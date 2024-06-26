#!/usr/bin/env roseus

(load "package://kxreus/euslisp/kxr-interface.l")
(ros::roseus-add-srvs "kxr_cube_solver")

(ros::roseus "kxr_command_server")

(setq *rwr-offset* -7)
(setq *lwr-offset* 15)

(defun ir2ri ()
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000))

(defun gripper-angle(arm angle)
  (send *robot* arm :gripper-r :joint-angle angle)
  (send *robot* arm :gripper2-r :joint-angle angle))

(defun grasp (arm)
  (gripper-angle arm
                 0)
  (send *ri* :angle-vector (send *robot* :angle-vector) 500)
  (send *ri* :wait-interpolation))

(defun release (arm)
  (gripper-angle arm 55)
  (send *ri* :angle-vector (send *robot* :angle-vector) 200)
  (send *ri* :wait-interpolation))

(defun angle(arm angle)
  (let ((angle (+ angle (if (eq arm :rarm) (+ *rwr-offset* -2) (- *lwr-offset* 5))))
	      (wr (send *robot* arm :wrist-r))
	      da n)
    (setq da (- angle (send wr :joint-angle)))
    (setq n (round (/ (abs da) 30)))
    (send wr :joint-angle angle)
    (send *ri* :angle-vector (send *robot* :angle-vector) (* n 200))
    (send *ri* :wait-interpolation)))

(defun init-pose()

  (send *robot* :init-pose)
  ;; (send *robot* :rarm :shoulder-p :joint-angle -80)
  ;; (send *robot* :larm :shoulder-p :joint-angle 80)
  ;; (send *robot* :rarm :shoulder-r :joint-angle 0)
  ;; (send *robot* :larm :shoulder-r :joint-angle 0)
  ;; (send *robot* :rarm :shoulder-y :joint-angle  45)
  ;; (send *robot* :larm :shoulder-y :joint-angle -45)
  ;; (send *robot* :rarm :elbow-p :joint-angle 0)
  ;; (send *robot* :larm :elbow-p :joint-angle 0)
  ;; (send *robot* :rarm :wrist-p :joint-angle -0)
  ;; (send *robot* :larm :wrist-p :joint-angle 0)
  ;; (send *robot* :rarm :wrist-r :joint-angle (+ 90 *rwr-offset*))
  ;; (send *robot* :larm :wrist-r :joint-angle (+ 90 *lwr-offset*))
  ;; (send *robot* :head-neck-p :joint-angle -15)

  (send *robot* :HEAD_JOINT0 :joint-angle 0.13501006364822388)
  (send *robot* :HEAD_JOINT1 :joint-angle -14.951238632202148)
  (send *robot* :LARM_JOINT0 :joint-angle 96.69376373291016)
  (send *robot* :LARM_JOINT1 :joint-angle 4.286259651184082)
  (send *robot* :LARM_JOINT2 :joint-angle -47.48624038696289)
  (send *robot* :LARM_JOINT3 :joint-angle 0.43876004219055176)
  (send *robot* :LARM_JOINT4 :joint-angle -13.3987398147583)
  (send *robot* :LARM_JOINT6 :joint-angle 30.138761520385742)
  (send *robot* :LARM_JOINT7 :joint-angle 30.138761520385742)
  (send *robot* :LLEG_JOINT0 :joint-angle 0.13501006364822388)
  (send *robot* :LLEG_JOINT1 :joint-angle -0.8099899291992188)
  (send *robot* :RARM_JOINT0 :joint-angle -97.03124237060547)
  (send *robot* :RARM_JOINT1 :joint-angle 5.535009860992432)
  (send *robot* :RARM_JOINT2 :joint-angle 45.22500991821289)
  (send *robot* :RARM_JOINT3 :joint-angle -14.782490730285645)
  (send *robot* :RARM_JOINT4 :joint-angle 31.488758087158203)
  (setq *rwr-offset* -6.648739814758301)
  (setq *lwr-offset* 15.120009422302246)
  (send *robot* :LARM_JOINT5 :joint-angle *lwr-offset*)
  (send *robot* :RARM_JOINT5 :joint-angle *rwr-offset*)
  (send *robot* :RARM_JOINT6 :joint-angle 30.341259002685547)
  (send *robot* :RARM_JOINT7 :joint-angle 30.341259002685547)
  (send *robot* :RLEG_JOINT0 :joint-angle 0.13501006364822388)
  (send *robot* :RLEG_JOINT1 :joint-angle 0.8100100755691528)


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
  (while (ros::ok)
    (ros::spin-once) ;; need to execute callbacks
    (ros::sleep)))

(defun demo()
  (kxr-init :create-viewer nil)
  (start-command-server))


(ros::rate 10)
(ros::advertise-service "~send_command" kxr_cube_solver::SendCommand #'command-callback)
(demo)
