local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AmmoHandler = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("AmmoHandler"))
local GunConfig = require(ReplicatedStorage:WaitForChild("GunSystem"):WaitForChild("GunConfig"))
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadEvent")
local AmmoUpdateEvent = ReplicatedStorage:WaitForChild("AmmoUpdateEvent")
local FireEvent = ReplicatedStorage:WaitForChild("FireEvent")

FireEvent.OnServerEvent:Connect(function(player, toolName)
    local config = GunConfig[toolName]
    if not config then return end

    local current, reserve = AmmoHandler.GetAmmo(player, toolName)
    if current <= 0 then return end

    AmmoHandler.SetAmmo(player, toolName, current - 1, reserve)
    AmmoUpdateEvent:FireClient(player, toolName, current - 1, reserve)

    -- Bullet firing logic should go here
end)

ReloadEvent.OnServerEvent:Connect(function(player, toolName)
    local config = GunConfig[toolName]
    if not config then return end

    local current, reserve = AmmoHandler.GetAmmo(player, toolName)
    if current >= config.MaxAmmo or reserve <= 0 then return end

    local needed = config.MaxAmmo - current
    local toLoad = math.min(needed, reserve)

    task.wait(config.ReloadTime)

    AmmoHandler.SetAmmo(player, toolName, current + toLoad, reserve - toLoad)
    AmmoUpdateEvent:FireClient(player, toolName, current + toLoad, reserve - toLoad)
end)
