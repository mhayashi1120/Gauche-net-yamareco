;;;
;;; Test net_yamareco
;;;

(use gauche.test)

(test-start "net.yamareco")
(use net.yamareco)
(test-module 'net.yamareco)

;; If you don't want `gosh' to exit with nonzero status even if
;; the test fails, pass #f to :exit-on-failure.
(test-end :exit-on-failure #t)




