local ProxyTable = require(script.Parent:FindFirstChild("proxy-table"))

local State = ProxyTable({
	-- control
	selectTestModal = false,
	testIndex = 0,

	-- data
	Tests = {}, -- testIndex --> function
	TestNames = {}, -- testIndex --> string
	TestResults = {}, -- testIndex --> boolean, or nil
	thisTestIsPassing = nil, -- boolean, or nil
})

-- control "testIndex"
function State.nextTest()
	State.selectTest(State.testIndex + 1)
end
function State.prevTest()
	if State.testIndex == -1 then
		State.selectTest(#State.Tests)
		return
	end
	State.selectTest(State.testIndex - 1)
end
function State.selectTest(newTestIndex)
	assert(typeof(newTestIndex) == "number" and math.floor(newTestIndex) == newTestIndex)

	if newTestIndex < 0 then -- BEGIN
		newTestIndex = 0
	end
	if newTestIndex > #State.Tests then -- END
		newTestIndex = -1
	end

	State.testIndex = newTestIndex
	State.thisTestIsPassing = State.TestResults[newTestIndex]
end

-- pass/fail tests (controls testIndex)
function State.setThisTestResult(isPassing)
	if State.testIndex < 1 then
		return
	end

	State.TestResults[State.testIndex] = isPassing
	State.thisTestIsPassing = isPassing
end
function State.clearTestResults()
	State.TestResults = {}
	State.thisTestIsPassing = nil
end
function State.passThisTest()
	State.setThisTestResult(if State.thisTestIsPassing then nil else true)
end
function State.failThisTest()
	State.setThisTestResult(if State.thisTestIsPassing == false then nil else false)
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
