(define-module net.yamareco.api
  (use text.tr)
  (use srfi-13)
  (use rfc.json)
  (use rfc.http)
  (use net.oauth2)
  (use gauche.parameter)
  (export

   ;; parameter
   api-server api-use-ssl

   ;; Type
   <yamareco-cred> <yamareco-api-error>

   ;; OAuth
   yamareco-authenticate
   yamareco-write-credential yamareco-read-credential

   ;; no oauth
   get-area-list/json
   get-genre-list/json
   get-record-list/json
   search-record/json
   search-poi/json
   nearby-poi/json
   get-type-list/json
   get-user-info/json

   ;; require oauth
   get-cheer-list/json
   get-record/json

   ;; low level API
   GET/json
   POST/json
   ))
(select-module net.yamareco.api)

;;;
;;; internal function
;;;

(define (oauth-token cred)
  (and cred
       (format "OAuth ~a" (~ cred 'access-token))))

(define (read-response status hdrs body)
  (unless (#/^2[0-9][0-9]$/ status)
    (errorf "HTTP status ~a with ~s" status hdrs))
  (let1 json (parse-json-string body)
    (when (if-let1 err (assoc-ref json "err")
            (equal? err 1) #f)
      (errorf <yamareco-api-error> "API error ~a" body))
    (values json hdrs)))

;;;
;;; API
;;;

(define-condition-type <yamareco-api-error> <error> #f
  )

(define-class <yamareco-cred> (<oauth2-cred>)
  ((client-id     :init-keyword :client-id)
   (client-secret :init-keyword :client-secret)))

(define api-use-ssl
  (make-parameter #t))

(define api-server
  (make-parameter "api.yamareco.com"))

;;
;; OAuth
;;

(define (yamareco-authenticate client-id client-secret redirect-uri)
  (define (prompt)
    (let1 auth-url (oauth2-construct-auth-request-url
                    #`"https://,(api-server)/api/v1/oauth"
                    client-id :scope "all"
                    :redirect redirect-uri)
      (print "Open the following url and type in the shown PIN.")
      (print auth-url)
      (let loop ()
        (display "Input code: ")
        (flush)
        (let1 code (read-line)
          (cond
           [(eof-object? code) #f]
           [(string-null? code) (loop)]
           [else code])))))

  (define (request code)
    (let1 json (oauth2-request-auth-token
                #`"https://,(api-server)/api/v1/oauth/access_token"
                code redirect-uri client-id
                ;; optional param
                :client-secret client-secret)
      (unless (= (assoc-ref json "error") 0)
        (errorf "failed yamareco authentication ~a"
                (assoc-ref json "error_message")))
      (assoc-ref json "access_token")))

  (define (make-cred token)
    (make <yamareco-cred>
      :access-token token
      :client-id client-id
      :client-secret client-secret))

  (let* ([code (prompt)]
         [token (request code)])

    (make-cred token)))

;;;
;;; Utilities
;;;

(define (yamareco-read-credential file)
  (with-input-from-file file
    (^() (oauth2-read-token <yamareco-cred>))))

(define (yamareco-write-credential cred file)
  (with-output-to-file file
    (^() (oauth2-write-token cred)))
  (sys-chmod file #o600))



;;
;; Low level API
;;

(define (GET/json path :optional (cred #f))
  (call-with-values
      (^() (http-get (api-server)
                      #`"/api/v1,|path|"
                      :Authorization (oauth-token cred)
                      :secure (api-use-ssl)))
    read-response))

(define (POST/json path request :optional (cred #f))
  (call-with-values
      (^() (http-post (api-server)
                      #`"/api/v1,|path|"
                      (http-compose-query #f request 'utf-8)
                      :Authorization (oauth-token cred)
                      :secure (api-use-ssl)
                      :content-type "application/x-www-form-urlencoded"))
    read-response))

(define-macro (query-params . vars)
  `(cond-list
    ,@(map (^v
            `(,v `(,',(->param-key v)
                   ,(->param-value ,v))))
           vars)))

(define-macro (api-params keys . vars)
  `(append
    (query-params ,@vars)
    (let loop ([ks ,keys]
               [res '()])
      (cond
       [(null? ks) (reverse! res)]
       [else
        (let* ([key (->param-key (car ks))]
               [val (->param-value (cadr ks))])
          (cond
           [(not val)
            (loop (cddr ks) res)]
           [else
            (loop (cddr ks) (cons (list key val) res))]))]))))

(define (->param-key x)
  (string-tr (x->string x) "-" "_"))

(define (->param-value x)
  (cond
   [(eq? x #f) #f]
   [else (x->string x)]))

;;
;; REST api
;;

(define (get-area-list/json)
  (GET/json "/getArealist"))

(define (get-genre-list/json)
  (GET/json "/getGenrelist"))

;; 1 <= page
(define (get-record-list/json :key (page #f) (max-id #f) (userID #f))
  (let1 path "/getReclist"
    (when userID
      (set! path #`",|path|/user/,|userID|"))
    (when page
      (set! path #`",|path|/,|page|"))
    (when (and max-id (not userID))
      (set! path #`",|path|?max_id=,|max-id|"))
    (GET/json path)))

;; https://sites.google.com/site/apiforyamareco/api/rest-api#TOC-2.16-searchRec-OAuth-
(define (search-record/json
         place
         :key (page 1) (area-id 0) (genre-id 0)
         (is-photo 0) (is-track 0) (ptid 0)
         :allow-other-keys _keys)
  (let1 request (api-params _keys
                            place page area-id genre-id
                            is-photo is-track ptid)
    (POST/json "/searchRec" request)))

;; https://sites.google.com/site/apiforyamareco/api/rest-api#TOC-2.17-searchPoi-OAuth-
(define (search-poi/json
         name
         :key (page 1) (type-id 0) (area-id 0)
         :allow-other-keys _keys)
  (let1 request (api-params _keys page name type-id area-id)
    (POST/json "/searchPoi" request)))

;; https://sites.google.com/site/apiforyamareco/api/rest-api#TOC-2.18-nearbyPoi-OAuth-
;; lat, lon is not described as required, but required parameter. (documentation mistake)
(define (nearby-poi/json lat lon range
         :key (page 1) (type-id 0)
         :allow-other-keys _keys)
  (let1 request (api-params _keys lat lon page range type-id)
    (POST/json "/nearbyPoi" request)))

(define (get-type-list/json)
  (GET/json "/getTypelist"))

(define (get-user-info/json :key (uid #f))
  (let1 path "/getUserInfo"
    (when uid
      (set! path #`",|path|/,|uid|"))
    (GET/json path)))

;; type: rec/rec_photo
(define (get-cheer-list/json cred type id)
  (let1 path "/getCheerlist"
    (when (and type id)
      (set! path #`",|path|/,|type|/,|id|"))
    (GET/json path cred)))

(define (get-record/json cred rec-id)
  (let1 path "/getRec"
    (set! path #`",|path|/,|rec-id|")
    (GET/json path cred)))
