local RunService = game:GetService("RunService")

--[[ SERVER ]]
--
if RunService:IsServer() then
	error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]
--
local ProxyTable = require(script:FindFirstChild("proxy-table"))

-- state
local State = ProxyTable({
	selectionModal = false,
	testIndex = 1,
	numTests = 2,
})

function State.nextTest()
	State.selectTest(State.testIndex + 1)
end
function State.prevTest()
	State.selectTest(State.testIndex - 1)
end
function State.selectTest(newTestIndex)
	assert(typeof(newTestIndex) == "number" and math.floor(newTestIndex) == newTestIndex)

	if newTestIndex < 0 then  -- BEGIN
		newTestIndex = 0
	end
	if newTestIndex > State.numTests then  -- END
		newTestIndex = -1
	end

	State.testIndex = newTestIndex
end

-- public
local butterfly = {}

function butterfly.run()
	
end

return butterfly
