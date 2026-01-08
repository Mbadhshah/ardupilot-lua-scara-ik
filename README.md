# ArduPilot Lua SCARA Driver (GSoC 2026 Prototype)

This is a standalone Lua implementation of a 3-DOF Inverse Kinematics (IK) solver designed for ArduPilot. 

## 🎯 The Goal
To provide a native, lightweight solution for controlling Robotic Arms (Manipulators) directly from the Flight Controller using Lua, removing the need for external companion computers (like ROS) for basic pick-and-place tasks.

## ⚙️ Features
* **Analytical IK Solver:** Implements standard geometric solutions (Law of Cosines) for 3-DOF arms.
* **Safety Clamping:** Prevents servo overdrive when targets are unreachable.
* **Zero Dependencies:** Runs entirely within the ArduPilot Lua sandbox.

## 🚀 How to Run in SITL
1.  Copy `scara_ik_driver.lua` to the `scripts/` folder of your SITL directory.
2.  Start SITL Rover: 
    ```bash
    sim_vehicle.py -v Rover --console --map
    ```
3.  Enable Scripting parameters in MAVProxy:
    ```bash
    param set SCR_ENABLE 1
    param set SCR_HEAP_SIZE 100000
    reboot
    ```
4.  Watch the console for PWM output:
    `IK Active: Tgt(52,45) -> PWM(1600, 1550, 1400)`

## 🔮 Future Roadmap (GSoC 2026)
* Refactor into a reusable `AP_Scripting/applets` library.
* Add MAVLink integration (control arm via `GLOBAL_POSITION_INT` or custom messages).
* Add S-Curve motion smoothing for fluid movement.
