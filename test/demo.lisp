(in-package #:kons-9)


;;;; start plugins demos =======================================================

;;; uv-mesh --------------------------------------------------------------------
(with-clear-scene
  (add-shape *scene* (translate-to (make-grid-uv-mesh 3 1.5 1 1) (p! 0 0 -6.0)))
  (add-shape *scene* (translate-to (make-cylinder-uv-mesh 1.5 3 16 4) (p! 0 0 -4.0)))
  (add-shape *scene* (translate-to (make-cone-uv-mesh 2 2 16 7) (p! 0 0 -2.0)))
  (add-shape *scene* (translate-to (make-rect-prism-uv-mesh 1.5 3 4 2) (p! 0 0 0.0)))
  (add-shape *scene* (translate-to (make-pyramid-uv-mesh 2 2 5 3) (p! 0 0 2.0)))
  (add-shape *scene* (translate-to (make-torus-uv-mesh 1.0 2.0 8 32) (p! 0 0 4.0)))
  (add-shape *scene* (translate-to (make-sphere-uv-mesh 1.5 8 16) (p! 0 0 6.0)))
  )

;;; transform-extrude-uv-mesh --------------------------------------------------
(with-clear-scene
  (add-shape *scene* (transform-extrude-uv-mesh (make-rectangle-polygon 2 2 2)
                                                (make-euler-transform (p! 2 1 4) (p! 90 90 60) (p! 1 .5 .2))
                                                16)))

;;; transform-extrude-uv-mesh --------------------------------------------------
(with-clear-scene
  (add-shape *scene* (transform-extrude-uv-mesh (make-circle-polygon 2.0 16)
                                                (make-euler-transform (p! 0 0 4) (p! 0 0 360) (p! 2 .2 1))
                                                40)))

;;; transform-extrude-uv-mesh rotate-pivot -------------------------------------
(with-clear-scene
  (let ((xform (make-euler-transform (p! 0 0 4) (p! 0 0 360) (p! 2 .2 1))))
    (setf (pivot (rotate xform)) (p! 1 0 0))
;;;    (setf (operator-order xform) :trs) ;comment out to test effect of operator order
    (add-shape *scene* (transform-extrude-uv-mesh (make-circle-polygon 2.0 16)
                                                  xform
                                                  40))))

;;; transform-extrude-uv-mesh scale-pivot -------------------------------------
(with-clear-scene
  (let ((xform (make-euler-transform (p! 0 0 4) (p! 0 0 360) (p! 2 .2 1))))
    (setf (pivot (scale xform)) (p! 1 2 0))
    (add-shape *scene* (transform-extrude-uv-mesh (make-circle-polygon 2.0 16)
                                                  xform
                                                  40))))

;;; transform-extrude-uv-mesh generalized-transform ----------------------------
;;; should exactly match previous case
(with-clear-scene
  (let ((xform (make-instance 'generalized-transform
                              :operators
                              (list (make-instance 'translate-operator :offset (p! 0 0 4))
                                    (make-instance 'euler-rotate-operator :angles (p! 0 0 360))
                                    (make-instance 'scale-operator
                                                   :scaling (p! 2 .2 1)
                                                   :pivot (p! 1 2 0))))))
    (add-shape *scene* (transform-extrude-uv-mesh (make-circle-polygon 2.0 16)
                                                  xform
                                                  40))))

;;; sweep-extrude-uv-mesh ------------------------------------------------------
(with-clear-scene
  (let* ((path (make-sine-curve-polygon 360 1 4 2 64))
         (prof (make-circle-polygon 1.0 4))
         (mesh (sweep-extrude-uv-mesh prof path :twist (* 2 pi) :taper 0.0)))
    (add-shape *scene* mesh)))
;;; assign point colors by uv
(set-point-colors-by-uv (first (shapes *scene*))
                        (lambda (u v) (declare (ignore u)) (c-rainbow v)))
;;; assign point colors by xyz
(set-point-colors-by-xyz (first (shapes *scene*))
                         (lambda (p) (c-rainbow (clamp (tween (y p) -2 2) 0.0 1.0))))

;;; function-extrude-uv-mesh --------------------------------------------------
(with-clear-scene
  (add-shape *scene* (function-extrude-uv-mesh
                      (make-circle-polygon 2.0 16)
                      (lambda (points f)
                       (map 'vector (lambda (p)
                                      (p+ (p-jitter p (* .1 f)) (p! 0 0 (* 4 f))))
                            points))
                      20)))

;;; function-extrude-uv-mesh --------------------------------------------------
(with-clear-scene
  (add-shape *scene* (function-extrude-uv-mesh
                      (make-circle-polygon 2.0 16)
                      (lambda (points f)
                       (map 'vector (lambda (p)
                                      (p+ (p* p (sin (* pi f)))
                                          (p! 0 0 (* 4 f))))
                            points))
                      20)))

;;; heightfield ---------------------------------------------------------------
;;; try using various height functions and color functions
(with-clear-scene
  (add-shape *scene* (make-heightfield 80 80 (p! -5 0 -5) (p! 5 0 5)
                                       (lambda (x z)
                                         (* 4 (noise (p! x 0 z)))))))

(with-clear-scene
  (add-shape *scene* (make-heightfield 80 80 (p! -5 0 -5) (p! 5 0 5)
                                       (lambda (x z)
                                         (* 4 (turbulence (p! x 0 z) 4))))))

(with-clear-scene
  (add-shape *scene* (make-heightfield 80 80 (p! -5 0 -5) (p! 5 0 5)
                                       (lambda (x z)
                                         (let* ((p (p! x 0 z))
                                                (mag (p-mag (p* p .25))))
                                           (if (= mag 0.0)
                                               10.0
                                               (/ 1.0 mag)))))))

(with-clear-scene
  (add-shape *scene* (make-heightfield 80 80 (p! -5 0 -5) (p! 5 0 5)
                                       (lambda (x z)
                                         (let* ((p (p! x 0 z))
                                                (mag (max 0.001 (p-mag (p* p 4)))))
                                           (* 3 (/ (sin mag) mag)))))))

;;; rainbow color based on height
(let ((mesh (first (shapes *scene*))))
  (set-point-colors-by-xyz mesh (lambda (p) (c-rainbow (clamp (tween (y p) -.25 1.0) 0.0 1.0)))))

;;; rainbow color based on XZ distance from origin
(let ((mesh (first (shapes *scene*))))
  (set-point-colors-by-xyz mesh (lambda (p) (c-rainbow (clamp (tween (p-mag (p! (x p) 0 (z p))) 0 8) 0.0 1.0)))))

;;; 3D color noise
(let ((mesh (first (shapes *scene*))))
  (set-point-colors-by-xyz mesh (lambda (p) (color-noise p))))

;;; animated heightfield -------------------------------------------------------
(with-clear-scene
  (let ((mesh (make-heightfield 80 80 (p! -5 0 -5) (p! 5 0 5) nil)))
    (set-point-colors-by-xyz mesh (lambda (p) (c-rainbow (clamp (tween (p-mag (p! (x p) 0 (z p))) 0 8) 0.0 1.0))))
    (add-shape *scene* mesh)
    (macrolet ((my-height-fn (scale)
                 `(lambda (x z)
                    (let* ((p (p! x 0 z))
                           (mag (max 0.001 (p-mag (p* p ,scale)))))
                      (* 3 (/ (sin mag) mag))))))
      (add-motion *scene*
                    (make-instance 'animator
                                   :setup-fn (lambda ()
                                              (setf (height-fn mesh) (my-height-fn 1.0))
                                              (update-heightfield mesh))
                                   :update-fn (lambda ()
                                                (setf (height-fn mesh) (my-height-fn (+ 1.0 (current-time *scene*))))
                                                (update-heightfield mesh)))))))

;;; procedural-mixin superquadric ----------------------------------------------
(with-clear-scene
  (let ((mesh (make-superquadric 16 16 2.0 1 0.1)))
    (add-shape *scene* mesh)
    (translate-by mesh (p! 0 1 0))))

;;; modify slots and shape will change due to prcedural-mixin setup
(setf (e1 (first (shapes *scene*))) 0.5)

(setf (u-dim (first (shapes *scene*))) 32)

;;; animated superquadric
(with-clear-scene
  (let ((mesh (make-superquadric 32 32 2.0 1.0 1.0)))
    (add-shape *scene* mesh)
    (translate-by mesh (p! 0 1 0))
    (add-motion *scene*
                  (make-instance 'animator
                                 :setup-fn (lambda ()
                                            (setf (e1 mesh) 1.0)
                                            (setf (e2 mesh) 1.0))
                                 :update-fn (lambda ()
                                              (let ((p (p-normalize
                                                        (noise-gradient
                                                         (p! (+ (current-time *scene*) 0.123)
                                                             (+ (current-time *scene*) 0.347)
                                                             (+ (current-time *scene*) 0.965))))))
                                              (setf (e1 mesh) (* (abs (x p)) 2.0))
                                              (setf (e2 mesh) (* (abs (y p)) 2.0))))))))

;;; parametric-curve -----------------------------------------------------------

(with-clear-scene
  (add-shape *scene* (make-bezier-curve (p! -2 0 0) (p! -1 2 0) (p! 1 1 0) (p! 2 0 0))))

(with-clear-scene
  (add-shape *scene* (make-butterfly-curve-polygon 1024)))

;;; poly-mesh ------------------------------------------------------------------
(with-clear-scene
  (add-shape *scene* (translate-by (make-cube 2.0 :mesh-type 'poly-mesh) (p! 0 1 0))))
;;; select vertices
(progn
  (select-vertex (first (shapes *scene*)) 7)
  (select-vertex (first (shapes *scene*)) 6))
;;; select edges
(progn
  (select-edge (first (shapes *scene*)) 11)
  (select-edge (first (shapes *scene*)) 10))
;;; select faces
(progn
  (select-face (first (shapes *scene*)) 2)
  (select-face (first (shapes *scene*)) 5))

;;; shapes ---------------------------------------------------------------------

;;; display bounds, face-normals, and axis
(with-clear-scene
    (let ((circle (translate-to (make-circle-polygon 3.0  7) (p! 0 0 -4.0)))
          (superq (translate-by (make-superquadric 32 16 1.0 0.2 0.5) (p! 0 0 4.0)))
          (icos (make-icosahedron 2.0)))
      (setf (show-axis circle) 1.0)
      (setf (show-normals icos) 1.0)
      (setf (show-bounds? superq) t)
      (add-shapes *scene* (list circle superq icos))))


;;; l-system ------------------------------------------------------------------
;;; uncomment an l-system to test
(with-clear-scene
  (let ((l-sys
          ;; (make-koch-curve-l-system)
          ;; (make-binary-tree-l-system)
          ;; (make-serpinski-triangle-l-system)
          ;; (make-serpinski-arrowhead-l-system)
          ;; (make-dragon-curve-l-system)
           (make-fractal-plant-l-system)
          ))
    (add-shape *scene* l-sys)
    (add-motion *scene* l-sys)
    (update-scene *scene* 5)
    ;; resize shape to convenient size and center shape at origin
    (scale-to-size (first (shapes *scene*)) 5.0)
    (center-at-origin (first (shapes *scene*)))))
;;; WARNING -- press space key in 3D view to generate new l-system levels hangs for some of these
;;; need to investigate

;;; particle-system ------------------------------------------------------------
(with-clear-scene
  (let ((p-sys (make-particle-system (make-point-cloud (vector (p! 0 0 0)))
                                     (p! 0 .2 0) 10 -1 'particle
                                     :update-angle (range-float (/ pi 8) (/ pi 16))
                                     :life-span 10)))
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation

;;; particle-system force-field collisions
;;; TODO -- num of intial particles not working -- always 1
(with-clear-scene
  (let ((p-sys (make-particle-system (make-point-cloud (vector (p! 0 2 0)))
                                     (p-rand .2) 2 -1 'dynamic-particle
                                     :life-span 20
                                     :do-collisions? t
                                     :force-fields (list (make-instance 'constant-force-field
                                                                        :force-vector (p! 0 -.02 0))))))
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation

;;; xxx

;;; sweep-mesh dependency-node-mixin -------------------------------------------
(with-clear-scene
  (defparameter *profile* (make-circle 0.8 4))
  (defparameter *path* (make-sine-curve 360 1 4 1 32))
  (defparameter *mesh* (make-sweep-mesh *profile* 0 *path* 0 :twist (* 2 pi) :taper 0.0))
  (add-shape *scene* *mesh*))

;;; modify slots and shape will change
(setf (num-points *profile*) 6)
(setf (num-points *path*) 8)
(setf (taper *mesh*) 1.0)

;;; sweep-mesh dependency-node-mixin animator ----------------------------------
(with-clear-scene
  (defparameter *profile* (make-circle 1.2 4))
  (defparameter *path* (make-sine-curve 360 1 4 1 32))
  (defparameter *mesh* (make-sweep-mesh *profile* 0 *path* 0 :twist (* 2 pi) :taper 0.0))
  (let ((anim (make-instance 'animator
                             :setup-fn (lambda () (setf (num-points *profile*) 4) nil)
                             :update-fn (lambda () (incf (num-points *profile*))))))
    (add-motion *scene* anim)
    (add-shape *scene* *mesh*)))
;;; hold down space key in 3D view to run animation

;;; dynamics-animator ----------------------------------------------------------
(with-clear-scene
  (let ((shapes '()))
    (dotimes (i 100) (push (make-cube 0.2) shapes))
    (add-shape *scene* (make-group shapes))
    (add-motions *scene*
                   (mapcar (lambda (s)
                               (translate-by s (p! (rand1 2.0) (rand2 2.0 4.0) (rand1 2.0)))
                               (make-instance 'dynamics-animator
                                              :shape s
                                              :velocity (p-rand 0.1)
                                              :do-collisions? t
                                              :collision-padding 0.1
                                              :elasticity 0.5
                                              :force-fields (list (make-instance 'constant-force-field
                                                                                 :force-vector (p! 0 -.02 0)))))
                           shapes))))
;;; hold down space key in 3D view to run animation

;;; obj import -----------------------------------------------------------------

(defparameter *example-obj-filename* 
  (first (list (asdf:system-relative-pathname "kons-9" "test/data/cow.obj")
               (asdf:system-relative-pathname "kons-9" "test/data/teapot.obj")))
  "An example object filename used in demonstrations for the OBJ-IMPORT facility.

You can find obj files at

  https://people.sc.fsu.edu/~jburkardt/data/obj/obj.html

in this and demos below, update the *EXAMPLE-OBJ-FILENAME* for your setup.")

(with-clear-scene
  (add-shape *scene*
             (import-obj *example-obj-filename*)))

;;; particle system growth along point-cloud -----------------------------------
(with-clear-scene
  (let* ((shape (generate-point-cloud (triangulate-polyhedron (import-obj *example-obj-filename*))
                                      100))
         (p-sys (make-particle-system (make-point-cloud (vector (p! 0 0 0)))
                                      (p! .2 .2 .2) 10 -1 'climbing-particle
                                      :support-point-cloud shape
                                      :update-angle (range-float (/ pi 8) (/ pi 16))
                                      :life-span (rand1 5 10))))
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation -- gets slow, need to profile code & optimize

;;; particle system growth along point-cloud & sweep-extrude -------------------
(with-clear-scene
  (let* ((shape
           (import-obj *example-obj-filename*))
         (cloud (generate-point-cloud shape 100))
         (p-sys (make-particle-system (make-point-cloud (vector (p! 0 0 0)))
                                      (p! .2 .2 .2) 10 -1 'climbing-particle
                                      :support-point-cloud cloud
                                      :update-angle (range-float (/ pi 8) (/ pi 16))
                                      :life-span (rand1 5 10))))
    (add-shape *scene* shape)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation -- gets slow, need to profile code & optimize
;;; sweep-extrude along particle system paths (first shape in scene)
;;; BUG -- the group contains at least one degenerate uv-mesh (16x16) with no points, causing
;;; a crash in set-point-colors-by-uv (added sanity check in that method)
(let ((group (make-group (sweep-extrude (make-circle 0.1 8)
                                        (first (shapes *scene*))
                                        :taper 1.0 :twist 0.0 :from-end? nil))))
  (set-point-colors-by-uv group (lambda (u v)
                                  (declare (ignore u v))
                                  (c! 0.1 0.5 0.1)))
  (add-shape *scene* group))

;;; point-instancer ------------------------------------------------------------
(with-clear-scene
  (let ((shape (make-point-instancer (import-obj *example-obj-filename*)
                                     (make-octahedron .2))))
    (add-shape *scene* shape)))
;;; change inputs and shape regenerates
(setf (instance-shape (first (shapes *scene*))) (make-icosahedron .2))

(setf (point-generator (first (shapes *scene*))) (make-sine-curve 360.0 1.0 4.0 4.0))

;;; point-instancer particle-system --------------------------------------------
(with-clear-scene
  (let* ((p-sys (make-particle-system (make-point-cloud (vector (p! 0 0 0)))
                                      (p! 0 .2 0) 10 -1 'particle
                                      :update-angle (range-float (/ pi 8) (/ pi 16))
                                      :life-span (rand1 5 10))))
;    (setf (draw-live-points-only? p-sys) nil)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation
;;; instance shapes along particle system points
(add-shape *scene* (make-point-instancer (first (shapes *scene*))
                                         (make-octahedron .2)))
;;; hold down space key in 3D view to run animation with point-instancer updating

;;; point-instancer particle-system dependency-node-mixin ----------------------
(with-clear-scene
  (let* ((p-sys (make-particle-system (make-point-cloud (vector (p! 0 0 0)))
                                      (p! 0 .2 0) 10 -1 'particle
                                      :update-angle (range-float (/ pi 8) (/ pi 16))
                                      :life-span (rand1 5 10)))
         (shape (make-point-instancer p-sys
                                      (make-octahedron .2))))
    ;;; uncomment to only instance at live position
;;;    (setf (point-generator-use-live-positions-only p-sys) t)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)
    (add-shape *scene* shape)
    ))
;;; hold down space key in 3D view to run animation

;;; transform-instancer euler-transform ----------------------------------------
(progn
  (defparameter *instancer*
    (make-transform-instancer (make-cube 1.0)
                              (make-euler-transform (p! 0 7 0) (p! 0 90 0) (p! 1 1 0.2))
                              8))
  (with-clear-scene
    (add-shape *scene* *instancer*)))

;;; change inputs and shape regenerates
(setf (instance-shape *instancer*) (make-superquadric 16 16 1 .2 .2))

(setf (num-steps *instancer*) 6)

;;; transform-instancer angle-axis-transform -----------------------------------
(progn
  (defparameter *instancer*
    (make-transform-instancer (make-cube 1.0)
                              (make-axis-angle-transform (p! 0 7 0) 90 (p! 1 2 3) (p! 1 1 0.2))
                              8))
  (with-clear-scene
    (add-shape *scene* *instancer*)))

;;; change inputs and shape regenerates
(setf (instance-shape *instancer*) (make-superquadric 16 16 1 .2 .2))

;;; requires call to compute because of limitations of dependency-node-mixin
(progn
  (rotate-to (instance-transform *instancer*) 150)
  (compute-procedural-node *instancer*))

;;; uv-mesh transform-instancer 1 ----------------------------------------------
(with-clear-scene
  (let* ((path (make-sine-curve 360 1 4 1 32))
         (prof (make-circle 0.6 4))
         (mesh (first (sweep-extrude prof path :twist (* 2 pi) :taper 0.0)))
         (transform (make-euler-transform (p! 0 0 0) (p! 0 (* 360 7/8) 0) (p! 1 1 1))))
    (add-shape *scene* (make-transform-instancer mesh transform 8))))

;;; change inputs and shape regenerates
(setf (num-steps (first (shapes *scene*))) 4)

;;; uv-mesh transform-instancer 2 ----------------------------------------------
(with-clear-scene
  (let* ((path (make-sine-curve 360 1 4 1 32))
         (prof (make-circle 0.6 4))
         (mesh (first (sweep-extrude prof path :twist (* 2 pi) :taper 0.0))))
    (set-point-colors-by-uv mesh (lambda (u v)
                                   (declare (ignore u))
                                   (c-rainbow v)))
    (let* ((transform-1 (make-euler-transform (p! 0 0 0) (p! 0 (* 360 7/8) 0) (p! 1 1 1)))
           (group-1 (make-transform-instancer mesh transform-1 8))
           (transform-2 (make-euler-transform (p! 0 6 0) (p! 0 45 0) (p! .2 .2 .2)))
           (group-2 (make-transform-instancer group-1 transform-2 6)))
      (add-shape *scene* group-2))))

;;; particle-system curve-shape force-field ------------------------------------
(with-clear-scene
  (let* ((curve (make-procedural-circle-polygon 4.0 16))
         (p-sys (make-particle-system curve (p! .2 .2 .2) 1 4 'dynamic-particle
                                      :force-fields (list (make-instance 'constant-force-field
                                                                         :force-vector (p! 0 -.02 0))))))
    (add-shape *scene* curve)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation

;;; particle-system curve-shape sweep-extrude ----------------------------------
(with-clear-scene
  (let* ((p-gen (make-circle 4.0 16))
         (p-sys (make-particle-system p-gen (p! .2 .2 .2) 4 4 'particle
                                      :update-angle (range-float (/ pi 16) (/ pi 32)))))
    (add-shape *scene* p-gen)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation
;;; do sweep along paths
(let ((group (make-group (sweep-extrude (make-circle 0.5 6)
                                        (first (shapes *scene*))
                                        :taper 0.0))))
  (set-point-colors-by-uv group (lambda (u v) (declare (ignore u)) (c-rainbow v)))
  (add-shape *scene* group))

;;; particle-system point-generator-mixin uv-mesh ------------------------------
(with-clear-scene
  (let* ((p-gen (make-grid-uv-mesh 8 8 24 24))
         (p-sys (make-particle-system p-gen (p! .2 .2 .2) 1 4 'particle
                                      :update-angle (range-float (/ pi 16) (/ pi 32)))))
    (add-shape *scene* p-gen)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation
;;; do sweep along paths
(let ((group (make-group (sweep-extrude (make-procedural-circle-polygon 0.2 6)
                                        (first (shapes *scene*))
                                        :taper 0.0))))
  (set-point-colors-by-uv group (lambda (u v) (declare (ignore u)) (c-rainbow v)))
  (add-shape *scene* group))

;;; particle-system point-generator-mixin sweep-mesh-group ---------------------
(with-clear-scene
  (let* ((p-gen (make-grid-uv-mesh 8 8 24 24))
         (p-sys (make-particle-system p-gen (p! .2 .2 .2) 1 4 'particle
                                      :update-angle (range-float (/ pi 16) (/ pi 32))))
         (sweep-mesh-group (make-sweep-mesh-group (make-circle 0.2 6)
                                                  p-sys
                                                  :taper 0.0 :twist 2pi)))
;;    (add-shape *scene* p-gen)
;;    (add-shape *scene* p-sys)
    (add-shape *scene* sweep-mesh-group)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation

;;; particle-system point-generator-mixin sweep-mesh-group spawning ------------
(with-clear-scene
  (let* ((p-gen (make-grid-uv-mesh 4 4 1 1))
         (p-sys (make-particle-system p-gen (p! .2 .2 .2) 1 8 'particle
                                      :life-span (round (rand2 5 10))
                                      :update-angle (range-float (/ pi 16) (/ pi 32))))
         (sweep-mesh-group (make-sweep-mesh-group (make-circle 0.2 6) p-sys
                                                  :taper 0.0 :twist 0.0)))
    (add-shape *scene* p-sys)
    (add-shape *scene* sweep-mesh-group)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation

;;; particle-system point-generator-mixin use polyh face centers ---------------
(with-clear-scene
  (let ((p-gen (make-icosahedron 2.0)))
    (setf (point-source-use-face-centers? p-gen) t)
    (let* ((p-sys (make-particle-system p-gen (p! .2 .2 .2) 1 4 'particle
                                        :life-span 10
                                        :update-angle (range-float (/ pi 16) (/ pi 32))
                                        :spawn-angle (range-float (/ pi 8) (/ pi 16))))
           (sweep-mesh-group (make-sweep-mesh-group (make-circle 0.2 6) p-sys
                                                    :taper 0.0 :twist 0.0)))
      (add-shape *scene* p-gen)
      (add-shape *scene* p-sys)
      (add-shape *scene* sweep-mesh-group)
      (add-motion *scene* p-sys))))
;;; hold down space key in 3D view to run animation

;;; particle-system point-generator-mixin polyhedron ---------------------------
(with-clear-scene
z  (let* ((p-gen (import-obj *example-obj-filename*))
         (p-sys (make-particle-system p-gen (p! .2 .2 .2) 1 4 'dynamic-particle
                                       :force-fields (list (make-instance 'constant-force-field
                                                                          :force-vector (p! 0 -.05 0))))))
    (add-shape *scene* p-gen)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation -- slow, profile & optimize

;;; particle-system point-generator-mixin particle-system ----------------------
(with-clear-scene
  (let* ((p-gen (polyhedron-bake (translate-by (make-superquadric 8 5 2.0 1.0 1.0)
                                               (p! 0 2 0))))
         (p-sys (make-particle-system p-gen (p! .4 .4 .4) 1 1 'particle
                                      :update-angle (range-float (/ pi 16) (/ pi 32)))))
    (add-shape *scene* p-gen)
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation
;;; make new particle-system generate from paths of existing particle-system
(progn
  (clear-motions *scene*)             ;remove exsting particle animator
  (let* ((p-gen (first (shapes *scene*)))
         (p-sys (make-particle-system p-gen (p! .4 .4 .4) 1 1 'particle
                                      :update-angle (range-float (/ pi 16) (/ pi 32)))))
    (add-shape *scene* p-sys)
    (add-motion *scene* p-sys)))
;;; hold down space key in 3D view to run animation
;;; do sweep-extrude
(let ((group (make-group (sweep-extrude (make-circle 0.25 4)
                                        (first (shapes *scene*))
                                        :taper 0.0))))
  (set-point-colors-by-uv group (lambda (u v)
                                  (declare (ignore u))
                                  (c-rainbow v)))
    (add-shape *scene* group))

;;; polyhedron curve-generator-mixin -------------------------------------------
(with-clear-scene
  (let ((polyh (make-cut-cube-polyhedron 4.0)))
    (add-shape *scene* polyh)))
;;; sweep-extrude circle along polyh faces
(add-shape *scene*
           (make-group (sweep-extrude (make-circle 0.5 6)
                                      (first (shapes *scene*)))))

;;;; END ========================================================================
