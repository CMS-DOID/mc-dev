local GunServer = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GunConfig = require(ReplicatedStorage:WaitForChild("GunConfig"))
local FireEvent = ReplicatedStorage:WaitForChild("FireEvent") -- RemoteEvent
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadEvent") -- RemoteEvent

-- Anti-spam fire delay tracker
local lastFired = {}

-- Helper function to apply damage
local function applyDamage(target, damage, shooter)
	if target and target:IsA("Humanoid") and target.Health > 0 then
		target:TakeDamage(damage)

		-- Optional: Tag for kill credit
		local creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = shooter
		creator.Parent = target
		Debris:AddItem(creator, 1)
	end
end

-- Create visual bullet hit effect
local function createHitEffect(position)
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.2, 0.2, 0.2)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.BrickColor = BrickColor.Red()
	part.Material = Enum.Material.Neon
	part.Name = "HitEffect"
	part.Parent = workspace

	Debris:AddItem(part, 0.3)
end

-- Handle remote fire call
FireEvent.OnServerEvent:Connect(function(player, gunName, origin, direction)
	if not gunName or not GunConfig[gunName] then return end
	local now = tick()
	local fireRate = 60 / GunConfig[gunName].rpm
	lastFired[player] = lastFired[player] or 0
	if now - lastFired[player] < fireRate then return end
	lastFired[player] = now

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {player.Character}
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local result = workspace:Raycast(origin, direction.Unit * 1000, rayParams)

	if result then
		local hitPart = result.Instance
		local hitHumanoid = hitPart:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid")
		if hitHumanoid then
			applyDamage(hitHumanoid, GunConfig[gunName].damage, player)
		end
		createHitEffect(result.Position)
	end
end)

-- Optional reload sync logic
ReloadEvent.OnServerEvent:Connect(function(player, gunName)
	if not gunName or not GunConfig[gunName] then return end
	-- Server-side reload logic, if needed
	-- Mostly handled client-side unless you want to verify ammo
end)

return GunServer
