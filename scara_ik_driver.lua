-- ArduPilot Lua SCARA Driver (v2 - Smooth Motion)
-- Controls: SCR_USER1 (X), SCR_USER2 (Y), SCR_USER3 (Z)

local param_x = Parameter("SCR_USER1")
local param_y = Parameter("SCR_USER2")
local param_z = Parameter("SCR_USER3")

local SERVO_BASE = 1
local SERVO_SHOULDER = 2
local SERVO_ELBOW = 3

-- ROBOT SETTINGS
local COXA_LEN = 30    
local FEMUR_LEN = 85   
local TIBIA_LEN = 125  

-- SMOOTHING SETTINGS
local MAX_SPEED = 2.0 -- mm per cycle (at 20Hz = 40mm/sec)
local current_x = 100 -- Start position guess
local current_y = 0
local current_z = -50

-- Helper: Slew Rate Limiter (The "Smoothing" Logic)
function move_towards(current, target, limit)
    local error = target - current
    if math.abs(error) <= limit then
        return target -- We are close enough, just snap to it
    elseif error > 0 then
        return current + limit
    else
        return current - limit
    end
end

-- Math: Inverse Kinematics
function calculate_arm_angles(x, y, z)
    local coxa_angle = math.deg(math.atan(x, y))
    local trueX = math.sqrt(x^2 + y^2) - COXA_LEN
    local dist_from_shoulder = math.sqrt(trueX^2 + z^2)

    if dist_from_shoulder > (FEMUR_LEN + TIBIA_LEN) then return nil end

    local q1 = -math.atan(z, trueX)
    local d1 = FEMUR_LEN^2 - TIBIA_LEN^2 + dist_from_shoulder^2
    local d2 = 2 * FEMUR_LEN * dist_from_shoulder
    local q2 = math.acos(d1/d2) 
    
    local femur_angle = math.deg(q1 + q2)
    local d1_tibia = FEMUR_LEN^2 - dist_from_shoulder^2 + TIBIA_LEN^2
    local d2_tibia = 2 * TIBIA_LEN * FEMUR_LEN
    local tibia_angle = math.deg(math.acos(d1_tibia/d2_tibia) - math.rad(90))

    return {coxa_angle, femur_angle, tibia_angle}
end

function update()
    -- 1. READ USER TARGETS
    -- Default to safe home position if parameters are 0
    local target_x = param_x:get() 
    if target_x == 0 then target_x = 100 end
    
    local target_y = param_y:get()
    local target_z = param_z:get()
    if target_z == 0 then target_z = -50 end

    -- 2. SMOOTH THE TRAJECTORY
    -- Instead of jumping, we step closer by MAX_SPEED
    current_x = move_towards(current_x, target_x, MAX_SPEED)
    current_y = move_towards(current_y, target_y, MAX_SPEED)
    current_z = move_towards(current_z, target_z, MAX_SPEED)

    -- 3. SOLVE IK (Use current_x, not target_x)
    local angles = calculate_arm_angles(current_x, current_y, current_z)

    if angles then
        -- 4. OUTPUT PWM
        local pwm_base     = 1000 + (angles[1] * 11.1)
        local pwm_shoulder = 1000 + (angles[2] * 11.1)
        local pwm_elbow    = 1000 + (angles[3] * 11.1)

        SRV_Channels:set_output_pwm(SERVO_BASE - 1, math.floor(pwm_base))
        SRV_Channels:set_output_pwm(SERVO_SHOULDER - 1, math.floor(pwm_shoulder))
        SRV_Channels:set_output_pwm(SERVO_ELBOW - 1, math.floor(pwm_elbow))

        -- Log occasionally (don't spam console every 50ms)
        if (millis():toint() % 1000) < 50 then
           gcs:send_text(0, string.format("Arm: X%.0f Y%.0f -> Base PWM:%.0f", current_x, current_y, pwm_base))
        end
    end

    -- Run fast (20Hz) for smooth animation
    return update, 50 
end

gcs:send_text(0, "SCARA Smooth Driver Loaded")
return update()
