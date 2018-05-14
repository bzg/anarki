; List comprehensions -- Kartik Agaram -- http://arclanguage.org/item?id=20381
;
; Idea suggested by musk_fan (http://arclanguage.org/item?id=20375).
; This implementation inspired by Common Lisp's 'iterate macro (https://common-lisp.net/project/iterate)
; as described by Michael Malis (http://malisper.me/loops-in-lisp-part-3-iterate).

(mac collect (expr . guards)
"Creates a list of data based on a sort of 'set builder' notation.
https://en.wikipedia.org/wiki/List_comprehension"
  (w/uniq gacc
    `(accum ,gacc
        ,(apply ingest
                (join (map collect-transform guards)
                      (list `(,gacc ,expr)))))))

(examples collect
  (collect i (for i from 1 to 3))
  (1 2 3)
  (collect (* i 2) (for i from 1 to 3))
  (2 4 6)
  (collect (list i j)
           (for i from 1 to 3)
           (for j from 1 to 3)
           (if (< i j)))
  ((1 2) (1 3) (2 3)))

(def ingest lists
  (when lists
    (ret x car.lists
      (when cdr.lists
        (let lastx lastcons.x
          (= cdr.lastx
             (list (apply ingest cdr.lists))))))))

(def collect-transform (guard)
  (if (is 'for guard.0)
        (if (is 5 len.guard)
              ; regular syntax: (for _var _init _term _update)
              guard
            (and (is 7 len.guard) (is 'from guard.2) (is 'down guard.4) (is 'to guard.5))
              ; (for _ from _ down to _)
              `(down ,guard.1 ,guard.3 ,guard.6)
            (and (is 6 len.guard) (is 'from guard.2) (is 'to guard.4))
              ; (for _ from _ to _)
              `(up ,guard.1 ,guard.3 ,guard.5)
            (and (is 4 len.guard) (is 'in guard.2))
              ; (for _ in _)
              `(each ,guard.1 ,guard.3)
            'else
              (err "don't understand how to handle " guard " in collect macro"))
      ; insert other syntax here
      'else
        guard))
