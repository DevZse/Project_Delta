local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Active = true
local Keybind = Enum.KeyCode.P
local RenderDistance = 200

local ScreenGui = Instance.new("ScreenGui")
syn.protect_gui(ScreenGui)
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CoreGui

local TextLabel = Instance.new("TextLabel")
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0.02, 0, 0.2, 0)
TextLabel.Size = UDim2.new(0, 0, 0, 0)
TextLabel.Text = "Render Distance: " .. RenderDistance .. [[<br /><font color = "rgb(255, 0, 0)">[↓]</font> Decrease render distance by 100<br /><font color = "rgb(0, 255, 0)">[↑]</font> Increase render distance by 100<br /><font color = "rgb(255, 255, 0)">]] .. Keybind.Name .. "</font> Enable / Disable ESP (" .. (Active and "Enabled" or "Disabled") .. ")"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Font = Enum.Font.RobotoMono
TextLabel.RichText = true
TextLabel.TextSize = 20
TextLabel.TextStrokeTransparency = 0
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Parent = ScreenGui

local Cache = {
	["6B45"] = 16,
	["AS Val"] = 16,
	["ATC Key"] = 4,
	["Airfield Key"] = 6,
	["Altyn Helmet"] = 16,
	["Altyn Visor"] = 8,
	["Attak-5 60L"] = 16,
	["Bolts"] = 1,
	["Crane Key"] = 6,
	["DAGR"] = 8,
	["Duct Tape"] = 1,
	["Fast MT"] = 10,
	["Flare Gun"] = 8,
	["Fueling Station Key"] = 4,
	["Garage Key"] = 4,
	["Hammer"] = 1,
	["JPC"] = 10,
	["Lighthouse Key"] = 6,
	["M4A1"] = 12,
	["Nails"] = 1,
	["Nuts"] = 1,
	["Saiga 12"] = 8,
	["Super Glue"] = 1,
	["Village Key"] = 4,
	["Wrench"] = 1
}

local Colors = {
	[0] = Color3.fromRGB(255, 255, 255),
	[4] = Color3.fromRGB(76, 187, 23),
	[8] = Color3.fromRGB(218, 112, 214),
	[16] = Color3.fromRGB(233, 116, 81),
	[32] = Color3.fromRGB(255, 36, 0)
}

local Camera = Workspace.CurrentCamera
local Containers = Workspace:WaitForChild("Containers")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character

while true do
	if LocalPlayer.Character then
		Character = LocalPlayer.Character; break
	end
	RunService.RenderStepped:Wait()
end

local function Draw(Container)
	local Drawing = Drawing.new("Text")
	Drawing.Center = true
	Drawing.Font = 2
	Drawing.Outline = true
	Drawing.Size = 14

	local Connection;
	Connection = RunService.RenderStepped:Connect(function()
		if not Active then
			Drawing.Visible = false; return
		end

		if not Container.PrimaryPart then
			Drawing.Visible = false; return
		end

		if LocalPlayer.Character ~= Character then
			Character = LocalPlayer.Character; return
		end

		if not Character:FindFirstChild("HumanoidRootPart") then
			Drawing.Visible = false; return
		end

		if (Container.PrimaryPart.Position - Character.HumanoidRootPart.Position).Magnitude > RenderDistance then
			Drawing.Visible = false; return
		end

		local Position, Visible = Camera:WorldToViewportPoint(Container.PrimaryPart.Position)
		if not Visible then
			Drawing.Visible = false; return
		end

		local Amount = 1
		local ItemName;
		local NextSpawn = (Container:GetAttribute("NextSpawn") or 0) - os.time()
		local TotalPrice = 0
		local Value = 0

		local Color;
		local Highest = -1
		local Loot = ""

		for _, v in pairs(Container.Inventory:GetChildren()) do
			Amount = v.ItemProperties:GetAttribute("Amount") or 1
			ItemName = v.ItemProperties:GetAttribute("CallSign")
			TotalPrice += v.ItemProperties:GetAttribute("Price") or 0
			Value += (Cache[ItemName] or 0) * Amount
			Loot ..= ItemName .. " (x" .. Amount .. ")\n"
		end

		for i, v in pairs(Colors) do
			if Value >= i and i > Highest then
				Color = v
				Highest = i
			end
		end

		Drawing.Color = Color
		Drawing.Position = Vector2.new(Position.X, Position.Y)
		Drawing.Text = "$" .. TotalPrice .. "\n" .. Container:GetAttribute("DisplayName") .. (NextSpawn < 0 and "\nNot loaded" or "\n" .. Loot .. "Next Spawn: " .. NextSpawn .. "s")
		Drawing.Visible = true
	end)
end

UserInputService.InputBegan:Connect(function(Input)
	if Input.KeyCode == Keybind then
		Active = not Active
	end

	if Input.KeyCode == Enum.KeyCode.Down or Input.KeyCode == Enum.KeyCode.Up then
		RenderDistance = math.clamp(RenderDistance + (Input.KeyCode == Enum.KeyCode.Down and -100 or 100), 100, 1200)
	end

	TextLabel.Text = "Render Distance: " .. RenderDistance .. [[<br /><font color = "rgb(255, 0, 0)">[↓]</font> Decrease render distance by 100<br /><font color = "rgb(0, 255, 0)">[↑]</font> Increase render distance by 100<br /><font color = "rgb(255, 255, 0)">]] .. Keybind.Name .. "</font> Enable / Disable ESP (" .. (Active and "Enabled" or "Disabled") .. ")"
end)

for _, v in pairs(Containers:GetDescendants()) do
	if v:IsA("Model") then
		Draw(v)
	end
end

Containers.ChildAdded:Connect(Draw)
