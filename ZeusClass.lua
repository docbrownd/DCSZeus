
local TMP_TEMPLATES = {
    [1] = {
        ["unit"] = "T-55",
        ["name"] = "T-55"
    },
    [2] = {
        ["unit"] = "T-90",
        ["name"] = "T-90"
    },
    [3] = {
        ["unit"] = "M-1 Abrams",
        ["name"] = "M-1"
    },
    [4] = {
        ["unit"] = "M-109",
        ["name"] = "M-109"
    },
    [5] = {
        ["unit"] = "T-80UD",
        ["name"] = "T-80"
    },

    [6] = {
        ["unit"] = "T-72B",
        ["name"] = "T-72"
    },

    [7] = {
        ["unit"] = "Vulcan",
        ["name"] = "Vulcan"
    },

    [8] = {
        ["unit"] = "Soldier RPG",
        ["name"] = "RPG"
    },

    [9] = {
        ["unit"] = "Ural-375 ZU-23",
        ["name"] = "ZU23"
    },

    [10] = {
        ["unit"] = "ZSU-23-4 Shilka",
        ["name"] = "ZSU23"
    },

    [11] = {
        ["unit"] = "Tor 9A331",
        ["name"] = "SA-15"
    },

    [12] = {
        ["unit"] = "Strela-10M3",
        ["name"] = "SA-13"
    },

    [13] = {
        ["unit"] = "Strela-1 9P31",
        ["name"] = "SA-9"
    },

    [14] = {
        ["unit"] = "SA-8 Osa LD 9T217",
        ["name"] = "SA-8"
    },

    [15] = {
        ["unit"] = "Ural-375",
        ["name"] = "Ural"
    },

    [16] = {
        ["unit"] = "Smerch",
        ["name"] = "Smerch"
    },

	[17] = {
        ["unit"] = "Soldier AK",
        ["name"] = "AK"
    },
	[18] = {
        ["unit"] = "BMP-3",
        ["name"] = "BMP-3"
    },
	[19] = {
        ["unit"] = "BTR-80",
        ["name"] = "BTR-80"
    },
	[20] = {
        ["unit"] = "Ural-4320T",
        ["name"] = "Ural-4320T"
    },
	[21] = {
        ["unit"] = "Ural-4320-31",
        ["name"] = "Ural-4320-31"
    },
	[22] = {
        ["unit"] = "HL_KORD",
        ["name"] = "HL_KORD"
    },
	[23] = {
        ["unit"] = "Tigr_233036",
        ["name"] = "Tigr"
    },
	[24] = {
        ["unit"] = "SA-18 Igla-S manpad",
        ["name"] = "SA-18"
    },
	
	
	
	
	
}





ZeusMod = {}

