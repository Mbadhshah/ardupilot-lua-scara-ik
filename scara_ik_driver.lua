-- ArduPilot Lua SCARA Inverse Kinematics Driver (Prototype)
-- GSoC 2026 Proposal Concept
-- Author: Muhammed Badhshah

local SERVO_BASE = 1
local SERVO_SHOULDER = 2
local SERVO_ELBOW = 3

-- Arm Dimensions (mm) - Conceptual SCARA/Arm
local COXA_LEN = 30    
local FEMUR_LEN = 85   
local TIBIA_LEN = 125  

function calculate_arm_angles(x, y, z)
  
    local coxa_angle = math.deg(math.atan(x, y))

    local trueX = math.sqrt(x^2 + y^2) - COXA_LEN
    local dist_from_shoulder = math.sqrt(trueX^2 + z^2)

    if dist_from_shoulder > (FEMUR_LEN + TIBIA_LEN) then
        return nil -- Target out of reach
    end

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

local radius = 30
local center_x = 50
local center_y = 50
local z_height = -50
local phase = 0

function update()

    phase = phase + 0.1
    local target_x = center_x + (math.cos(phase) * radius)
    local target_y = center_y + (math.sin(phase) * radius)
    
    local angles = calculate_arm_angles(target_x, target_y, z_height)
    
    if angles then

        local pwm_base = 1500 + (angles[1] * 10)
        local pwm_shoulder = 1500 + (angles[2] * 10)
        local pwm_elbow = 1500 + (angles[3] * 10)


        pwm_base = math.max(1000, math.min(2000, pwm_base))
        pwm_shoulder = math.max(1000, math.min(2000, pwm_shoulder))
        pwm_elbow = math.max(1000, math.min(2000, pwm_elbow))

        SRV_Channels:set_output_pwm(SERVO_BASE - 1, math.floor(pwm_base))
        SRV_Channels:set_output_pwm(SERVO_SHOULDER - 1, math.floor(pwm_shoulder))
        SRV_Channels:set_output_pwm(SERVO_ELBOW - 1, math.floor(pwm_elbow))

        gcs:send_text(0, string.format("IK Active: Tgt(%.0f,%.0f) -> PWM(%.0f, %.0f, %.0f)", target_x, target_y, pwm_base, pwm_shoulder, pwm_elbow))
    else
        gcs:send_text(0, "IK Error: Target Unreachable")
    end

    return update, 100 
end

gcs:send_text(0, "Lua SCARA Driver Loaded")
return update()
