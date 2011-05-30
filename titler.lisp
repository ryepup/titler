;;;; titler.lisp

(in-package #:titler)

;;; "titler" goes here. Hacks and glory await!

(defun lines (text)
  "splits a string into lines, returns the list of lines, longest line, and number of lines"
  (with-input-from-string (s text)
    (iter (for l = (read-line s nil nil))
	  (with longest = "")
	  (while l)
	  (collect l into lines)
	  (when (< (length longest) (length l))
	    (setf longest l))
	  (finally (return (values lines longest (length lines)))))))

(defun title-bounding-box (longest-line num-lines font size)
  "returns bounding box as a list (width height)"
  (let* ((box (string-bounding-box longest-line size font))
	 (xmin (svref box 0))
	 (ymin (svref box 1))
	 (xmax (svref box 2))
	 (ymax (svref box 3)))
    (list (- xmax xmin) (* num-lines (- ymax ymin)))))

(defun find-optimal-font-size (width height num-lines longest-line font
			       &optional (upper-bound 40) (lower-bound 0))
  "search for the biggest font size that can be used for to display the text"
  (destructuring-bind (text-width text-height) (title-bounding-box longest-line num-lines font upper-bound)
    (cond
      ((or (> text-width (* width 0.9))
	   (> text-height (* height 0.9)))
       ;;too big, back down
       (find-optimal-font-size width height num-lines longest-line font
			       (+ lower-bound (truncate (- upper-bound lower-bound) 2))
			       lower-bound))
      ((< text-width (* width 0.75))
       ;;text takes less than 75% of width, too small, try doubling
       (find-optimal-font-size width height num-lines longest-line font (* upper-bound 2) upper-bound))
      (T (values upper-bound text-height)))))

(defun make-title (text width height &key (background-color '(0 0 0))
		   (text-color '(1 1 1))
		   (font-file "/home/ryan/lisp/titler/times.ttf")
		   (outfile "title.png"))
  (with-canvas (:width width :height height)
    (apply #'set-rgb-fill background-color)
    (clear-canvas)
    (apply #'set-rgb-fill text-color)
    (let ((font (get-font font-file)))
      (multiple-value-bind (lines longest num-lines) (lines text)
	(multiple-value-bind (font-size text-height)
	    (find-optimal-font-size width height num-lines longest font)
	  (set-font font font-size)
	  (iter
	    (with x = (truncate width 2))
	    (with line-height = (truncate text-height num-lines))

	    (with ymargin = (truncate (- height text-height) 2))
	    (for line in lines)
	    (for i from 0)
	    (for y = (- height (+ ymargin (* i line-height))) )
	    (draw-centered-string x y line)))))
    (save-png outfile)))
