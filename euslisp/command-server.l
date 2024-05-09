#!/usr/bin/env roseus

(load "package://kxreus/euslisp/kxr-interface.l")
(ros::roseus-add-srvs "kxr_cube_solver")

(ros::roseus "kxr_command_server")

(defun gripper-angle(arm angle)
  (send *robot* arm :gripper-r :joint-angle angle)
  (send *robot* arm :gripper2-r :joint-angle angle))

(defun grasp(arm)
  (gripper-angle arm 23)
  (send *ri* :angle-vector (send *robot* :angle-vector) 500)
  (send *ri* :wait-interpolation))

(defun release(arm)
  (gripper-angle arm 55)
  (send *ri* :angle-vector (send *robot* :angle-vector) 200)
  (send *ri* :wait-interpolation))

(defun angle(arm angle)
  (let ((angle (+ angle (if (eq arm :rarm) *rwr-offset* *lwr-offset*)))
	      (wr (send *robot* arm :wrist-r))
	      da n)
    (setq da (- angle (send wr :joint-angle)))
    (setq n (round (/ (abs da) 30)))
    (send wr :joint-angle angle)
    (send *ri* :angle-vector (send *robot* :angle-vector) (* n 200))
    (send *ri* :wait-interpolation)))

(defun init-pose()
  (setq *rwr-offset* 11)
  (setq *lwr-offset* -7)
  (send *robot* :init-pose)
  (send *robot* :rarm :shoulder-p :joint-angle -95)
  (send *robot* :larm :shoulder-p :joint-angle 90)
  (send *robot* :larm :shoulder-r :joint-angle -10)
  (send *robot* :rarm :shoulder-y :joint-angle  45)
  (send *robot* :larm :shoulder-y :joint-angle -45)
  (send *robot* :rarm :elbow-p :joint-angle -15)
  (send *robot* :larm :elbow-p :joint-angle 15)
  (send *robot* :rarm :wrist-p :joint-angle  20)
  (send *robot* :larm :wrist-p :joint-angle  -15)
  (send *robot* :rarm :wrist-r :joint-angle *rwr-offset*)
  (send *robot* :larm :wrist-r :joint-angle *lwr-offset*)
  (send *robot* :head-neck-p :joint-angle 15)
  (gripper-angle :rarm 30)
  (gripper-angle :larm 30)
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000)
  (send *ri* :wait-interpolation))

(defun command-callback (req)
  (let ((com (send req :command))
        (res (send req :response)))
    (print com)
    (eval (read-from-string com))
    (send res :success t)
    res))

(defun start-command-server ()
  (ros::ros-info "start command server")
  (while t
    (ros::spin-once) ;; need to execute callbacks
    (ros::sleep)))

(defun demo()
  (kxr-init :create-viewer nil)
  (start-command-server))


(ros::rate 10)
(ros::advertise-service "~send_command" kxr_cube_solver::SendCommand #'command-callback)
(demo)
