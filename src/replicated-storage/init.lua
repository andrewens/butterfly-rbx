local RunService = game:GetService("RunService")

--[[ SERVER ]]--
if RunService:IsServer() then
    error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]--
local butterfly = {}

function butterfly.run(...)
    print("Hello world")
end

return butterfly

