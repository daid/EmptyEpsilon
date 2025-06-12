
__random_callsign_index = 1
__random_callsign_prefix_length = 0
__random_callsign_prefix_pool = {}
function generateRandomCallSign(prefix)
    if prefix == nil then
        if #__random_callsign_prefix_pool < 1 then
            __random_callsign_prefix_length = __random_callsign_prefix_length + 1
            for i=1,26 do
                table.insert(__random_callsign_prefix_pool, string.char(i+64))
            end
            for i = 2, __random_callsign_prefix_length do
                local new_pool = {}
                for _, a in ipairs(__random_callsign_prefix_pool) do
                    for i=1,26 do
                        table.insert(new_pool, a .. string.char(i+64))
                    end
                end
                __random_callsign_prefix_pool = new_pool
            end
        end
        local prefix_index = math.random(1,#__random_callsign_prefix_pool)
        prefix = __random_callsign_prefix_pool[prefix_index]
        table.remove(__random_callsign_prefix_pool, prefix_index)
    end
    __random_callsign_index = __random_callsign_index + irandom(1, 3)
    if __random_callsign_index > 999 then
        __random_callsign_index = __random_callsign_index - 999
    end
    return string.format("%s%i", prefix, __random_callsign_index)
end
