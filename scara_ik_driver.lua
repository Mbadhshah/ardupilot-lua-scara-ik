-- ArduPilot Lua SCARA Driver
-- Controls: SCR_USER1 (X), SCR_USER2 (Y), SCR_USER3 (Z)

local param_x = Parameter("SCR_USER1")
local param_y = Parameter("SCR_USER2")
local param_z = Parameter("SCR_USER3")

local SERVO_BASE = 1
local SERVO_SHOULDER = 2
local SERVO_ELBOW = 3

-- Arm Dimensions (mm)
local COXA_LEN = 30    
local FEMUR_LEN = 85   
local TIBIA_LEN = 125  

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
    local target_x = param_x:get() or 100
    local target_y = param_y:get() or 0
    local target_z = param_z:get() or -50

    local angles = calculate_arm_angles(target_x, target_y, target_z)

    if angles then
        local pwm_base     = 1000 + (angles[1] * 10)
        local pwm_shoulder = 1000 + (angles[2] * 10)
        local pwm_elbow    = 1000 + (angles[3] * 10)

        SRV_Channels:set_output_pwm(SERVO_BASE - 1, math.floor(pwm_base))
        SRV_Channels:set_output_pwm(SERVO_SHOULDER - 1, math.floor(pwm_shoulder))
        SRV_Channels:set_output_pwm(SERVO_ELBOW - 1, math.floor(pwm_elbow))

        gcs:send_text(0, string.format("Arm: Tgt(%.0f,%.0f) -> PWM Base:%.0f", target_x, target_y, pwm_base))
    else
        gcs:send_text(4, "Arm Error: Target Unreachable")
    end
    return update, 1000
end

gcs:send_text(0, "SCARA Driver Loaded")
return update()
