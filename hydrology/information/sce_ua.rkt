(define (SCE_UA object_function range dimension)
  (define NGS 50)
  (define NPG 50)
  (define NPT 2500)
  (define NSPL 10)
  (define MAXN 500)
  (define random
    (let ((a 69069) (c 1) (m (expt 2 32)) (seed 19380110))
       (lambda new-seed
          (if (pair? new-seed)
              (set! seed (car new-seed))
              (set! seed (modulo (+ (* seed a) c) m)))
          (+ (/ seed m) 0.0))))  
  (define (generate_strings)
    (define (build) 
      (define (b_in i ls)
        (if (> i dimension) '() (cons (+ (caar ls) (* (random) (- (cadr (car ls)) (caar ls)))) (b_in (+ i 1) (cdr ls)))))
      (b_in 1 range))
    (define (pro i)
      (if (> i NPT) '() (cons (build) (pro (+ i 1)))))
    (define (rank-pop pop)
      (map (lambda(str) (list (object_function str) str)) pop)) 
    (rank-pop (pro 1)))   
  (define (divide lis) 
    (define (qsort e)
      (if (or (null? e) (<= (length e) 1)) e
          (let loop ((left '()) (right '()) (pivot (car e)) (rest (cdr e)))
            (if (null? rest)
                (append (append (qsort left) (list pivot)) (qsort right))
                (if (<= (caar rest) (car pivot))
                    (loop (append left (list (car rest))) right pivot (cdr rest))
                    (loop left (append right (list (car rest))) pivot (cdr rest))))))) 
    (define (cluster str)
      (define (take n xs)
        (define (iter s n taken)
          (if (zero? n) (reverse taken) (iter (cdr s) (- n 1) (cons (car s) taken))))
        (iter xs n '()))
      (define (drop n xs)
        (define (iter s n)
          (if (zero? n) s (iter (cdr s) (- n 1))))
        (iter xs n))
      (if (null? str) '() (cons (take NGS str) (cluster (drop NGS str)))))   
    (define (transpose matrix)
      (define (accumulate-n op init seqs)
        (define (accumulate op initial sequence)
          (if (null? sequence)  initial (op (car sequence) (accumulate op initial (cdr sequence)))))
        (if (null? (car seqs)) '() (cons (accumulate op init (map (lambda(x) (car x)) seqs)) (accumulate-n op init (map (lambda(x) (cdr x)) seqs)))))
      (accumulate-n cons '() matrix))
    (transpose (cluster (qsort lis)))) 
  (define (evolve lis)  
    (define (improve x)
      (define (manipulate x)
        (define (process m n)
          (define (center)
            (define (com a)
              (define (plus ls1 ls2)
                (if (null? ls2) ls1 (map (lambda(x y) (+ x y)) ls1 ls2))) 
              (if (null? a) '() (plus (cadr (car a)) (com (cdr a)))))
            (map (lambda(z) (/ z (length n))) (com n)))
          (define (reflect)
            (map (lambda(x y) (- (* 2.0 y) x)) (cadr m) (center)))
          (define (contract)
            (map (lambda(x y) (/ (+ x y) 2.0)) (cadr m) (center)))
          (define (mutation)
            (define (b_in i ls)
              (if (> i dimension) '() (cons (+ (caar ls) (* (random) (- (cadr (car ls)) (caar ls)))) (b_in (+ i 1) (cdr ls)))))
            (b_in 1 range))
          (define (within string)
            (define (certi x)
              (if (null? x) #t (and (car x) (certi (cdr x)))))
            (certi (map (lambda(x y) (and (> x (car y)) (< x (cadr y)))) string range)))
          (cond ((and (within (reflect)) (> (object_function (reflect)) (car m))) (cons (object_function (reflect)) (list(reflect))))
                ((and (within (contract)) (> (object_function (contract)) (car m))) (cons (object_function (contract)) (list (contract))))
                (else (cons (object_function (mutation)) (list (mutation))))))    
        (let ((a (car x)) (b (cdr x)))
          (cons (process a b) b)))
      (define (d n x)
        (if (> n NSPL) x (d (+ n 1) (manipulate x))))
      (d 1 x))
    (map (lambda(i) (improve i)) lis)) 
  (define (shuffle lis)
    (define (seperate x)
      (if (null? x) '() (append (car x) (seperate (cdr x)))))
    (divide (seperate lis))) 
  (define (mainline i lis)
    (cond ((eq? i 1) (mainline (+ i 1) (divide (generate_strings))))
          ((< i MAXN) (mainline (+ i 1) (shuffle (evolve lis))))
          (else (car (reverse (car (reverse lis)))))))
  (mainline 1 '()))

  

  