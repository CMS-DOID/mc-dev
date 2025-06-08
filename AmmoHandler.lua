local AmmoHandler = {}
local ammoData = {}

function AmmoHandler.InitPlayer(player)
    ammoData[player.UserId] = {}
end

function AmmoHandler.RemovePlayer(player)
    ammoData[player.UserId] = nil
end

function AmmoHandler.GetAmmo(player, gun)
    if not ammoData[player.UserId] then return 0, 0 end
    local gunAmmo = ammoData[player.UserId][gun] or {Current = 0, Reserve = 0}
    return gunAmmo.Current, gunAmmo.Reserve
end

function AmmoHandler.SetAmmo(player, gun, current, reserve)
    if not ammoData[player.UserId] then
        ammoData[player.UserId] = {}
    end
    ammoData[player.UserId][gun] = {Current = current, Reserve = reserve}
end

return AmmoHandler
