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
	testIndex = 0,
	numTests = 5,
})

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

-- rendering
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiMaid = Maid()
local ScreenGui

local function initGui()
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.DisplayOrder = math.huge
	ScreenGui.Parent = LocalPlayer.PlayerGui
    GuiMaid(ScreenGui)

    -- render testIndex
	local TextLabel = Instance.new("TextLabel")
	TextLabel.Parent = ScreenGui
	TextLabel.Size = UDim2.new(1, 0, 1, 0)
	TextLabel.TextScaled = true
	TextLabel.Font = Enum.Font.GothamBlack
	TextLabel.Text = "ScreenGui!"

    GuiMaid(State:changed("testIndex", function(_, testIndex)
        TextLabel.Text = "TestIndex: " .. testIndex
    end))

    -- control testIndex with buttons
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Parent = ScreenGui
    ButtonContainer.Size = UDim2.new(0, 400, 0, 400)
    ButtonContainer.Position = UDim2.new(0, 0, 0.5, 0)
    ButtonContainer.AnchorPoint = Vector2.new(0, 0.5)

    local LeftButton = Instance.new("TextButton")
    LeftButton.Size = UDim2.new(0.5, 0, 0, 50)
    LeftButton.TextScaled = true
    LeftButton.Position = UDim2.new(0.5, 0, 1, 0)

    LeftButton.Parent = ButtonContainer
    LeftButton.AnchorPoint = Vector2.new(1, 1)
    LeftButton.Text = "< PREV"
    LeftButton.Activated:Connect(State.prevTest)

    local RightButton = LeftButton:Clone()
    RightButton.Parent = ButtonContainer
    RightButton.AnchorPoint = Vector2.new(0, 1)
    RightButton.Text = "NEXT >"
    RightButton.Activated:Connect(State.nextTest)

    -- render BEGIN / END screens as modals
    local IntroMaid = Maid()
    GuiMaid(IntroMaid)
    GuiMaid(State:changed("testIndex", function(_, testIndex)
        IntroMaid:DoCleaning()

        -- do nothing if normal test
        if testIndex > 0 then
            return
        end

        local Background = Instance.new("Frame")
        Background.Parent = ScreenGui
        Background.Size = UDim2.new(1, 0, 1, 0)
        IntroMaid(Background)

        local TitleText = Instance.new("TextLabel")
        TitleText.Parent = Background
        TitleText.Size = UDim2.new(1, 0, 0, 100)
        TitleText.Position = UDim2.new(0, 0, 0, 0)
        TitleText.TextScaled = true

        local Button = Instance.new("TextButton")
        Button.Parent = Background
        Button.Size = UDim2.new(0, 200, 0, 50)
        Button.Position = UDim2.new(0.5, 0, 1, 0)
        Button.AnchorPoint = Vector2.new(0.5, 1)
        Button.TextScaled = true

        --[[
            TODO -- change in progress

            Render BEGIN and END screens that say "begin" and "end" 
            and have buttons...

            BEGIN has a "begin" button.
            END has a "prev" button.
        ]]

        -- render BEGIN screen (returns)
        if testIndex == 0 then
            TitleText.Text = "TEST INTRO"
            Button.Text = "BEGIN"
            IntroMaid(Button.Activated:Connect(State.nextTest))

            return
        end

        -- render END screen (returns)
        if testIndex == -1 then
            TitleText.Text = "TEST FINISHED"
            Button.Text = "< PREV"
            IntroMaid(Button.Activated:Connect(State.prevTest))

            return
        end
    end))

	return GuiMaid
end

-- variables
local ButterflyMaid = Maid()

-- public
local butterfly = {}

function butterfly.run()
	ButterflyMaid(initGui())
	return ButterflyMaid
end
function butterfly.stop()
	ButterflyMaid:DoCleaning()
end

return butterfly