do
    function ZeusMod:New(editorUnit)
        local obj = {}  
        setmetatable(obj,  {__index = self})
		obj.templates = templates or TMP_TEMPLATES
		obj.needPassword = false
		obj.passwordDone = false
		obj.password = ''
		obj.groupSpawn = {}
		obj.randomPos = false
		obj.groupNbr = 0
		obj.coalition = nil
		obj.destination = nil
		obj.marks = {}
		obj.marksIDs = {}
		obj.markID = 10000
		obj.turnOffReco = false
		obj.zones = {}
		obj.defineZone = ""
		obj.zonesMenu = {}
		obj.fobTemplates = FOBTemplates
		obj.FOBAliveNumber = 0
		obj.editorUnit = editorUnit
		obj.backupSpawn = {}
        return obj
    end

	function ZeusMod:AddZone(zoneName, codeName, Menu)
		self.zones[codeName] = ZONE:FindByName(zoneName)
		if self.zonesMenu[Menu] == nil then self.zonesMenu[Menu] = {} end 
		self.zonesMenu[Menu][#self.zonesMenu[Menu] + 1] = {zoneName = zoneName, menu = Menu, codeName = codeName}
		--self.zonesMenu[codeName] = zoneName
	end

	function ZeusMod:UsePassword(pwd)
		self.needPassword = true 
		self.password = pwd
	end


	function ZeusMod:Split(s, delimiter)
		local result = {};
		for match in (s..delimiter):gmatch("(.-)"..delimiter) do
			table.insert(result, match);
		end
		return result;
	end

	function ZeusMod:CreateTemplate()
		for i, datas in ipairs(self.templates) do 
			env.info(datas.unit, false)
			local trueTemplate = {
				["task"] = {},
				["units"] = 
				{
					[1] = 
					{
						["type"] = datas.unit,
						["y"] = 0,
						["x"] = 0,
						["name"] = "Z_" .. datas.name,  
					}, -- end of [1]
				},
				["name"] = "Z_" .. datas.name,  
				["y"] = 0,
				["x"] = 0,
			}
			GROUP:NewTemplate(trueTemplate, coalition.side.RED, Group.Category.GROUND, country.id.RUSSIA)     
		end
	end

	function ZeusMod:Init()
		self:CreateTemplate()
		self:DefineMenu()
        world.addEventHandler(self)
		env.info("Zeus Init", false)

	end

	function ZeusMod:defineZoneFromMenu(codename)
		if (codename ~= nil) then 
			self.defineZone = codename
			trigger.action.outText("Utilisez la commande '#zone' pour déclencher le spawn dans la zone "..self.zones[codename]:GetName(), 20)
		end
	end

	function ZeusMod:DefineMenu()
		if (self.zonesMenu ~= {}) then 
			local subMenus = {}
			local menuSpawn = missionCommands.addSubMenu("Spawn in zones", nil)
			for menuName, obj in pairs(self.zonesMenu) do 
				subMenus[menuName] = missionCommands.addSubMenu(menuName.."...", menuSpawn)
				for index, datas in ipairs(obj) do 
					missionCommands.addCommand(  
						"Zone "..datas.zoneName,
						subMenus[menuName],
						self.defineZoneFromMenu,
						self, datas.codeName
					)

				end
			end
		end


	end

	
    function ZeusMod:SpawnEditorUnit(groupName, pos)

		local coord = COORDINATE:NewFromVec3(pos)
		self.groupNbr = self.groupNbr + 1

		local spawnTmp = SPAWN:NewWithAlias(groupName, groupName .. "_" .. tostring(self.groupNbr)):OnSpawnGroup(
			function(mooseGroup)
				self.groupSpawn[mooseGroup] = mooseGroup
			end
		):InitCoalition(self.coalition)

		if (self.randomPos) then 
			spawnTmp = spawnTmp:InitRandomizePosition(true, 100)
		end
		if (self.coalition == coalition.side.RED) then --red
			spawnTmp = spawnTmp:InitCountry(country.id.RUSSIA)
		else 
			spawnTmp = spawnTmp:InitCountry(country.id.USA)
		end
		spawnTmp:SpawnFromVec2(coord:GetVec2())
    end

	function ZeusMod:AddSpecificGroup(pos, cmds) 
		if (cmds[2] == nil) then return end

		local groupName = cmds[2]
		self:DefineCoalition(cmds[3])
			
		if(groupName == "SA2") then 		
			self:Spawn("SA2_ZEUS", pos)		
		elseif(groupName == "SA3") then 	
			self:Spawn("SA3_ZEUS", pos)		
		elseif(groupName == "SA6") then 	
			self:Spawn("SA6_ZEUS", pos)		
		elseif(groupName == "SA10") then 	
			self:Spawn("SA10_ZEUS", pos)		
		elseif(groupName == "SA11") then 	
			self:Spawn("SA11_ZEUS", pos)		
		elseif(groupName == "SA5") then 	
			self:Spawn("SA5_ZEUS", pos)		
		-- elseif(groupName == "FOB1") then
		-- 	self:SpawnStaticUnit("FOB", pos)
		-- elseif(groupName == "LARGEFOB") then 
		-- 	self:SpawnStaticUnit("LARGEFOB", pos)
		-- elseif(groupName == "SMALLFOB") then 
		-- 	self:SpawnStaticUnit("SMALLFOB", pos)
		-- elseif(groupName == "MEDIUMFOB") then 
		-- 	self:SpawnByTemplateName("BIGFOB",pos) 
		else
			local nbr = tonumber(cmds[4]) or 1
			self.randomPos = nbr > 1
			for i = 1,  nbr do
				self:Spawn("Z_" .. groupName, pos)
			end
		end
		trigger.action.outText("Spawn groupe", 10)
		
	end

	function ZeusMod:Spawn(groupName, pos)
		env.info("Spawn")
		env.info("coalition : " .. tostring(self.coalition))

		local coord = COORDINATE:NewFromVec3(pos)
		self.groupNbr = self.groupNbr + 1
		local spawnTmp = SPAWN:NewWithAlias(self.editorUnit, groupName .. "_" ..tostring(self.groupNbr)):InitRandomizeTemplate({groupName}):OnSpawnGroup(
			function(mooseGroup)
				self.groupSpawn[mooseGroup] = mooseGroup
			end
		):InitCoalition(self.coalition)


		if (self.randomPos) then 
			spawnTmp = spawnTmp:InitRandomizePosition(true, 100)
		end

		if (self.coalition == coalition.side.RED) then --red
			spawnTmp = spawnTmp:InitCountry(country.id.RUSSIA)
		else 
			spawnTmp = spawnTmp:InitCountry(country.id.USA)
		end

		spawnTmp:SpawnFromVec2(coord:GetVec2())
	end
	

	function ZeusMod:SpawnByTemplateName(template, pos) 
		local distanceBetween = 0
		local angleBetween = 0
		local initCoord = nil
		local coord = nil
		local x = 0
		local y = 0
		local z = 0
		local spawnGroupUnit = nil
		local shapeName = nil
		local typeName = nil
		local nameStat = nil
		local heading = nil 
		local spawnDtat = nil 
		self.FOBAliveNumber = self.FOBAliveNumber + 1 

		for index, datas in ipairs(self.fobTemplates[template]["static"]["group"]) do

			shapeName = datas.units[1].shape_name 
			typeName = datas.units[1].type 
			nameStat = datas.units[1].name 
			heading = datas.units[1].heading or 0
			x = datas.units[1].x
			z = datas.units[1].y 
			y = pos.y 


			spawnDtat = SPAWNSTATIC:InitType(typeName)
			spawnDtat = spawnDtat:InitNamePrefix(nameStat .. "_" .. tostring(self.FOBAliveNumber))

			if (shapeName ~= nil ) then 
				spawnDtat = spawnDtat:InitShape(shapeName)
			end
			spawnDtat = spawnDtat:InitCountry(country.id.RUSSIA)

			if (index == 1) then 

				coord = COORDINATE:New(x, y, z) 
				initCoord = COORDINATE:New(pos.x, pos.y, pos.z)
				if self.backupSpawn[template] == nil then self.backupSpawn[template]  = {} end
				self.backupSpawn[template][self.FOBAliveNumber] = initCoord
				distanceBetween = initCoord:Get2DDistance(coord)
				angleBetween = coord:GetAngleDegrees(coord:GetDirectionVec3(initCoord))
				coord = initCoord
			else 
				coord = COORDINATE:New(x, y,z):Translate(distanceBetween,angleBetween )

			end
			
			spawnDtat:SpawnFromCoordinate(coord, math.deg(heading))

		end

		x = 0
		y = 0
		z = 0

		if (self.fobTemplates[template]["vehicle"] ~= nil) then 
			
			for index, datas in ipairs(self.fobTemplates[template]["vehicle"]["group"]) do
				x = datas.units[1].x
				z = datas.units[1].y 
				y = pos.y 
				env.info(tostring(x) .. "   " ..tostring(y).. "   ".. tostring(z), false)

				spawnGroupUnit = SPAWN:NewFromTemplate(datas, datas.name..tostring(self.FOBAliveNumber), datas.name.."_A_"..template..tostring(self.FOBAliveNumber) )
				env.info(datas.units[1].name, false)
				if (self.FOBAliveNumber == 1) then 
					coord = COORDINATE:New(x, y,z):Translate(distanceBetween,angleBetween)
					spawnGroupUnit:InitCountry(country.id.RUSSIA):InitCategory(Group.Category.GROUND):SpawnFromCoordinate(coord)
				else 	
					local tmp = self.backupSpawn[template][self.FOBAliveNumber - 1 ]
		
					coord = COORDINATE:New(x, y, z)
					distanceBetween = tmp:Get2DDistance(coord)
					angleBetween = tmp:GetAngleDegrees(tmp:GetDirectionVec3(coord))

					coord = COORDINATE:New(pos.x, pos.y,pos.z):Translate(distanceBetween,angleBetween )


					spawnGroupUnit:InitCountry(country.id.RUSSIA):InitCategory(Group.Category.GROUND):SpawnFromCoordinate(coord)
				end
			end
		end
	end


	function ZeusMod:Remove(pos, cmds)
		if (cmds[2] == "all") then 
			self:RemoveAll()
		end
	end


	function ZeusMod:RemoveAll()
		for index, units in pairs(self.groupSpawn) do
			if (units and units:IsAlive()) then 
				env.info(tostring(units:GetName()), false)
				Group.getByName(units:GetName()):destroy()		
			end
		end
		self.groupSpawn = {}
		self.groupNbr = 0
		trigger.action.outText("Suppression des unités", 10)
	end


	function ZeusMod:AddGroup(pos, cmds) 
		env.info("slot : " .. tostring(cmds[2]), false)
		if (cmds[2] == nil) then return end
		self:DefineCoalition(cmds[3])
		self:SpawnEditorUnit(cmds[2],  pos)
		trigger.action.outText("Groupe " .. tostring(cmds[2]) .. " spawn", 10)
	end

	function ZeusMod:Explode(pos, cmds) 
		local detonator = cmds[2] or 5
		local power = cmds[3] or 1000000
		timer.scheduleFunction(
			function(time) 
				trigger.action.explosion(pos, power)
			end, 
			nil, timer.getTime() + detonator
		)
		trigger.action.outText("Explosion", 10)
	end

	function ZeusMod:DefineCoalition(value)
		self.coalition = coalition.side.RED
		if (value ~= nil and value ~= "" ) then 
			if value == "1" then self.coalition = coalition.side.RED else self.coalition = coalition.side.BLUE end
		end
	end

	function ZeusMod:AddConvoy(pos, cmds) 
		local conv = Convoy:New(self.templates)
		self:DefineCoalition(cmds[4])
		conv:SpawnGroup({
			type  = cmds[2],
			coalition = self.coalition,
			pos  = pos,
			name = cmds[3],
			destination = self.destination
		})
	end

	function ZeusMod:RemoveMark(unitName)
		if (self.marks[unitName]) then 
			trigger.action.removeMark(self.marks[unitName])
			self.marks[unitName] = nil
		end
	end

	function ZeusMod:AddMark(obj)
		if (self.marks[obj.name] ~= nil) then 
			self:RemoveMark(obj.name)
		end

		self.markID = self.markID + 1 
		trigger.action.markToAll( self.markID , obj.text, obj.position , false)
		self.marks[obj.name] = self.markID
		self.marksIDs[self.markID] = obj.name
	end 

	function ZeusMod:ExecReco(pos, cmds)
		trigger.action.outText("Reconnaissance en cours...", 20)
		local radius = cmds[2] or 4000

        local searchVolume = {
            ["id"] = world.VolumeType.SPHERE,
            ["params"] = {
                ["point"] = pos,
                ["radius"] = radius,
            }
        }

        world.searchObjects(Object.Category.UNIT, searchVolume, 
            function(obj, param)
                if obj ~= nil and obj:getLife() > 0 and obj:isActive() and obj:getCoalition() ==  coalition.side.RED  then 
                    local vec3 =  obj:getPoint() 
                    local coord = COORDINATE:NewFromVec3(vec3)
                    local text =  obj:getTypeName() .. "\n\n" .. coord:ToStringLLDDM() .. "\n" .. coord:ToStringMGRS() .. "\n" .. coord:ToStringLLDMS()
                    param:AddMark({text = text, position = vec3, name = obj:getName() })
                end
            end
        , self)

        trigger.action.outText("Reconnaissance terminée", 20)

	end


	function ZeusMod:Reco(pos, cmds)
		if (self.turnOffReco) then return end
		local doReco = true
		local j = 0
		for i, value in pairs(self.marks) do 
			j = j + 1
			if (doReco and value ~= nil and j >= 40) then 
				trigger.action.outText("Reconnaissance impossible, trop d'unité identifiées...", 20)
				doReco = false
				return
			end
		end
		if (not doReco) then return end
		self:ExecReco(pos, cmds)
	end

	function ZeusMod:RandomPosInZone(codeName)
		if (self.zones[codeName] ~= nil) then 
			return self.zones[codeName]:GetRandomPointVec3()
		end
		return nil
	end

	function ZeusMod:ConvertCmd(cmd)
		local cmdN = {}
		cmdN[1] = "addZ"
		for i = 2, #cmd do 
			cmdN[i] = cmd[i+1]
		end
		return cmdN
	end

	function ZeusMod:onEvent(event)
        if (event.id == 26 and string.sub(event.text, 1,1) == "#") then
				local text = event.text:gsub("#","")  
				local cmd = self:Split(text, '_')
				if (self.needPassword and self.passwordDone) or (not self.needPassword) then 
					if (cmd[1] == "add") then self:AddGroup(event.pos, cmd) end -- for dev spawn 
					if (cmd[1] == "addZ") then self:AddSpecificGroup(event.pos, cmd) end -- for tempalte spawn 
					if (cmd[1] == 'addF') then self:SpawnByTemplateName(cmd[2],event.pos) end
					if (cmd[1] == "explosion") then self:Explode(event.pos, cmd) end -- boom 
					if (cmd[1] == "remove") then self:Remove(event.pos, cmd) end -- remove all 
					if (cmd[1] == "convoy") then self:AddConvoy(event.pos, cmd) end -- spawn convoy
					if (cmd[1] == "destination") then self.destination = event.pos end -- define destination for convoy
					if (cmd[1] == "reconolimit") then self:ExecReco(event.pos, cmd) end
					if (cmd[1] == "turnoffreco") then self.turnOffReco = true end
					if (cmd[1] == "turnonreco") then self.turnOffReco = false end
					if (cmd[1] == "zone") then 
						local vec3 = self:RandomPosInZone(cmd[2]) or self:RandomPosInZone(self.defineZone)
						local cmdN = self:ConvertCmd(cmd)
						if vec3 ~= nil and cmdN ~= nil then 
							self:AddSpecificGroup(vec3, cmdN) 
						end
					end 

					if (cmd[1] == "test") then 
						local coord = COORDINATE:NewFromVec3(event.pos)
						local POINT = POINT_VEC2:NewFromVec2(coord:GetVec2())
				
						SPAWNSTATIC:NewFromTemplate(TEMPLATE_TEST)
						:InitCountry(country.id.RUSSIA)
						:SpawnFromPointVec2(POINT, 90)
					end

				end
			
				if (self.needPassword and not self.passwordDone and cmd[1] == "pass") then 
					if cmd[2] and cmd[2] == self.password then 
						self.passwordDone = true 
					--	trigger.action.outText("Mot de passe confirmé", 10)
					end
				end

				-- cmd possible without pwd
				if (cmd[1] == "recon") then self:Reco(event.pos, cmd) end -- reco 
				trigger.action.removeMark(event.idx)
        end

		if (event.id == 27) then 
			if (self.marksIDs[event.idx] ~= nil) then 
				self.marks[self.marksIDs[event.idx]] = nil
				self.marksIDs[event.idx] = nil
			end
		end

		if (event.id == world.event.S_EVENT_UNIT_LOST or event.id == world.event.S_EVENT_DEAD ) then 
            if (event.initiator) then 
                local unitName = event.initiator:getName()
                if (self.marks ~= nil and self.marks[unitName] ~= nil) then 
					self:RemoveMark(unitName)
                end
            end

        end
	end
	

end

Convoy = {}

do




	--[[
	un convoi se défini par : 
		- les unités qui vont pop 
		- la base de départ  
		- la base de destination 
		- un temps minimal entre 2 pop 
		- ne peut pas pop s'il est en vie 
		- ne peut pas pop s'il n'est pas mort depuis assez longtemps 
	]]--

	function Convoy:New(templates) 
		local obj = {}
		setmetatable(obj,  {__index = self})
		obj.name = ""
		obj.templates = templates
		obj.units = {}
		obj.units.heavy = {
			"T-90", "BTR-80", "BTR-80", "Ural", "SA-9", "SA-15", "Ural", "Ural", "ZSU23", "BTR-80", "T-90"
		}
		obj.units.sa9 = {
			"T-90", "BTR-80", "BTR-80", "Ural", "SA-9", "Ural", "Ural", "ZSU23", "BTR-80", "T-90"
		}
		obj.units.zu = {
			"T-90", "BTR-80", "BTR-80", "Ural", "Ural", "Ural", "ZSU23", "BTR-80", "T-90"
		}
		obj.units.armored = {
			"T-90", "BTR-80", "BTR-80", "Ural", "Ural", "Ural", "BTR-80", "BMP-3", "T-90"
		}
		obj.units.t90 = {
			"T-90", "T-90", "T-90", "T-90", "T-90", "Ural", "T-90", "T-90"
		}
		obj.units.t90SA = {
			"T-90", "T-90", "T-90", "T-90", "T-90", "Ural", "SA-9", "T-90", "T-90"
		}
		obj.units.unArmored = {
			"Ural-4320T", "Ural-4320T", "Ural-4320T", "Ural", "Ural", "Ural", "Ural-4320-31", "Ural-4320-31", "Ural-4320T"
		}
		obj.units.scout = {
			"HL_KORD", "HL_KORD", "Tigr", "HL_KORD", "Ural", "Ural", "Ural-4320-31", "HL_KORD", "HL_KORD"
		}
		obj.units.uniq = {
			"HL_KORD"
		}
		return obj
	end

	function Convoy:FindUnitByName(name)
		for _, unitInfos in ipairs(self.templates) do 
			if (unitInfos.name and unitInfos.name == name) then return unitInfos.unit end
		end
	end

	function Convoy:EraseName()
		self.name = ""
	end

	function Convoy:IsAlive()
		local mooseGroup = GROUP:FindByName(self.name)
		if (mooseGroup == nil) then return false end
		return mooseGroup:IsAlive()
	end

	function Convoy:Destroy()
		local groupUnits = Group.getByName(self.name)
		if (groupUnits ~= nil) then  
			Group.getByName(groupUnits:GetName()):destroy()	
			self.EraseName()
		end
	end


	function Convoy:CreateTemplate(type, name)
		if (type == nil or name == nil or self.units[type] == nil) then return end
		local units = {}
		for index, unit in ipairs(self.units[type]) do 
			-- env.info(unit, false)
			units[#units + 1] = {
				["type"] = self:FindUnitByName(unit),
				["y"] = 0,
				["x"] = 20 * index,
				["name"] = "C_" .. unit .. tostring(index) ,
				["skill"] = "High",
			}
		end

		local temp = {
			--["route"] = {["points"] = {}},
			["task"] = {},
			["units"] = units,
			["name"] = "C_" .. name,  
			["y"] = 0,
			["x"] = 0
		
		}


		return temp
	end


	function Convoy:SpawnGroup(obj)
		if (obj.type == nil or obj.name == nil or obj.coalition == nil or obj.pos == nil or obj.destination == nil) then return self end

		local countryID = country.id.RUSSIA
		if (obj.coalition ==  coalition.side.BLUE) then 
			countryID = country.id.USA
		end

		local template = self:CreateTemplate(obj.type, obj.name)
		local coordinate = COORDINATE:NewFromVec3(obj.pos)
		local mooseGroup = SPAWN:NewFromTemplate(template,"C_".. obj.name)
		:InitCountry(countryID)
		:InitCoalition(obj.coalition)
		:InitCategory(Group.Category.GROUND)
		:OnSpawnGroup(
			function(grp)
				grp:RouteGroundOnRoad(COORDINATE:NewFromVec3(obj.destination), 100)
				--grp:RouteToVec3(obj.destination, 12)
				self.name = grp:GetName()
			end
		)
		:SpawnFromPointVec3(POINT_VEC3:NewFromVec3(obj.pos))
		env.info("spawn name : " .. tostring(self.name), false)
	end




end

env.info("Zeus load", false)
