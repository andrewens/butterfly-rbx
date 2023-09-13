local RunService = game:GetService("RunService")

--[[ SERVER ]]
--
if RunService:IsServer() then
	error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]
--
local Maid = require(script:FindFirstChild("maid"))
local AppState = require(script:FindFirstChild("app-state"))

-- rendering
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local GuiMaid = Maid()
local ScreenGui

local function initGui()
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.DisplayOrder = math.huge
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = LocalPlayer.PlayerGui
	GuiMaid(ScreenGui)

	-- test control palette
	local ButtonContainer = Instance.new("Frame")
	ButtonContainer.Parent = ScreenGui
	ButtonContainer.Size = UDim2.new(0, 400, 0, 400)
	ButtonContainer.Position = UDim2.new(0, 0, 0.5, 0)
	ButtonContainer.AnchorPoint = Vector2.new(0, 0.5)

	-- render testIndex
	local IndexLabel = Instance.new("TextLabel")
	IndexLabel.Parent = ButtonContainer
	IndexLabel.Size = UDim2.new(1, 0, 0, 50)
	IndexLabel.TextScaled = true
	IndexLabel.Font = Enum.Font.GothamBlack
	IndexLabel.Text = "ScreenGui!"

	GuiMaid(AppState:changed("testIndex", function(_, testIndex)
		IndexLabel.Text = "TestIndex: " .. testIndex
	end))

	-- control testIndex with buttons
	local LeftButton = Instance.new("TextButton")
	LeftButton.Size = UDim2.new(0.5, 0, 0, 50)
	LeftButton.TextScaled = true
	LeftButton.Position = UDim2.new(0.5, 0, 1, -50)

	LeftButton.Parent = ButtonContainer
	LeftButton.AnchorPoint = Vector2.new(1, 1)
	LeftButton.Text = "< PREV"
	LeftButton.Activated:Connect(AppState.prevTest)

	local RightButton = LeftButton:Clone()
	RightButton.Parent = ButtonContainer
	RightButton.AnchorPoint = Vector2.new(0, 1)
	RightButton.Text = "NEXT >"
	RightButton.Activated:Connect(AppState.nextTest)

	-- button brings up selection modal
	local SelectTestButton = Instance.new("TextButton")
	SelectTestButton.Parent = ButtonContainer
	SelectTestButton.Size = UDim2.new(1, 0, 0, 50)
	SelectTestButton.AnchorPoint = Vector2.new(0, 1)
	SelectTestButton.Position = UDim2.new(0, 0, 1, 0)
	SelectTestButton.TextScaled = true
	SelectTestButton.Text = "ALL TESTS"
	SelectTestButton.Activated:Connect(AppState.toggleViewAllTests)

	-- view all tests (modal)
	local ViewAllTestsMaid = Maid()
	GuiMaid(ViewAllTestsMaid)
	GuiMaid(AppState:changed("selectTestModal", function(_, viewAllTests)
		ViewAllTestsMaid:DoCleaning()
		if not viewAllTests then
			return
		end

		local Background = Instance.new("Frame")
		Background.Parent = ScreenGui
		Background.Size = UDim2.new(1, 0, 1, 0)
		ViewAllTestsMaid(Background)

		local TitleText = Instance.new("TextLabel")
		TitleText.Parent = Background
		TitleText.Size = UDim2.new(1, 0, 0, 100)
		TitleText.Position = UDim2.new(0, 0, 0, 0)
		TitleText.TextScaled = true
		TitleText.Text = "ALL TESTS"

		local TestContainer = Instance.new("ScrollingFrame")
		TestContainer.Size = UDim2.new(1, -50, 1, -200)
		TestContainer.Position = UDim2.new(0.5, 0, 1, -50)
		TestContainer.AnchorPoint = Vector2.new(0.5, 1)

		local ReturnButton = Instance.new("TextButton")
		ReturnButton.Parent = Background
		ReturnButton.Size = UDim2.new(0, 200, 0, 50)
		ReturnButton.Position = UDim2.new(0.5, 0, 1, 0)
		ReturnButton.AnchorPoint = Vector2.new(0.5, 1)
		ReturnButton.TextScaled = true
		ReturnButton.Text = "BACK"
		ReturnButton.Activated:Connect(AppState.hideAllTests)
	end))

	-- render BEGIN / END screens as modals
	local IntroMaid = Maid()
	GuiMaid(IntroMaid)
	GuiMaid(AppState:changed("testIndex", function(_, testIndex)
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
			IntroMaid(Button.Activated:Connect(AppState.nextTest))

			return
		end

		-- render END screen (returns)
		if testIndex == -1 then
			TitleText.Text = "TEST FINISHED"
			Button.Text = "< PREV"
			IntroMaid(Button.Activated:Connect(AppState.prevTest))

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
