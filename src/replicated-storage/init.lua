--[[ SERVER ]]
local RunService = game:GetService("RunService")
if RunService:IsServer() then
	error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]
local Maid = require(script:FindFirstChild("maid"))
local AppState = require(script:FindFirstChild("app-state"))

local function initTestController(ScreenGui)
	--[[
		Users use the TestController to label a test as "PASSED" or "FAILED"
		and also move between tests
	]]

	-- test control palette
	local ButtonContainer = Instance.new("Frame")
	ButtonContainer.Parent = ScreenGui
	ButtonContainer.Size = UDim2.new(0, 400, 0, 400)
	ButtonContainer.Position = UDim2.new(0, 0, 0.5, 0)
	ButtonContainer.AnchorPoint = Vector2.new(0, 0.5)

	local GuiMaid = Maid()
	GuiMaid(ButtonContainer)

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

	return GuiMaid
end
local function initTestSelectionModal(ScreenGui)
	--[[
		TestSelection modal shows list of all tests & lets user goto any of them
		It pops up when AppState.selectTestModal is true
	]]

	local ModalMaid = Maid()
	local GuiMaid = Maid()
	GuiMaid(ModalMaid)
	GuiMaid(AppState:changed("selectTestModal", function(_, viewAllTests)
		ModalMaid:DoCleaning()
		if not viewAllTests then
			return
		end

		local Background = Instance.new("Frame")
		Background.Parent = ScreenGui
		Background.Size = UDim2.new(1, 0, 1, 0)
		ModalMaid(Background)

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

	return GuiMaid
end
local function initBookEndScreens(ScreenGui)
	--[[
		BookEnd screens are the Intro screen at the beginning and End screen at the end.
		They come up when AppState.testIndex == 0 or AppState.testIndex == -1 (signifies the end).
	]]

	local ModalMaid = Maid()
	local GuiMaid = Maid()
	GuiMaid(ModalMaid)
	GuiMaid(AppState:changed("testIndex", function(_, testIndex)
		ModalMaid:DoCleaning()

		-- do nothing if normal test
		if testIndex > 0 then
			return
		end

		local Background = Instance.new("Frame")
		Background.Parent = ScreenGui
		Background.Size = UDim2.new(1, 0, 1, 0)
		ModalMaid(Background)

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

		-- render BEGIN screen (returns)
		if testIndex == 0 then
			TitleText.Text = "TEST INTRO"
			Button.Text = "BEGIN"
			ModalMaid(Button.Activated:Connect(AppState.nextTest))

			return
		end

		-- render END screen (returns)
		if testIndex == -1 then
			TitleText.Text = "TEST FINISHED"
			Button.Text = "< PREV"
			ModalMaid(Button.Activated:Connect(AppState.prevTest))

			return
		end
	end))

	return GuiMaid
end
local function initGui(GuiContainer)
	--[[
		Initialize butterfly's User Interface in the given GuiContainer parent.
		Currently only supports PlayerGuis.
	]]

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.DisplayOrder = math.huge
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = GuiContainer

	local GuiMaid = Maid()
	GuiMaid(ScreenGui)
	GuiMaid(initTestController(ScreenGui))
	GuiMaid(initTestSelectionModal(ScreenGui))
	GuiMaid(initBookEndScreens(ScreenGui))

	return GuiMaid
end

-- public
local ButterflyMaid = Maid()
local butterfly = {}

function butterfly.run()
	-- temporary player gui lookup -- this should be specified by params of this method.
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	ButterflyMaid(initGui(LocalPlayer.PlayerGui))
	return ButterflyMaid
end
function butterfly.stop()
	ButterflyMaid:DoCleaning()
end

return butterfly
