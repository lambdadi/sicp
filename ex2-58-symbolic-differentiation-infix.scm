;; Chapter 2.3.2 Symbolic Differentiation example

;; Ex. 2.58 Support infix notation by modifying preds, selectors,
;; and constructors

;; Common utils
(define (variable? x)
  (symbol? x))

(define (same-variable? v1 v2)
  (and (variable? v1) (variable? v2) (eq? v1 v2)))

(define (=number? x y)
  (and (number? x) (number? y) (eq? x y)))


;; 2.58.a Fix assuming fully parenthesized expressions and
;; only two arguments.

(define (deriv exp var)
  ;; Sums
  (define (sum? e)
    (and (pair? e) (eq? '+ (cadr e))))

  (define addend car)

  (define augend caddr)

  (define (make-sum a1 a2)
    (cond ((eq? a1 0) a2)
          ((eq? a2 0) a1)
          ((and (number? a1) (number? a2))
           (+ a1 a2))
          (else (list a1 '+ a2))))

  ;; Products
  (define (product? e)
    (and (pair? e) (eq? '* (cadr e))))

  (define multiplier car)

  (define multiplicand caddr)

  (define (make-product m1 m2)
    (cond ((or (=number? m1 0) (=number? m2 0)) 0)
          ((=number? m1 1) m2)
          ((=number? m2 1) m1)
          ((and (number? m1) (number? m2)) (* m1 m2))
          (else
           (list m1 '* m2))))

  ;; Exponents
  (define (exponentiation? e)
    (and (pair? e) (eq? (cadr e) '^)))

  (define base car)

  (define exponent caddr)

  (define (make-exponentiation u n)
    (cond ((=number? u 0) 1)
          ((=number? n 1) u)
          ((and (number? u) (number? n)) (expt u n))
          (else
           (list u '^ n))))

  ;; Differentiation rules
  (cond ((number? exp)
         0)
        ((variable? exp)
         (if (same-variable? exp var) 1 0))
        ((sum? exp)
         (make-sum (deriv (addend exp) var)
                   (deriv (augend exp) var)))
        ((product? exp)
         (make-sum
          (make-product (multiplier exp)
                        (deriv (multiplicand exp) var))
          (make-product (deriv (multiplier exp) var)
                        (multiplicand exp))))
        ((exponentiation? exp)
         (let ((u (base exp))
               (n (exponent exp)))
           (make-product n
                         (make-product
                          (make-exponentiation u (make-sum n -1))
                          (deriv u var)))))
        (else
         (error "Unknown expression type: DERIV" exp))))


;; Examples:

(deriv '(x + (3 * (x + (y + 2)))) 'x)

(deriv '(x + 3) 'x)

(deriv '(x * y) 'x)

(deriv '((x * y) * (x + 3)) 'x)

(deriv '(x ^ 2) 'x)

(deriv '(x * (x + 3)) 'x)

;; Grows insanely
(deriv
 (deriv
  (deriv '(((x * (y * z))
            * (x * x))
           * (x ^ 3))
         'x)
  'x)
 'x)



;; Ex. 2.58.b Fix for standard infix algebraic notation, such as
;; (x + 3 * (x + y + 2)), which drops "unnecessary" parentheses
;; and assumes that multiplication is done before addition.

;; Solution (TBD):
;; Maybe we can get away with some sort of a "group-by" strategy.
;; Perhaps we can base it on:
;; - the associative property of addition and of multiplication
;; - give priority to multiplications
;; - use some sort of a look-ahead plan
;;
;; e.g. what if augend takes this:
;; (e1 + e2 * e3 * e4 + e5 + e6 + e7 * e8 + e9)
;;
;; and produces this?
;; (e1 + (e5 + (e6 + e9)))
;;
;; whereas addend produces this?
;; ((e2 * e3 * e4) + (e7 * e8))
;;
;; Anything even slightly more complicated, like full infix BODMAS,
;; will probably require a proper parser.

;; Punted in favour of moving on to further lessons (sets etc...)
