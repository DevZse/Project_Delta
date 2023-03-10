local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");

local Cache = {
	["6B45"] = 16,
	["ATC Key"] = 4,
	["Altyn Helmet"] = 16,
	["Defense Advanced GPS Receiver"] = 8,
	["Duct Tape"] = 1,
	["Factory Garage Key"] = 4,
	["Flare Gun"] = 8,
	["Fueling Station Office Key"] = 4,
	["Hammer"] = 1,
	["Metal Nails"] = 1,
	["Metal Nuts"] = 1,
	["Super Glue"] = 1,
	["Village Key"] = 4,
	["Wrench"] = 1
};

local Colors = {
	[0] = Color3.fromRGB(255, 255, 255),
	[4] = Color3.fromRGB(135, 206, 235),
	[8] = Color3.fromRGB(233, 116, 81),
	[16] = Color3.fromRGB(218, 112, 214),
	[32] = Color3.fromRGB(76, 187, 23)
};

local Active = true;
local Keybind = Enum.KeyCode.P;
local RenderDistance = 200;

local Camera = Workspace.CurrentCamera;
local Containers = Workspace:WaitForChild("Containers");

local LocalPlayer = Players.LocalPlayer;
local Character = LocalPlayer.Character;

while true do
	if LocalPlayer.Character then
		Character = LocalPlayer.Character; break
	end
	RunService.RenderStepped:Wait()
end;

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
		local TotalPrice = 0
		local Value = 0

		local Color;
		local Highest = -1
		local Loot = ""

		for _, v in pairs(Container.Inventory:GetChildren()) do
			Amount = v.ItemProperties:GetAttribute("Amount") or 1
			ItemName = v.ItemProperties:GetAttribute("ItemName")
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
		Drawing.Position = Vector2.new(Position.X, Position.Y, Position.Z)
		Drawing.Text = "$" .. TotalPrice .. "\n" .. Container:GetAttribute("DisplayName") .. "\n" .. Loot
		Drawing.Visible = true
	end)
end;

UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
	if GameProcessedEvent then
		return
	end

	if Input.KeyCode == Keybind then
		Active = not Active
	end
end);

for _, v in pairs(Containers:GetDescendants()) do
	if v:IsA("Model") then
		Draw(v)
	end
end;

Containers.ChildAdded:Connect(Draw);
