# ArduPilot Lua SCARA Solver

This is a standalone Lua script to test Inverse Kinematics (IK) for 3-DOF robotic arms directly within ArduPilot.

## The Problem
Currently, controlling a robotic arm using Cartesian (XYZ) coordinates in ArduPilot usually requires a heavy companion computer (like a Raspberry Pi) running ROS to handle the kinematics.

## The Solution
This script solves the Inverse Kinematics **directly on the Flight Controller** using Lua. It calculates the required angles for the Base, Shoulder, and Elbow servos based on a target XYZ position provided via MAVLink.

## Current Status
* **Math:** Implements 3-DOF Analytical IK (Law of Cosines).
* **Control:** Maps standard MAVLink parameters (`SCR_USERx`) to arm coordinates.
* **Safety:** Includes reachability checks (clamps if target is out of range).
* **Testing:** Verified in SITL Rover.

## How to Run in SITL

### 1. Install the Script
Copy the script to your vehicle's scripts folder:
```bash
cp scara_ik_driver.lua ~/ardupilot/Rover/scripts/

```

### 2. Start Simulation

Run the Rover simulator with the console enabled:

```bash
../Tools/autotest/sim_vehicle.py -v Rover --console --map

```

### 3. Enable Scripting

In the MAVProxy console, type:

```bash
param set SCR_ENABLE 1
reboot

```

### 4. Move the Arm

The arm listens to the `SCR_USER` parameters (in millimeters):

* `SCR_USER1` = **X** (Forward/Back)
* `SCR_USER2` = **Y** (Left/Right)
* `SCR_USER3` = **Z** (Up/Down)

Example command to move the arm 150mm forward:

```bash
param set SCR_USER1 150

```

### 5. Monitor Output

Watch the MAVProxy console for status messages:

> `AP: Arm: Tgt(150,0) -> PWM Base:1xxx`

## Hardware Pinout

* **Servo 1:** Base Joint
* **Servo 2:** Shoulder Joint
* **Servo 3:** Elbow Joint

```

```
