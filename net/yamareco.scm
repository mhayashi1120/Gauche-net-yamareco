(define-module net.yamareco
  (use net.yamareco.api)
  )
(select-module net.yamareco)


;; copy module export
(let* ([api-mod (find-module 'net.yamareco.api)]
       [api-table (module-table api-mod)]
       [main-mod (find-module 'net.yamareco)]
       [main-table (module-table main-mod)]
       [api-exports (module-exports api-mod)])
  (hash-table-map
   api-table
   (^ [s g]
     (when (memq s api-exports)
       (hash-table-put! main-table s g)))))


(export-all)

