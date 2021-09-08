local pedspawneado = false

RegisterNetEvent('esx:playerLoaded') 
AddEventHandler('esx:playerLoaded', function(xPlayer, isNew)
    ESX.PlayerData = xPlayer
    ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:playerLogout') 
AddEventHandler('esx:playerLogout', function(xPlayer, isNew)
    ESX.PlayerLoaded = false
    ESX.PlayerData = {}
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

---- npc spawn

local genderNum = 0
local distancecheck = false


Citizen.CreateThread(function()

	while true do
		Citizen.Wait(100)
		for k,v in pairs (Config.main) do
			local id = GetEntityCoords(PlayerPedId())
			local distancia = #(id - v.coords)
			
			if distancia < Config.Distancia and distancecheck == false then
				spawn(v.modelo, v.coords, v.heading, v.gender, v.animDict, v.animName)
				distancecheck = true
			end
			if distancia >= Config.Distancia and distancia <= Config.Distancia + 1 then
				
				distancecheck = false
				DeletePed(ped)
			end
		end
	end
	
	
end)

function spawn(modelo, coords, heading, gender, animDict, animName)
	
	RequestModel(GetHashKey(modelo))
	while not HasModelLoaded(GetHashKey(modelo)) do
		Citizen.Wait(1)
	end
	
	if gender == 'male' then
		genderNum = 4
	elseif gender == 'female' then 
		genderNum = 5
	end	

	
	local x, y, z = table.unpack(coords)
	ped = CreatePed(genderNum, GetHashKey(modelo), x, y, z - 1, heading, false, true)
		
	
	
	SetEntityAlpha(ped, 255, false)
	FreezeEntityPosition(ped, true) 
	SetEntityInvincible(ped, true) 
	SetBlockingOfNonTemporaryEvents(ped, true) 
	
	if animDict and animName then
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
		TaskPlayAnim(ped, animDict, animName, 8.0, 0, -1, 1, 0, 0, 0)
	end
	
	
end 

exports['qtarget']:AddBoxZone("police:outfits", vector3(459.32, -990.97, 30.69), 0.60, 0.70, {
	name="police:outfits",
	heading=88.53,
	debugPoly=false,
	minZ=29.67834,
	maxZ=31.67834,
	}, {
	options = {
		{
			event = "Night:openoutfitsmenu",
			icon = "fas fa-sign-in-alt",
			label = "Open Outfits Menu",
			job = "police",
		},
	},
	distance = 3.5
})

exports['qtarget']:AddBoxZone("mechanic:outfits", vector3(-344.41, -123.38, 39.01), 0.60, 0.70, {
	name="mechanic:outfits",
	heading=88.53,
	debugPoly=false,
	minZ=37.97834,
	maxZ=40.17834,
	}, {
	options = {
		{
			event = "Night:openoutfitsmenu",
			icon = "fas fa-sign-in-alt",
			label = "Open Outfits Menu",
			job = "mechanic",
		},
	},
	distance = 3.5
})

RegisterNetEvent('Night:openoutfitsmenu', function()
    
    TriggerEvent('nh-context:sendMenu', {
        {
            id = 1,
            header = "Emergency outfits",
            txt = ""
        },
        {
            id = 2,
            header = "Oufits",
            txt = "",
            params = {
                event = "Night:testings",
                args = {
                        
                        
                }
            }
        },
        {
            id = 3,
            header = "Street clothes",
            txt = "",
            params = {
                event = "Night:streetclothes",
                args = {
                        
                        
                }
            }
        },
        {
            id = 4,
            header = "save clothing",
            txt = "",
            params = {
                event = "Night:saveclothingoutfit",
                args = {
                        
                        
                }
            }
        },
            
    })

       
    
end)

RegisterNetEvent('Night:saveclothingoutfit')
AddEventHandler('Night:saveclothingoutfit', function()
    TriggerServerEvent('fivem-appearance:save', exports['fivem-appearance']:getPedAppearance(PlayerPedId()))
    exports['mythic_notify']:SendAlert('inform', 'outfit saved for relog')
end)

RegisterNetEvent('Night:testings', function()

    for k,v in pairs(Config.outfits) do
        
        if ESX.PlayerData.job and ESX.PlayerData.job.name == v.job and ESX.PlayerData.job.grade_name == v.grade then
            ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin.model == v.model then
                    local outfit = {}
                    table.insert(outfit, {
                        id = k,
                        header = v.label,
                        txt = '',
                        params = {
                            event = 'Night:outfitspolice',
                            args = {
                                torso = v.torso,
                                undershirt = v.undershirt,
                                arms = v.arms,
                                pants = v.pants,
                                shoes = v.shoes,
                                bag = v.bag,
                                accesories = v.accesories,
                                kevlar = v.kevlar,
                                badge = v.badge,
                                hat = v.hat
                            }
                        }
                    })
                    TriggerEvent('nh-context:sendMenu', outfit)
                end
            end)        
       
        
        end     
    end    
         
end)

RegisterNetEvent('Night:streetclothes')
AddEventHandler('Night:streetclothes',function(data)

    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)

        local model = nil

        if skin.sex == 0  then
        model = GetHashKey("mp_m_freemode_01")
        else
        model = GetHashKey("mp_f_freemode_01")
        end

        RequestModel(model)
        while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(1)
        end

        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)

        TriggerEvent('skinchanger:loadSkin', skin)
        TriggerEvent('esx:restoreLoadout')
    end)
    
end)

RegisterNetEvent('Night:outfitspolice')
AddEventHandler('Night:outfitspolice',function(data)
  
    exports['fivem-appearance']:setPedComponents(PlayerPedId(), {data.torso,data.undershirt,data.pants,data.shoes,data.bag,data.accesories,data.kevlar,data.badge,data.arms})  
    exports['fivem-appearance']:setPedProps(PlayerPedId(), {data.hat})     
         
end)

