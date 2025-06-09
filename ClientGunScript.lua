local GunClient = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local gunConfig = require(ReplicatedStorage:WaitForChild("GunConfig"))

-- State variables
local currentGun = nil
local currentAmmo = 0
local currentReserve = 0
local canShoot = true
local isReloading = false
local isFiring = false
local firstPersonUI = nil
local ammoLabel = nil

-- Constants
local FIRE_COOLDOWN = {}
local RELOAD_TIME = 2 -- Seconds

-- Helper to update ammo GUI
local function updateAmmoDisplay()
	if ammoLabel and currentGun then
		ammoLabel.Text = string.format("Ammo: %d / %d", currentAmmo, currentReserve)
	end
end

-- Create UI if not present
local function initUI()
	if player:WaitForChild("PlayerGui"):FindFirstChild("FirstPersonUI") then
		firstPersonUI = player.PlayerGui:FindFirstChild("FirstPersonUI")
	else
		firstPersonUI = Instance.new("ScreenGui")
		firstPersonUI.Name = "FirstPersonUI"
		firstPersonUI.ResetOnSpawn = false
		firstPersonUI.Parent = player:WaitForChild("PlayerGui")

		ammoLabel = Instance.new("TextLabel")
		ammoLabel.Size = UDim2.new(0, 200, 0, 40)
		ammoLabel.Position = UDim2.new(0.5, -100, 0.9, 0)
		ammoLabel.BackgroundTransparency = 1
		ammoLabel.TextScaled = true
		ammoLabel.TextColor3 = Color3.new(1, 1, 1)
		ammoLabel.Font = Enum.Font.SourceSansBold
		ammoLabel.Name = "AmmoDisplay"
		ammoLabel.Parent = firstPersonUI
	end

	ammoLabel = firstPersonUI:FindFirstChild("AmmoDisplay")
end

-- Create bullet effect
local function fireBullet()
	local origin = camera.CFrame.Position
	local direction = (mouse.Hit.Position - origin).Unit * 1000
	local bullet = Instance.new("Part")
	bullet.Size = Vector3.new(0.2, 0.2, 2)
	bullet.Color = Color3.new(1, 1, 0)
	bullet.Anchored = false
	bullet.CanCollide = false
	bullet.Material = Enum.Material.Neon
	bullet.CFrame = CFrame.new(origin, origin + direction)
	bullet.Velocity = direction * 2
	bullet.Parent = workspace

	game.Debris:AddItem(bullet, 3)
end

-- Reload mechanic
local function reload()
	if isReloading or not currentGun then return end
	local stats = gunConfig[currentGun]
	if currentReserve <= 0 or currentAmmo == stats.magazine then return end

	isReloading = true
	canShoot = false

	wait(RELOAD_TIME)

	local needed = stats.magazine - currentAmmo
	local taken = math.min(needed, currentReserve)
	currentAmmo += taken
	currentReserve -= taken

	isReloading = false
	canShoot = true
	updateAmmoDisplay()
end

-- Handle single shot or burst
local function shoot()
	if not currentGun or not canShoot or isReloading then return end
	local stats = gunConfig[currentGun]
	if currentAmmo <= 0 then reload() return end

	if not FIRE_COOLDOWN[currentGun] then
		FIRE_COOLDOWN[currentGun] = 0
	end

	local now = tick()
	if now - FIRE_COOLDOWN[currentGun] < (60 / stats.rpm) then return end
	FIRE_COOLDOWN[currentGun] = now

	currentAmmo -= 1
	updateAmmoDisplay()
	fireBullet()
end

-- Input loop
local function bindInput()
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isFiring = true
		elseif input.KeyCode == Enum.KeyCode.R then
			reload()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isFiring = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if isFiring and currentGun then
			local stats = gunConfig[currentGun]
			if stats.mode == "auto" then
				shoot()
			elseif stats.mode == "semi" then
				if canShoot then
					shoot()
					canShoot = false
					wait(60 / stats.rpm)
					canShoot = true
				end
			end
		end
	end)
end

-- Public API
function GunClient:SetEquippedGun(gunName)
	if not gunName then
		currentGun = nil
		if ammoLabel then ammoLabel.Text = "" end
		return
	end

	if gunConfig[gunName] then
		currentGun = gunName
		local stats = gunConfig[gunName]
		currentAmmo = stats.magazine
		currentReserve = stats.reserve
		updateAmmoDisplay()
		initUI()
	end
end

-- Initialize system
bindInput()

return GunClient
