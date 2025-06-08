local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local AmmoUpdateEvent = ReplicatedStorage:WaitForChild("AmmoUpdateEvent")
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadEvent")

local equippedTool = nil
local currentAmmo = 0
local reserveAmmo = 0

AmmoUpdateEvent.OnClientEvent:Connect(function(toolName, current, reserve)
    currentAmmo = current
    reserveAmmo = reserve
    local gui = player:WaitForChild("PlayerGui"):FindFirstChild("FirstPerson")
    if gui then
        local ammoLabel = gui:FindFirstChild("AmmoLabel")
        if ammoLabel then
            ammoLabel.Text = tostring(currentAmmo) .. " / " .. tostring(reserveAmmo)
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.R and equippedTool then
        ReloadEvent:FireServer(equippedTool.Name)
    end
end)
