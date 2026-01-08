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

## How to Run
1.  Put `scara_ik_driver.lua` in your `ardupilot/scripts/` folder.
2.  Run SITL: `sim_vehicle.py -v Rover --console --map`
3.  Enable scripting in MAVProxy:
    * `param set SCR_ENABLE 1`
    * `param set SCR_HEAP_SIZE 100000`
    * `reboot`
4.  You will see PWM outputs in the console window.

## Future Plans (GSoC 2026)
I plan to turn this into a standard library in `AP_Scripting/applets` and add MAVLink support so users can control the arm from a Ground Station.
