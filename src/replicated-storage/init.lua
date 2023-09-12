local RunService = game:GetService("RunService")

--[[ SERVER ]]
--
if RunService:IsServer() then
	error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]
--
local ProxyTable = require(script:FindFirstChild("proxy-table"))
local Maid = require(script:FindFirstChild("maid"))

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

	if newTestIndex < 0 then -- BEGIN
		newTestIndex = 0
	end
	if newTestIndex > State.numTests then -- END
		newTestIndex = -1
	end

	State.testIndex = newTestIndex
end

-- rendering
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiMaid = Maid()
local ScreenGui

local function initGui()
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.DisplayOrder = math.huge
	ScreenGui.Parent = LocalPlayer.PlayerGui

	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = ScreenGui
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.GothamBlack
	TextLabel.Text = "ScreenGui!"

	GuiMaid(ScreenGui)

	return GuiMaid
end
local function renderUpdate(testIndex) end

-- variables
local ButterflyMaid = Maid()

-- public
local butterfly = {}

function butterfly.run()
	ButterflyMaid(initGui())
	ButterflyMaid(State:changed("testIndex", function(_, testIndex)
		renderUpdate(testIndex)
	end))

	return ButterflyMaid
end
function butterfly.stop()
	ButterflyMaid:DoCleaning()
end

return butterfly
