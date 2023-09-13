local ProxyTable = require(script.Parent:FindFirstChild("proxy-table"))

local State = ProxyTable({
	selectTestModal = false,
	testIndex = 0,
	numTests = 5,
})

-- control "testIndex"
function State.nextTest()
	State.selectTest(State.testIndex + 1)
end
function State.prevTest()
	if State.testIndex == -1 then
		State.selectTest(State.numTests)
		return
	end
	State.selectTest(State.testIndex - 1)
end
function State.selectTest(newTestIndex)
	assert(typeof(newTestIndex) == "number" and math.floor(newTestIndex) == newTestIndex)

	if newTestIndex < 0 then -- BEGIN
		newTestIndex = 0
	end
	if newTestIndex > State.numTests then -- END
		newTestIndex = -1
	end

	State.testIndex = newTestIndex
end

-- control "selectTestModal"
function State.viewAllTests()
	State.selectTestModal = true
end
function State.hideAllTests()
	State.selectTestModal = false
end
function State.toggleViewAllTests()
	State.selectTestModal = not State.selectTestModal
end

return State
