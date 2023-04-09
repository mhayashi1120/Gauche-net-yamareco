;;
;; Package Gauche-net-yamareco
;;

(define-gauche-package "Gauche-net-yamareco"
  :version "0.3.2"

  ;; Description of the package.  The first line is used as a short
  ;; summary.
  :description "ヤマレコの api を呼び出す。\n\
                API に関しての詳細は本家の Document をご覧ください。https://sites.google.com/site/apiforyamareco/api/rest-api"

  ;; List of dependencies.
  ;; Example:
  ;;     :require (("Gauche" (>= "0.9.5"))  ; requires Gauche 0.9.5 or later
  ;;               ("Gauche-gl" "0.6"))     ; and Gauche-gl 0.6
  :require (
            ("Gauche-net-oauth2" (>= "0.1.1"))
            ("Gauche" (>= "0.9.12"))
            )

  ;; List of providing modules
  ;; NB: This will be recognized >= Gauche 0.9.7.
  ;; Example:
  ;;      :providing-modules (util.algorithm1 util.algorithm1.option)
  :providing-modules (
                      net.yamareco
                      )
  
  ;; List name and contact info of authors.
  ;; e.g. ("Eva Lu Ator <eval@example.com>"
  ;;       "Alyssa P. Hacker <lisper@example.com>")
  :authors ("Masahiro Hayashi <mhayashi1120@gmail.com>")

  ;; List name and contact info of package maintainers, if they differ
  ;; from authors.
  ;; e.g. ("Cy D. Fect <c@example.com>")
  :maintainers ()

  ;; List licenses
  ;; e.g. ("BSD")
  :licenses ("BSD")

  ;; Homepage URL, if any.
  :homepage "https://github.com/mhayashi1120/Gauche-net-yamareco/"

  ;; Repository URL, e.g. github
  :repository "https://github.com/mhayashi1120/Gauche-net-yamareco.git"
  )
