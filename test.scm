;;;
;;; Test net_yamareco
;;;

(use gauche.test)

(test-start "net.yamareco")

(use net.yamareco)
(test-module 'net.yamareco)

(use net.yamareco.api)
(test-module 'net.yamareco.api)

(test-end :exit-on-failure #t)




