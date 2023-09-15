--[[ SERVER ]]
local RunService = game:GetService("RunService")
if RunService:IsServer() then
	error("Attempt to require butterfly on the server")
end

--[[ CLIENT ]]
local Maid = require(script:FindFirstChild("maid"))
local AppState = require(script:FindFirstChild("app-state"))

-- private
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

	-- render testIndex & testName
	local IndexLabel = Instance.new("TextLabel")
	IndexLabel.Parent = ButtonContainer
	IndexLabel.Size = UDim2.new(1, 0, 0, 50)
	IndexLabel.TextScaled = true
	IndexLabel.Font = Enum.Font.GothamBlack

	local DescLabel = IndexLabel:Clone()
	DescLabel.Parent = ButtonContainer
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.Position = UDim2.new(0, 0, 0, 50)
	DescLabel.Size = UDim2.new(1, 0, 0, 200)
	DescLabel.TextYAlignment = Enum.TextYAlignment.Top
	DescLabel.TextSize = 30
	DescLabel.TextScaled = false

	GuiMaid(AppState:changed("testIndex", function(_, testIndex)
		IndexLabel.Text = " Test #" .. testIndex .. "/" .. #AppState.Tests
		DescLabel.Text = (AppState.TestNames[testIndex] or "")
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

	-- pass/fail this test
	local PassButton = LeftButton:Clone()
	PassButton.Parent = ButtonContainer
	PassButton.AnchorPoint = Vector2.new(1, 1)
	PassButton.Position = UDim2.new(0.5, 0, 1, -100)
	PassButton.TextColor3 = Color3.new(1, 1, 1)
	PassButton.Activated:Connect(AppState.passThisTest)

	local FailButton = RightButton:Clone()
	FailButton.Parent = ButtonContainer
	FailButton.Position = UDim2.new(0.5, 0, 1, -100)
	FailButton.AnchorPoint = Vector2.new(0, 1)
	FailButton.TextColor3 = Color3.new(1, 1, 1)
	FailButton.Activated:Connect(AppState.failThisTest)

	GuiMaid(AppState:changed("thisTestIsPassing", function(_, isPassing)
		-- font
		local font = if isPassing == nil then Enum.Font.GothamBold else Enum.Font.Gotham
		PassButton.Font = font
		FailButton.Font = font

		-- text
		PassButton.Text = if isPassing == true then "PASSING" else "PASS"
		FailButton.Text = if isPassing == false then "FAILING" else "FAIL"

		-- background color
		if isPassing == nil then
			PassButton.BackgroundColor3 = Color3.new(0, 1, 0)
			FailButton.BackgroundColor3 = Color3.new(1, 0, 0)

			return
		end

		PassButton.BackgroundColor3 = if isPassing then Color3.new(0, 0.8, 0) else Color3.new(0.5, 0.6, 0.5)
		FailButton.BackgroundColor3 = if not isPassing then Color3.new(0.8, 0, 0) else Color3.new(0.6, 0.5, 0.5)
	end))

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

		-- main elements
		local TitleText = Instance.new("TextLabel")
		TitleText.Parent = Background
		TitleText.Size = UDim2.new(1, 0, 0, 100)
		TitleText.Position = UDim2.new(0, 0, 0, 0)
		TitleText.TextScaled = true
		ModalMaid(AppState:changed("Tests", function(_, Tests)
			TitleText.Text = "All tests (" .. #Tests .. ")"
		end))

		local SubtitleText = TitleText:Clone()
		SubtitleText.Parent = Background
		SubtitleText.Size = UDim2.new(1, 0, 0, 50)
		SubtitleText.Position = UDim2.new(0, 0, 0, 100)
		ModalMaid(AppState:changed("testIndex", function(_, testIndex)
			SubtitleText.Text = "Currently Testing #" .. testIndex
		end))

		local ReturnButton = Instance.new("TextButton")
		ReturnButton.Parent = Background
		ReturnButton.Size = UDim2.new(0, 200, 0, 50)
		ReturnButton.Position = UDim2.new(0.5, 0, 1, 0)
		ReturnButton.AnchorPoint = Vector2.new(0.5, 1)
		ReturnButton.TextScaled = true
		ReturnButton.Text = "BACK"
		ReturnButton.Activated:Connect(AppState.hideAllTests)

		-- render every test
		local TestContainer = Instance.new("ScrollingFrame")
		TestContainer.Parent = Background
		TestContainer.Size = UDim2.new(1, -100, 1, -220)
		TestContainer.Position = UDim2.new(0.5, 0, 1, -70)
		TestContainer.AnchorPoint = Vector2.new(0.5, 1)
		TestContainer.CanvasSize = UDim2.new(0, 0, 0, #AppState.Tests * 40)

		local ListLayout = Instance.new("UIListLayout")
		ListLayout.Parent = TestContainer
		for testIndex, testName in pairs(AppState.TestNames) do
			local TestButton = Instance.new("TextButton")
			TestButton.Parent = TestContainer
			TestButton.LayoutOrder = testIndex
			TestButton.TextXAlignment = Enum.TextXAlignment.Left
			TestButton.TextScaled = true
			TestButton.Size = UDim2.new(1, 0, 0, 40)
			TestButton.Activated:Connect(function()
				AppState.selectTest(testIndex)
			end)

			ModalMaid(AppState:changed("testIndex", function(_, currentTestIndex)
				-- color
				TestButton.BackgroundColor3 = if currentTestIndex == testIndex
					then Color3.fromRGB(200, 200, 200)
					else Color3.fromRGB(163, 162, 165)

				-- text
				local testIsPassing = AppState.TestResults[testIndex]
				local testResultText = if testIsPassing ~= nil
					then (if testIsPassing
						then '  <font color="#00FF00">PASSING</font>'
						else '  <font color="#FF0000">FAILING</font>')
					else ""
				local currentTestText = if currentTestIndex == testIndex then "  ← current" else ""
				TestButton.RichText = true
				TestButton.Text = "#" .. testIndex .. ": " .. testName .. testResultText .. currentTestText
			end))
		end
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

local function extractTests(Instances, TestFunctions, TestNames)
	--[[
		Compiles list of test functions & list of test names from ModuleScripts,
		given an array of Instances.
		TestFunctions & TestNames are indexed by integers.
		ModuleScripts must return a function to be added to the list.
	]]

	for _, ModuleScript in pairs(Instances) do
		-- must be a .spec file & return a function
		local index = string.find(ModuleScript.Name, ".spec")
		if ModuleScript:IsA("ModuleScript") and index then
			local testFunc = require(ModuleScript)
			if typeof(testFunc) ~= "function" then
				continue
			end
			table.insert(TestFunctions, testFunc)

			-- save the file name, but without the .spec
			local testName = string.sub(ModuleScript.Name, 1, index - 1)
			table.insert(TestNames, testName)
		end
		extractTests(ModuleScript:GetChildren(), TestFunctions, TestNames)
	end
end
local function initTestRunner()
	--[[
		Run the test module of the given testIndex when it changes
	]]
	local TestMaid = Maid()
	local GuiMaid = Maid()
	GuiMaid(TestMaid)
	GuiMaid(AppState:changed("testIndex", function(_, testIndex)
		TestMaid:DoCleaning()

		-- there are no tests at testIndex=0 or testIndex=-1
		local testFunction = AppState.Tests[testIndex]
		if testFunction == nil then
			return
		end

		-- tests can return a Maid or function to cleanup the test
		local cleanupTest = testFunction()
		if cleanupTest then
			TestMaid(cleanupTest)
		end
	end))

	return GuiMaid
end

-- public
local ButterflyMaid = Maid()
local butterfly = {}

function butterfly.run(TestContainers)
	assert(typeof(TestContainers) == "table")
	extractTests(TestContainers, AppState.Tests, AppState.TestNames)
	AppState.clearTestResults()

	-- temporary player gui lookup -- this should be specified by params of this method.
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	ButterflyMaid(initGui(LocalPlayer.PlayerGui))
	ButterflyMaid(initTestRunner())

	return ButterflyMaid
end
function butterfly.stop()
	ButterflyMaid:DoCleaning()
end

return butterfly
