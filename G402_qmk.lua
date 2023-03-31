-- This idea of using layers is inspired by qmk

-- GPL2 license (may change at some point)
-- Copyright 2023 mbartlett21
-- Original repo: https://github.com/mbartlett21/logitech

-- This is for a G402 mouse with 8 buttons
--[[

left:
  _
 / 8
|  7
|6 |)
| 5|
| 4|
|  |
| /
|/
]]

local MOUSE_BUTTON_COUNT = 8

local MB_LFT = 1
local MB_RGT = 3 -- oddly, these are swapped for output
local MB_MID = 2
local MB_X1  = 4
local MB_X2  = 5

local ______ = nil
local MB_NON = 0


-- begin setup


local KB_PST = { ty = 'shortcut', 'lctrl', 'v' }
local KB_CPY = { ty = 'shortcut', 'lctrl', 'c' }
local KB_CUT = { ty = 'shortcut', 'lctrl', 'x' }

local GU_LFT = { ty = 'shortcut', 'lgui', MB_LFT }
local GU_RGT = { ty = 'shortcut', 'lgui', MB_RGT }
local GU_MID = { ty = 'shortcut', 'lgui', MB_MID }

local function MO(layer)
    return {
        ty = 'mo',
        layer = layer,
    }
end

local function TO(layer)
    return {
        ty = 'to',
        layer = layer,
    }
end

local clickmaps = {
    -- left, right and mid are programmed in g hub
    { ______, ______, ______, KB_PST, KB_CPY, MO(2),  MB_NON, MB_NON },
    { ______, ______, ______, ______, KB_CUT, ______, TO(3),  GU_LFT },
    { ______, ______, ______, GU_MID, GU_LFT, MO(4),  TO(1),  GU_RGT },
    { ______, ______, ______, ______, ______, ______, ______, ______ }
}


-- end setup


local curr_pressed = {}

local curr_layers = { true }

local function get_code(id)
    for i = #clickmaps, 1, -1 do
        -- OutputLogMessage('i == ' .. i .. '\n')
        if curr_layers[i] or i == 1 then -- can't turn off default layer
            -- OutputLogMessage('checking layer ' .. i .. '\n')
            if clickmaps[i][id] then
                return clickmaps[i][id]
            end
        end
    end
    return MB_NON
end

local interpret_down, interpret_up

local function release_other_codes(code)
    for i = 1, MOUSE_BUTTON_COUNT do
        if curr_pressed[i] and get_code(i) ~= code then
            -- release other keys
            curr_pressed[i] = nil
            interpret_up(get_code(i))
        end
    end
end

interpret_down = function(code)
    if type(code) == 'number' then
        if code >= MB_LFT and code <= MB_X1 then
            -- OutputLogMessage('PressMouseButton ' .. code .. '\n')
            PressMouseButton(code)
        elseif code > MB_X1 then
            -- probably a keycode
            -- OutputLogMessage('PressKey ' .. code .. '\n')
            PressKey(code)
        end
    elseif type(code) == 'table' then
        if code.ty == 'shortcut' then
            for i, v in ipairs(code) do
                interpret_down(v)
            end
        elseif code.ty == 'mo' then
            release_other_codes(code)

            curr_layers[code.layer] = true
        elseif code.ty == 'to' then
            release_other_codes(code)

            for i = 2, #clickmaps do
                curr_layers[i] = nil
            end
            curr_layers[code.layer] = true
        end
    elseif type(code) == 'string' then
        -- OutputLogMessage('PressKey ' .. code .. '\n')
        PressKey(code)
    end
end

interpret_up = function(code)
    if type(code) == 'number' then
        if code >= MB_LFT and code <= MB_X1 then
            -- OutputLogMessage('ReleaseMouseButton ' .. code .. '\n')
            ReleaseMouseButton(code)
        elseif code > MB_X1 then
            -- probably a keycode
            -- OutputLogMessage('ReleaseKey ' .. code .. '\n')
            ReleaseKey(code)
        end
    elseif type(code) == 'table' then
        if code.ty == 'shortcut' then
            for i, v in ipairs(code) do
                interpret_up(v)
            end
        elseif code.ty == 'mo' then
            release_other_codes(code)

            curr_layers[code.layer] = nil
        elseif code.ty == 'to' then
            -- do nothing
        end
    elseif type(code) == 'string' then
        -- OutputLogMessage('ReleaseKey ' .. code .. '\n')
        ReleaseKey(code)
    end
end

local function pretty_code(code)
    if type(code) == 'table' then
        local s = '{'
        for k, v in pairs(code) do
            if s ~= '{' then
                s = s .. ', '
            end
            s = s .. k .. ' = ' .. v
        end
        return s .. '}'
    else
        return code
    end
end

-- Hook to Logitech
function OnEvent(event, arg)
    -- OutputLogMessage('Event: ' .. event .. ', Arg: ' .. arg .. '\n')
    if event == 'MOUSE_BUTTON_PRESSED' then
        if curr_pressed[arg] then
            return
        end
        curr_pressed[arg] = true

        local code = get_code(arg)
        -- OutputLogMessage('Code: ' .. pretty_code(code) .. '\n')
        interpret_down(code)
    elseif event == 'MOUSE_BUTTON_RELEASED' then
        if not curr_pressed[arg] then
            return
        end
        curr_pressed[arg] = nil

        local code = get_code(arg)
        -- OutputLogMessage('Code: ' .. pretty_code(code) .. '\n')
        interpret_up(code)
    end
end
