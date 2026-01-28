# ArduPilot Lua SCARA Solver

This is a standalone Lua script to test Inverse Kinematics (IK) for 3-DOF robotic arms in ArduPilot.

## The Problem
Currently, if you want to control a robotic arm with XYZ coordinates in ArduPilot, you need a companion computer (like a Raspberry Pi) running ROS.

## My Solution
I wrote this script to solve the Inverse Kinematics directly on the Flight Controller using Lua. It calculates the angles for the Base, Shoulder, and Elbow servos based on a target XYZ position.

## Current Status
* **Math:** Implements 3-DOF Analytical IK (Law of Cosines).
* **Safety:** Clamps PWM values if the target is out of reach.
* **Testing:** Works in SITL Rover.

## How to Run in SITL
1. Copy the script to the scripts folder:
   `cp scara_ik_driver.lua ~/ardupilot/Rover/scripts/`
2. Run the Rover simulation:
   `../Tools/autotest/sim_vehicle.py -v Rover --console --map`
3. Enable Scripting in MAVProxy:
   `param set SCR_ENABLE 1`
   `reboot`
4. **Move the Arm:**
   Set the Target X coordinate (in mm) using the User Parameter:
   `param set SCR_USER1 150`
   
   (SCR_USER1 = X, SCR_USER2 = Y, SCR_USER3 = Z)
