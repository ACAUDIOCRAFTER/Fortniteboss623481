local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local savedCFrame = nil
local HttpService = game:GetService("HttpService")
local reanimEnabled = false
local originalChar = nil
local cloneChar = nil
local savedRootCFrame = nil
local animateScript = nil
local heartbeatConnection = nil
local originalHipHeight = nil
local originalPartSizes = {}
local originalMotorData = {}
local animationCache = {}
local stateAnimations = {
	["idle"] = nil,
	["walking"] = nil,
	["jumping"] = nil
}

local playerID = tostring(LocalPlayer.UserId)
local playerFolder = "ac_reanim_" .. playerID
local jsonDropFolder = "Drop JSON FILES HERE"

local stateAnimCachePath = playerFolder .. "/state_animations.json"
local stateConnections = {}
local sizeScale = {
	["heightScale"] = 1,
	["widthScale"] = 1
}
local animListCachePath = playerFolder .. "/animation_list_cache.json"
_G.hiddenBodyParts = _G.hiddenBodyParts or {}
local _ = _G.hiddenBodyParts
local bodyPartNames = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
	"HumanoidRootPart"
}
local snakeModeEnabled = false
local snakeDistance = 1
local snakeLerpSpeed = 0.1
local snakeForwardMode = true
local coverSkyEnabled = false
local groundPositions = {
	["Head"] = Vector3.new(101, 3, -2152),
	["UpperTorso"] = Vector3.new(101, 3, -2150002),
	["LowerTorso"] = Vector3.new(101, 3, -2150002),
	["Torso"] = Vector3.new(101, 3, -2150002),
	["LeftUpperArm"] = Vector3.new(0, 3, 0),
	["LeftLowerArm"] = Vector3.new(0, 3, 0),
	["LeftHand"] = Vector3.new(0, 3, 0),
	["Left Arm"] = Vector3.new(0, 3, 0),
	["RightUpperArm"] = Vector3.new(999999, 3, 0),
	["RightLowerArm"] = Vector3.new(0, 3, 0),
	["RightHand"] = Vector3.new(0, 3, 0),
	["Right Arm"] = Vector3.new(999999, 3, 0),
	["LeftUpperLeg"] = Vector3.new(-10000000, 3, 25000000),
	["LeftLowerLeg"] = Vector3.new(-10000000, 3, -25000000),
	["LeftFoot"] = Vector3.new(0, 3, 0),
	["Left Leg"] = Vector3.new(-10000000, 3, 25000000),
	["RightUpperLeg"] = Vector3.new(10000000, 3, 25000000),
	["RightLowerLeg"] = Vector3.new(10000000, 3, -25000000),
	["RightFoot"] = Vector3.new(0, 3, 0),
	["Right Leg"] = Vector3.new(10000000, 3, 25000000)
}
local skyPositions = {
	["Head"] = Vector3.new(101, 1003, -2152),
	["UpperTorso"] = Vector3.new(101, 1015, -2150002),
	["LowerTorso"] = Vector3.new(101, 996.8, -2150002),
	["Torso"] = Vector3.new(101, 1015, -2150002),
	["LeftUpperArm"] = Vector3.new(0, 1000, 0),
	["LeftLowerArm"] = Vector3.new(0, 1000, 0),
	["LeftHand"] = Vector3.new(0, 1000, 0),
	["Left Arm"] = Vector3.new(0, 1000, 0),
	["RightUpperArm"] = Vector3.new(999999, 1000, 0),
	["RightLowerArm"] = Vector3.new(0, 1000, 0),
	["RightHand"] = Vector3.new(0, 1000, 0),
	["Right Arm"] = Vector3.new(999999, 1000, 0),
	["LeftUpperLeg"] = Vector3.new(-10000000, 1015, 25000000),
	["LeftLowerLeg"] = Vector3.new(-10000000, 1015, -25000000),
	["LeftFoot"] = Vector3.new(0, 1000, 0),
	["Left Leg"] = Vector3.new(-10000000, 1015, 25000000),
	["RightUpperLeg"] = Vector3.new(10000000, 1015, 25000000),
	["RightLowerLeg"] = Vector3.new(10000000, 1015, -25000000),
	["RightFoot"] = Vector3.new(0, 1000, 0),
	["Right Leg"] = Vector3.new(10000000, 1015, 25000000)
}
local snakeCurrentPos = {}
local snakeTargetPos = {}
local snakeHistory = {}
local snakeMaxHistory = 3000
local snakePartOrder = {
	"Head",
	"UpperTorso",
	"LowerTorso",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot"
}
local animPlayback = {
	["isRunning"] = false,
	["currentId"] = nil,
	["keyframes"] = nil,
	["totalDuration"] = 0,
	["elapsedTime"] = 0,
	["speed"] = 1,
	["connection"] = nil
}
local animationList = {}
local animationOrder = {}
local animListFetched = false
(function()

	local function v46(p_u_42)
	
		if savedCFrame then
			local v43 = p_u_42:WaitForChild("HumanoidRootPart", 5)
			if v43 then
				v43.CFrame = savedCFrame
			end
			savedCFrame = nil
		end
		local v44 = p_u_42:FindFirstChildOfClass("Humanoid")
		if v44 then
			v44.Died:Connect(function()
			
				local v45 = p_u_42:FindFirstChild("HumanoidRootPart")
				if v45 then
					savedCFrame = v45.CFrame
				end
			end)
		end
	end
	if LocalPlayer.Character then
		v46(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(v46)
end)()
local favoriteAnims = {}
local animKeybinds = {}
local customAnims = {}
local customAnimsPath = playerFolder .. "/custom_animations.json"
local speedKeybindsPath = playerFolder .. "/speed_keybinds.json"
local speedSlots = {}

local function ensureFolder()
	-- Player-ID folder
	if not isfolder(playerFolder) then
		makefolder(playerFolder)
	end
	-- JSON drop folder for custom emotes
	if not isfolder(jsonDropFolder) then
		makefolder(jsonDropFolder)
	end
end

local function loadJsonDropFolder()
	ensureFolder()
	pcall(function()
		local files = listfiles(jsonDropFolder)
		for _, filePath in ipairs(files) do
			-- Only process .json files
			if filePath:lower():match("%.json$") then
				local ok, content = pcall(readfile, filePath)
				if ok and content and content ~= "" then
					local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
					if ok2 and type(data) == "table" then
						-- Support two formats:
						-- Format 1: { "AnimName": "animId or code", ... }
						-- Format 2: [ { "name": "AnimName", "id": "animId" }, ... ]
						if data[1] and type(data[1]) == "table" then
							-- Array format
							for _, entry in ipairs(data) do
								if entry.name and entry.id then
									local name = tostring(entry.name)
									local id = tostring(entry.id)
									customAnims[name] = id
									animationList[name] = id
									if not table.find(animationOrder, name) then
										table.insert(animationOrder, name)
									end
								end
							end
						else
							-- Dictionary format
							for name, id in pairs(data) do
								local n = tostring(name)
								local v = tostring(id)
								customAnims[n] = v
								animationList[n] = v
								if not table.find(animationOrder, n) then
									table.insert(animationOrder, n)
								end
							end
						end
					end
				end
			end
		end
	end)
end

local function saveAnimCache()
	ensureFolder()
	local v54 = {
		["animations"] = animationList,
		["order"] = animationOrder,
		["timestamp"] = os.time()
	}
	local v55, v_u_56 = pcall(HttpService.JSONEncode, HttpService, v54)
	if v55 then
		pcall(function()
			writefile(animListCachePath, v_u_56)
		end)
	end
end
local function loadAnimCache()
	ensureFolder()
	local v58, v59 = pcall(readfile, animListCachePath)
	if v58 then
		local v60, v61 = pcall(HttpService.JSONDecode, HttpService, v59)
		if v60 and (typeof(v61) == "table" and (v61.animations and v61.order)) then
			animationList = v61.animations
			animationOrder = v61.order
			return true
		end
	end
	return false
end
local function fetchAnimList()
	if animListFetched then
		return
	else
		animListFetched = true
		local v63, v64 = pcall(game.HttpGet, game, "https://yourscoper.vercel.app/scripts/akadmin/animlist.lua", true)
		if v63 then
			local v65, v66 = pcall(loadstring(v64))
			if v65 and type(v66) == "table" then
				animationList = {}
				local v67, v68, v69 = pairs(v66)
				while true do
					local v70
					v69, v70 = v67(v68, v69)
					if v69 == nil then
						break
					end
					animationList[v69] = v70
				end
				saveAnimCache()
			end
		else
			return
		end
	end
end
local function saveFavorites()
	ensureFolder()
	local v72, v73, v74 = pairs(favoriteAnims)
	local v75 = {}
	while true do
		local v76
		v74, v76 = v72(v73, v74)
		if v74 == nil then
			break
		end
		v75[v74] = tostring(v76)
	end
	local v77, v_u_78 = pcall(HttpService.JSONEncode, HttpService, v75)
	if v77 then
		pcall(function()
			writefile(playerFolder .. "/favorite_animations.json", v_u_78)
		end)
	end
end
local function loadFavorites()
	ensureFolder()
	local v80, v81 = pcall(readfile, playerFolder .. "/favorite_animations.json")
	if v80 then
		local v82, v83 = pcall(HttpService.JSONDecode, HttpService, v81)
		if v82 and typeof(v83) == "table" then
			favoriteAnims = {}
			local v84, v85, v86 = pairs(v83)
			while true do
				local v87
				v86, v87 = v84(v85, v86)
				if v86 == nil then
					break
				end
				favoriteAnims[v86] = v87
				if not animationList[v86] then
					animationList[v86] = v87
					if not table.find(animationOrder, v86) then
						table.insert(animationOrder, v86)
					end
				end
			end
		else
			favoriteAnims = {}
		end
	else
		favoriteAnims = {}
	end
end
local function saveKeybinds()
	ensureFolder()
	local v89, v90, v91 = pairs(animKeybinds)
	local v92 = {}
	while true do
		local v93
		v91, v93 = v89(v90, v91)
		if v91 == nil then
			break
		end
		v92[v91] = v93.Name
	end
	local v94, v_u_95 = pcall(HttpService.JSONEncode, HttpService, v92)
	if v94 then
		pcall(function()
			writefile(playerFolder .. "/animation_keybinds.json", v_u_95)
		end)
	end
end
local function loadKeybinds()
	ensureFolder()
	local v97, v98 = pcall(readfile, playerFolder .. "/animation_keybinds.json")
	if v97 then
		local v99, v100 = pcall(HttpService.JSONDecode, HttpService, v98)
		if v99 and typeof(v100) == "table" then
			animKeybinds = {}
			local v101, v102, v103 = pairs(v100)
			while true do
				local v104
				v103, v104 = v101(v102, v103)
				if v103 == nil then
					break
				end
				local v105 = Enum.KeyCode[v104]
				if v105 then
					animKeybinds[v103] = v105
				end
			end
		else
			animKeybinds = {}
		end
	else
		animKeybinds = {}
	end
end
local function saveSpeedSlots()
	ensureFolder()
	local v107 = {}
	for v108 = 1, 5 do
		if speedSlots[v108] then
			v107["slot" .. v108] = {
				["speed"] = speedSlots[v108].speed or v108 * 2 - 1,
				["key"] = speedSlots[v108].key or ""
			}
		end
	end
	local v109, v_u_110 = pcall(HttpService.JSONEncode, HttpService, v107)
	if v109 then
		pcall(function()
			writefile(speedKeybindsPath, v_u_110)
		end)
	end
end
local function loadSpeedSlots()
	ensureFolder()
	local v112, v113 = pcall(readfile, speedKeybindsPath)
	if v112 then
		local v114, v115 = pcall(HttpService.JSONDecode, HttpService, v113)
		if v114 and typeof(v115) == "table" then
			for v116 = 1, 5 do
				local v117 = "slot" .. v116
				if v115[v117] then
					speedSlots[v116] = {
						["speed"] = v115[v117].speed or v116 * 2 - 1,
						["key"] = v115[v117].key or ""
					}
				end
			end
		end
	end
end
local function saveStateAnims()
	ensureFolder()
	local v119 = {
		["idle"] = stateAnimations.idle,
		["walking"] = stateAnimations.walking,
		["jumping"] = stateAnimations.jumping
	}
	local v120, v_u_121 = pcall(HttpService.JSONEncode, HttpService, v119)
	if v120 then
		pcall(function()
			writefile(stateAnimCachePath, v_u_121)
		end)
	end
end
local function loadStateAnims()
	ensureFolder()
	local v123, v124 = pcall(readfile, stateAnimCachePath)
	if v123 then
		local v125, v126 = pcall(HttpService.JSONDecode, HttpService, v124)
		if v125 and typeof(v126) == "table" then
			stateAnimations.idle = v126.idle
			stateAnimations.walking = v126.walking
			stateAnimations.jumping = v126.jumping
		end
	end
end
local function saveCustomAnims()
	ensureFolder()
	local v128, v129, v130 = pairs(customAnims)
	local v131 = {}
	while true do
		local v132
		v130, v132 = v128(v129, v130)
		if v130 == nil then
			break
		end
		v131[v130] = v132
	end
	local v133, v_u_134 = pcall(HttpService.JSONEncode, HttpService, v131)
	if v133 then
		pcall(function()
			writefile(customAnimsPath, v_u_134)
		end)
	end
end
local function loadCustomAnims()
	ensureFolder()
	local v136, v137 = pcall(readfile, customAnimsPath)
	if v136 then
		local v138, v139 = pcall(HttpService.JSONDecode, HttpService, v137)
		if v138 and typeof(v139) == "table" then
			customAnims = {}
			local v140, v141, v142 = pairs(v139)
			while true do
				local v143
				v142, v143 = v140(v141, v142)
				if v142 == nil then
					break
				end
				customAnims[v142] = v143
				animationList[v142] = v143
				if not table.find(animationOrder, v142) then
					table.insert(animationOrder, v142)
				end
			end
		else
			customAnims = {}
		end
	else
		customAnims = {}
	end
	-- Also load from JSON drop folder
	loadJsonDropFolder()
end
local function loadAllData()
	ensureFolder()
	loadAnimCache()
	loadKeybinds()
	loadFavorites()
	loadCustomAnims()
	loadStateAnims()
	loadSpeedSlots()
	task.spawn(function()
		wait(2)
		if isfile(animListCachePath) then
			pcall(function()
				delfile(animListCachePath)
			end)
			print("Deleted old animation cache")
		end
		fetchAnimList()
		loadCustomAnims()
	end)
end
local guisWithResetOnSpawn = {}
local function disableGuiReset()
	local v147 = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	if v147 then
		local v148, v149, v150 = ipairs(v147:GetChildren())
		while true do
			local v151
			v150, v151 = v148(v149, v150)
			if v150 == nil then
				break
			end
			if v151:IsA("ScreenGui") and v151.ResetOnSpawn then
				table.insert(guisWithResetOnSpawn, v151)
				v151.ResetOnSpawn = false
			end
		end
	end
end
local function restoreGuiReset()
	local v153, v154, v155 = ipairs(guisWithResetOnSpawn)
	while true do
		local v156
		v155, v156 = v153(v154, v155)
		if v155 == nil then
			break
		end
		v156.ResetOnSpawn = true
	end
	table.clear(guisWithResetOnSpawn)
end
local function hideCloneChar()
	if cloneChar then
		local v158 = cloneChar
		local v159, v160, v161 = pairs(v158:GetDescendants())
		while true do
			local v162
			v161, v162 = v159(v160, v161)
			if v161 == nil then
				break
			end
			if v162:IsA("BasePart") then
				v162.Transparency = 1
			end
		end
		local v163 = cloneChar:FindFirstChild("Head")
		if v163 then
			local v164, v165, v166 = ipairs(v163:GetChildren())
			while true do
				local v167
				v166, v167 = v164(v165, v166)
				if v166 == nil then
					break
				end
				if v167:IsA("Decal") then
					v167.Transparency = 1
				end
			end
		end
	end
end
local function updateSnakeMode(_)
	if not (reanimEnabled and (originalChar and (originalChar.Parent and (cloneChar and cloneChar.Parent)))) then
		return
	end
	if not snakeModeEnabled then
		return
	end
	local v169 = cloneChar:FindFirstChild("HumanoidRootPart")
	if not v169 then
		return
	end
	if not snakeTargetPos then
		snakeTargetPos = {}
	end
	if not snakeCurrentPos then
		snakeCurrentPos = {}
	end
	local v170 = snakePartOrder
	if #v170 == 0 then
		return
	end
	local v171 = v169.AssemblyLinearVelocity.Magnitude > 0.1
	if not snakeHistory then
		snakeHistory = {}
	end
	table.insert(snakeHistory, 1, {
		["pos"] = v169.Position,
		["rot"] = v169.CFrame - v169.Position
	})
	if snakeMaxHistory < #snakeHistory then
		table.remove(snakeHistory)
	end
	if snakeForwardMode then
		local v172 = v170[1]
		local v173 = originalChar:FindFirstChild(v172)
		if v173 then
			if not snakeTargetPos[v172] then
				snakeTargetPos[v172] = v173.CFrame
			end
			if not snakeCurrentPos[v172] then
				snakeCurrentPos[v172] = v173.CFrame
			end
			if v171 then
				local v174 = v169.Position
				local v175 = v169.CFrame - v169.Position
				snakeTargetPos[v172] = CFrame.new(v174) * v175
			end
			local v176 = snakeCurrentPos[v172]:Lerp(snakeTargetPos[v172], snakeLerpSpeed)
			v173.CFrame = v176
			v173.AssemblyLinearVelocity = Vector3.zero
			v173.AssemblyAngularVelocity = Vector3.zero
			snakeCurrentPos[v172] = v176
			for v177 = 2, #v170 do
				local v178 = v170[v177]
				local v179 = originalChar:FindFirstChild(v178)
				local v180 = originalChar:FindFirstChild(v170[v177 - 1])
				if v179 then
					if v180 then
						if not snakeTargetPos[v178] then
							snakeTargetPos[v178] = v179.CFrame
						end
						if not snakeCurrentPos[v178] then
							snakeCurrentPos[v178] = v179.CFrame
						end
						if v171 then
							local v181 = v180.Position
							local v182 = v180.CFrame - v180.Position
							local v183
							if v177 == 2 then
								v183 = (v181 - v169.Position).Unit
							else
								local v184 = originalChar:FindFirstChild(v170[v177 - 2])
								if v184 then
									v183 = (v181 - v184.Position).Unit
								else
									v183 = v182.LookVector
								end
							end
							if v183.Magnitude < 0.1 then
								v183 = v182.LookVector
							end
							local v185 = v181 + v183 * snakeDistance
							snakeTargetPos[v178] = CFrame.new(v185) * v182
						end
						local v186 = snakeCurrentPos[v178]:Lerp(snakeTargetPos[v178], snakeLerpSpeed)
						v179.CFrame = v186
						v179.AssemblyLinearVelocity = Vector3.zero
						v179.AssemblyAngularVelocity = Vector3.zero
						snakeCurrentPos[v178] = v186
					end
				end
			end
		end
	else
		local v187 = #snakeHistory
		local v188 = { 0 }
		for v189 = 2, v187 do
			v188[v189] = v188[v189 - 1] + (snakeHistory[v189 - 1].pos - snakeHistory[v189].pos).Magnitude
		end
		for v197 = 1, #v170 do
			local v191 = v170[v197]
			local v192 = originalChar:FindFirstChild(v191)
			if v192 then
				local v193 = (v197 - 1) * snakeDistance
				local v194 = v197
				local v195 = nil
				for v196 = 2, v187 do
					if v193 <= v188[v196] then
						v195 = v196
						break
					end
				end
				local v197
				if v195 and (snakeHistory[v195] and snakeHistory[v195 - 1]) then
					local v198 = v188[v195 - 1]
					local v199 = v188[v195]
					local v200 = (v193 - v198) / math.max(1e-6, v199 - v198)
					local v201 = snakeHistory[v195 - 1].pos
					local v202 = snakeHistory[v195].pos
					local v203 = snakeHistory[v195 - 1].rot
					local v204 = v201:Lerp(v202, v200)
					local v205 = CFrame.new(v204) * v203
					if not snakeCurrentPos[v191] then
						snakeCurrentPos[v191] = v192.CFrame
					end
					if not snakeTargetPos[v191] then
						snakeTargetPos[v191] = v192.CFrame
					end
					snakeTargetPos[v191] = v205
					local v206 = snakeCurrentPos[v191]:Lerp(snakeTargetPos[v191], snakeLerpSpeed)
					v192.CFrame = v206
					v192.AssemblyLinearVelocity = Vector3.zero
					v192.AssemblyAngularVelocity = Vector3.zero
					snakeCurrentPos[v191] = v206
					v197 = v194
				else
					local v207 = v169.CFrame
					local v208 = v207 + v207.LookVector * (-(v197 - 1) * snakeDistance)
					v192.CFrame = v208
					snakeCurrentPos[v191] = v208
					v197 = v194
				end
			end
		end
	end
end
local function updateHeartbeat(p210)
	if reanimEnabled and (originalChar and (originalChar.Parent and (cloneChar and cloneChar.Parent))) then
		if snakeModeEnabled then
			updateSnakeMode(p210)
			return
		elseif groundModeEnabled then
			local v211, v212, v213 = pairs(groundPositions)
			while true do
				local v214
				v213, v214 = v211(v212, v213)
				if v213 == nil then
					break
				end
				local v215 = originalChar:FindFirstChild(v213)
				if v215 and v215:IsA("BasePart") then
					v215.CFrame = CFrame.new(v214)
					v215.AssemblyLinearVelocity = Vector3.zero
					v215.AssemblyAngularVelocity = Vector3.zero
				end
			end
			return
		elseif coverSkyEnabled then
			local v216, v217, v218 = pairs(skyPositions)
			while true do
				local v219
				v218, v219 = v216(v217, v218)
				if v218 == nil then
					break
				end
				local v220 = originalChar:FindFirstChild(v218)
				if v220 and v220:IsA("BasePart") then
					v220.CFrame = CFrame.new(v219)
					v220.AssemblyLinearVelocity = Vector3.zero
					v220.AssemblyAngularVelocity = Vector3.zero
				end
			end
		else
			local v221, v222, v223 = ipairs(bodyPartNames)
			while true do
				local v224
				v223, v224 = v221(v222, v223)
				if v223 == nil then
					break
				end
				local v225 = originalChar:FindFirstChild(v224)
				local v226 = cloneChar:FindFirstChild(v224)
				if v225 and v226 then
					if _G.hiddenBodyParts[v224] then
						if not _G.hiddenBodyPartPositions then
							_G.hiddenBodyPartPositions = {}
						end
						if not _G.hiddenBodyPartPositions[v224] then
							local v227 = Vector3.new(0, -500, 0)
							local v228 = v225.CFrame - v225.Position
							_G.hiddenBodyPartPositions[v224] = CFrame.new(v227) * v228
						end
						v225.CFrame = _G.hiddenBodyPartPositions[v224]
					else
						if _G.hiddenBodyPartPositions then
							_G.hiddenBodyPartPositions[v224] = nil
						end
						v225.Anchored = false
						v225.CFrame = v226.CFrame
					end
					v225.AssemblyLinearVelocity = Vector3.zero
					v225.AssemblyAngularVelocity = Vector3.zero
				end
			end
			local v229 = cloneChar:FindFirstChildWhichIsA("Humanoid")
			if v229 and (sizeScale.heightScale ~= 1 or sizeScale.widthScale ~= 1) then
				local v230 = originalHipHeight * sizeScale.heightScale - 0.5
				v229.HipHeight = math.max(v230, 0.2)
			end
		end
	else
		return
	end
end
local function applyBodyScale()
	if reanimEnabled and cloneChar then
		local v232 = cloneChar:FindFirstChildWhichIsA("Humanoid")
		if v232 then
			local v233 = originalHipHeight * sizeScale.heightScale - 0.5
			v232.HipHeight = math.max(v233, 0.2)
			local v234, v235, v236 = pairs(originalPartSizes)
			while true do
				local v237
				v236, v237 = v234(v235, v236)
				if v236 == nil then
					break
				end
				if v236 and v236:IsA("BasePart") then
					v236.Size = Vector3.new(v237.X * sizeScale.widthScale, v237.Y * sizeScale.heightScale, v237.Z * sizeScale.widthScale)
				end
			end
			local v238, v239, v240 = pairs(originalMotorData)
			while true do
				local v241
				v240, v241 = v238(v239, v240)
				if v240 == nil then
					break
				end
				if v240 and v240:IsA("Motor6D") then
					local v242 = v241.C0.Position
					local v243 = Vector3.new(v242.X * sizeScale.widthScale, v242.Y * sizeScale.heightScale, v242.Z * sizeScale.widthScale)
					v240.C0 = CFrame.new(v243) * (v241.C0 - v241.C0.Position)
					local v244 = v241.C1.Position
					local v245 = Vector3.new(v244.X * sizeScale.widthScale, v244.Y * sizeScale.heightScale, v244.Z * sizeScale.widthScale)
					v240.C1 = CFrame.new(v245) * (v241.C1 - v241.C1.Position)
				end
			end
		end
	else
		return
	end
end
local function disableHeadMovement()
	pcall(function()
		local v247 = Workspace:FindFirstChild("VirtuallyNad")
		if v247 then
			local v248 = v247:FindFirstChild("HeadMovement")
			if v248 and v248:IsA("LocalScript") then
				v248.Disabled = true
			end
		end
		LocalPlayer:SetAttribute("TurnHead", false)
	end)
end
local function enableHeadMovement()
	pcall(function()
		local v250 = Workspace:FindFirstChild("VirtuallyNad")
		if v250 then
			local v251 = v250:FindFirstChild("HeadMovement")
			if v251 and v251:IsA("LocalScript") then
				v251.Disabled = false
			end
		end
	end)
end
local pendingReanimState = nil
local reanimBusy = false
local function setReanimEnabled(p254)
	if reanimBusy then return end
	reanimBusy = true
	local MicUpFolderNames = {
		"click_the_player",
		"input",
		"map",
		"picture_to_avatar",
		"vr"
	}
	local PlayerGuiRef  = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
	local StorageRef    = game:GetService("ReplicatedStorage"):FindFirstChild("Storage")
		or game:GetService("ReplicatedStorage")

	if PlayerGuiRef then
		for _, guiChild in ipairs(PlayerGuiRef:GetChildren()) do
			if guiChild:IsA("Folder") and table.find(MicUpFolderNames, guiChild.Name) then
				if not StorageRef:FindFirstChild(guiChild.Name) then
					local savedFolder = guiChild:Clone()
					savedFolder.Parent = StorageRef
				end
			end
		end
	end

	RunService.Heartbeat:Connect(function()
		if not PlayerGuiRef then return end
		for _, storedFolder in ipairs(StorageRef:GetChildren()) do
			if storedFolder:IsA("Folder") and table.find(MicUpFolderNames, storedFolder.Name) then
				if not PlayerGuiRef:FindFirstChild(storedFolder.Name) then
					local restoredFolder = storedFolder:Clone()
					restoredFolder.Parent = PlayerGuiRef
				end
			end
		end
	end)

	reanimEnabled = p254
	local v_u_255 = game:GetService("ReplicatedStorage"):FindFirstChild("event_rag")
	local v_u_256 = game:GetService("ReplicatedStorage"):FindFirstChild("Ragdoll")
	local v_u_257 = game:GetService("ReplicatedStorage"):FindFirstChild("Unragdoll")
	local v_u_258 = nil
	if not (v_u_255 or v_u_256) then
		local v261, v262 = pcall(function()
			local v259 = ReplicatedStorage:FindFirstChild("LocalModules", true)
			local v260 = v259 and v259:FindFirstChild("Backend")
			if v260 then
				local _ = require
				local _ = v260.FindFirstChild
			end
		end)
		v_u_258 = v261 and v262 and v262 or v_u_258
	end
	if reanimEnabled then
		local v263 = LocalPlayer.Character
		if not v263 then
			return
		end
		local v264 = v263:FindFirstChildOfClass("Humanoid")
		local v265 = v263:FindFirstChild("HumanoidRootPart")
		if not (v264 and v265) then
			return
		end
		originalChar = v263
		savedRootCFrame = v265.CFrame
		v263.Archivable = true
		cloneChar = v263:Clone()
		v263.Archivable = false
		local v266 = originalChar.Name
		cloneChar.Name = v266 .. "Celeste"
		local v267 = cloneChar:FindFirstChildWhichIsA("Humanoid")
		if v267 then
			v267.DisplayName = v266 .. "Celeste"
			originalHipHeight = v267.HipHeight
			sizeScale = {
				["heightScale"] = 1,
				["widthScale"] = 1
			}
			v267.WalkSpeed = v264.WalkSpeed
			v267.JumpPower = v264.JumpPower
		end
		local v268 = not cloneChar.PrimaryPart and cloneChar:FindFirstChild("HumanoidRootPart")
		if v268 then
			cloneChar.PrimaryPart = v268
		end
		hideCloneChar()
		originalPartSizes = {}
		originalMotorData = {}
		local v269 = cloneChar
		local v270, v271, v272 = ipairs(v269:GetDescendants())
		while true do
			local v273
			v272, v273 = v270(v271, v272)
			if v272 == nil then
				break
			end
			if v273:IsA("BasePart") then
				originalPartSizes[v273] = v273.Size
			elseif v273:IsA("Motor6D") then
				originalMotorData[v273] = {
					["C0"] = v273.C0,
					["C1"] = v273.C1
				}
			end
		end
		local v274 = originalChar:FindFirstChild("Animate")
		if v274 then
			animateScript = v274:Clone()
			animateScript.Parent = cloneChar
			animateScript.Disabled = true
		end
		disableGuiReset()
		cloneChar.Parent = Workspace
		LocalPlayer.Character = cloneChar
		if v267 then
			Workspace.CurrentCamera.CameraSubject = v267
		end
		restoreGuiReset()
		if animateScript then
			animateScript.Disabled = false
		end
		if v267 then
			v267:ChangeState(Enum.HumanoidStateType.Running)
		end
		task.spawn(function()
			if reanimEnabled then
				if v_u_255 then
					pcall(function()
						local v275 = game:GetService("ReplicatedStorage"):FindFirstChild("event_rag")
						if v275 then
							local v276 = originalChar and (originalChar:FindFirstChildOfClass("Humanoid") and originalChar:FindFirstChildOfClass("Humanoid"))
							if v276 then
								game.Players.LocalPlayer.Character.Humanoid.HipHeight = v276.HipHeight
							end
							v275:FireServer(unpack({ "Hinge" }))
						end
					end)
				elseif v_u_256 then
					pcall(function()
						local v277 = game:GetService("ReplicatedStorage"):FindFirstChild("Ragdoll")
						if v277 then
							v277:FireServer(unpack({ "Ball" }))
						end
					end)
				elseif v_u_258 then
					pcall(function()
						v_u_258.Ragdoll:Fire(true)
						disableHeadMovement()
					end)
				end
				if heartbeatConnection then
					heartbeatConnection:Disconnect()
				end
				heartbeatConnection = RunService.Heartbeat:Connect(updateHeartbeat)
				reanimBusy = false
			end
		end)
	else
		local v278, v279, v280 = pairs(stateConnections)
		while true do
			local v281
			v280, v281 = v278(v279, v280)
			if v280 == nil then
				break
			end
			if v281 then
				v281:Disconnect()
			end
		end
		stateConnections = {}
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
		if animPlayback.connection then
			animPlayback.connection:Disconnect()
			animPlayback.connection = nil
		end
		animPlayback.isRunning = false
		if not (originalChar and cloneChar) then
			return
		end
		for _ = 1, 3 do
			pcall(function()
				if v_u_255 then
					local v282 = game:GetService("ReplicatedStorage"):FindFirstChild("event_rag")
					if v282 then
						v282:FireServer(unpack({ "Hinge" }))
					end
				elseif v_u_257 then
					local v283 = game:GetService("ReplicatedStorage"):FindFirstChild("Unragdoll")
					if v283 then
						v283:FireServer()
					end
				elseif v_u_258 then
					v_u_258.Ragdoll:Fire(false)
					enableHeadMovement()
				end
			end)
			task.wait(0.1)
		end
		local v284 = originalChar:FindFirstChild("HumanoidRootPart")
		local v285 = cloneChar:FindFirstChild("HumanoidRootPart")
		local v286 = v285 and v285.CFrame or savedRootCFrame
		local v287 = cloneChar:FindFirstChild("Animate")
		if v287 then
			v287.Parent = originalChar
			v287.Disabled = true
		end
		cloneChar:Destroy()
		if v284 then
			v284.CFrame = v286
		end
		local v288 = originalChar:FindFirstChildWhichIsA("Humanoid")
		disableGuiReset()
		LocalPlayer.Character = originalChar
		if v288 then
			Workspace.CurrentCamera.CameraSubject = v288
		end
		restoreGuiReset()
		if v287 then
			task.wait(0.1)
			v287.Disabled = false
		end
		pendingReanimState = nil
		reanimBusy = false
	end
	reanimBusy = false
end
local animEntryRefs = {}
local function stopAnimation()
	animPlayback.isRunning = false
	if cloneChar then
		local v291, v292, v293 = pairs(originalMotorData)
		while true do
			local v294
			v293, v294 = v291(v292, v293)
			if v293 == nil then
				break
			end
			if v293 and v293:IsA("Motor6D") then
				v293.C0 = v294.C0
			end
		end
		local v295 = cloneChar
		local v296, v297, v298 = pairs(v295:GetChildren())
		while true do
			local v299
			v298, v299 = v296(v297, v298)
			if v298 == nil then
				break
			end
			if v299:IsA("LocalScript") and (not v299.Enabled and v299 ~= animateScript) then
				v299.Enabled = true
			end
		end
		if animateScript then
			animateScript.Disabled = false
		end
	end
	if animPlayback.connection then
		animPlayback.connection:Disconnect()
		animPlayback.connection = nil
	end
	local v300, v301, v302 = pairs(animEntryRefs)
	while true do
		local v303
		v302, v303 = v300(v301, v302)
		if v302 == nil then
			break
		end
		-- Silver/dark reset color for black-silver theme
		v303.NameButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	end
end
local function playAnimation(p_u_305)
	if not cloneChar then
		warn("Reanimate first!")
		return
	end
	if p_u_305 == "" then
		return
	end
	local v306 = cloneChar:FindFirstChildWhichIsA("Humanoid")
	if not v306 then
		return
	end
	local v307 = cloneChar:FindFirstChild("LowerTorso") ~= nil
	if not (v307 and cloneChar:FindFirstChild("LowerTorso") or cloneChar:FindFirstChild("Torso")) then
		return
	end
	if animPlayback.isRunning and animPlayback.currentId == p_u_305 then
		stopAnimation()
		animPlayback.currentId = nil
		return
	end
	local v308, v309, v310 = pairs(animEntryRefs)
	while true do
		local v311
		v310, v311 = v308(v309, v310)
		if v310 == nil then
			break
		end
		v311.NameButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	end
	local v312 = { animationList, favoriteAnims }
	local v313, v314, v315 = pairs(v312)
	local v316 = nil
	while true do
		local v317
		v315, v317 = v313(v314, v315)
		if v315 == nil then
			v320 = v316
		end
		local v318, v319, v320 = pairs(v317)
		while true do
			local v321
			v320, v321 = v318(v319, v320)
			if v320 == nil then
				v320 = v316
				break
			end
			if tostring(v321) == p_u_305 then
				break
			end
		end
		if v320 then
			break
		end
		v316 = v320
	end
	if v320 and animEntryRefs[v320] then
		-- Silver/active highlight for playing anim
		animEntryRefs[v320].NameButton.BackgroundColor3 = Color3.fromRGB(160, 160, 175)
	end
	if animateScript and (v306.MoveDirection.Magnitude > 0 or v306:GetState() == Enum.HumanoidStateType.Running) then
		animateScript.Disabled = true
		local v322, v323, v324 = pairs(v306:GetPlayingAnimationTracks())
		while true do
			local v325
			v324, v325 = v322(v323, v324)
			if v324 == nil then
				break
			end
			v325:Stop()
		end
	end
	local v326 = animationCache[p_u_305]
	if not v326 then
		local v327 = nil
		local v328 = nil
		if tostring(p_u_305):match("^http") then
			local v329, v_u_330 = pcall(function()
				return game:HttpGet(p_u_305)
			end)
			if v329 then
				local v331
				v331, v326 = pcall(function()
					return loadstring(v_u_330)()
				end)
				if v331 and type(v326) == "table" then
					v327 = true
				else
					v326 = v328
				end
			else
				v326 = v328
			end
		elseif tonumber(p_u_305) then
			-- Fire GetObjects on a separate thread so the click feels instant;
			-- if already cached on retry it returns immediately
			if not animationCache[p_u_305] then
				task.spawn(function()
					local ok, result = pcall(function()
						return game:GetObjects("rbxassetid://" .. p_u_305)[1]
					end)
					if ok and result then
						animationCache[p_u_305] = result
					end
				end)
				-- Try a fast synchronous load as well (returns from cache if Studio-side cached)
				v327, v326 = pcall(function()
					return game:GetObjects("rbxassetid://" .. p_u_305)[1]
				end)
			else
				v327 = true
				v326 = animationCache[p_u_305]
			end
		else
			local v332
			v332, v326 = pcall(function()
				return loadstring(p_u_305)()
			end)
			if v332 and type(v326) == "table" then
				v327 = true
			else
				v326 = v328
			end
		end
		if not (v327 and v326) then
			return
		end
		animationCache[p_u_305] = v326
	end
	if type(v326) ~= "table" then
		v326.Priority = Enum.AnimationPriority.Action
		animPlayback.keyframes = v326:GetKeyframes()
		if not animPlayback.keyframes or #animPlayback.keyframes == 0 then
			return
		end
		animPlayback.totalDuration = animPlayback.keyframes[#animPlayback.keyframes].Time
	else
		local v333 = next(v326)
		if not v333 then
			return
		end
		animPlayback.keyframes = v326[v333]
		if not animPlayback.keyframes or #animPlayback.keyframes == 0 then
			return
		end
		animPlayback.totalDuration = animPlayback.keyframes[#animPlayback.keyframes].Time
	end
	animPlayback.currentId = p_u_305
	animPlayback.elapsedTime = 0
	animPlayback.isRunning = true
	local v334 = cloneChar
	local v335
	if v307 then
		local v336 = v334:FindFirstChild("HumanoidRootPart")
		local v337 = v334:FindFirstChild("Head")
		local v338 = v334:FindFirstChild("LeftUpperArm")
		local v339 = v334:FindFirstChild("RightUpperArm")
		local v340 = v334:FindFirstChild("LeftUpperLeg")
		local v341 = v334:FindFirstChild("RightUpperLeg")
		local v342 = v334:FindFirstChild("LeftFoot")
		local v343 = v334:FindFirstChild("RightFoot")
		local v344 = v334:FindFirstChild("LeftHand")
		local v345 = v334:FindFirstChild("RightHand")
		local v346 = v334:FindFirstChild("LeftLowerArm")
		local v347 = v334:FindFirstChild("RightLowerArm")
		local v348 = v334:FindFirstChild("LeftLowerLeg")
		local v349 = v334:FindFirstChild("RightLowerLeg")
		local v350 = v334:FindFirstChild("LowerTorso")
		local v351 = v334:FindFirstChild("UpperTorso")
		v335 = {}
		if v336 then
			v336 = v336:FindFirstChild("RootJoint")
		end
		v335.Torso = v336
		if v337 then
			v337 = v337:FindFirstChild("Neck")
		end
		v335.Head = v337
		if v338 then
			v338 = v338:FindFirstChild("LeftShoulder")
		end
		v335.LeftUpperArm = v338
		if v339 then
			v339 = v339:FindFirstChild("RightShoulder")
		end
		v335.RightUpperArm = v339
		if v340 then
			v340 = v340:FindFirstChild("LeftHip")
		end
		v335.LeftUpperLeg = v340
		if v341 then
			v341 = v341:FindFirstChild("RightHip")
		end
		v335.RightUpperLeg = v341
		if v342 then
			v342 = v342:FindFirstChild("LeftAnkle")
		end
		v335.LeftFoot = v342
		if v343 then
			v343 = v343:FindFirstChild("RightAnkle")
		end
		v335.RightFoot = v343
		if v344 then
			v344 = v344:FindFirstChild("LeftWrist")
		end
		v335.LeftHand = v344
		if v345 then
			v345 = v345:FindFirstChild("RightWrist")
		end
		v335.RightHand = v345
		if v346 then
			v346 = v346:FindFirstChild("LeftElbow")
		end
		v335.LeftLowerArm = v346
		if v347 then
			v347 = v347:FindFirstChild("RightElbow")
		end
		v335.RightLowerArm = v347
		if v348 then
			v348 = v348:FindFirstChild("LeftKnee")
		end
		v335.LeftLowerLeg = v348
		if v349 then
			v349 = v349:FindFirstChild("RightKnee")
		end
		v335.RightLowerLeg = v349
		if v350 then
			v350 = v350:FindFirstChild("Root")
		end
		v335.LowerTorso = v350
		if v351 then
			v351 = v351:FindFirstChild("Waist")
		end
		v335.UpperTorso = v351
	else
		v335 = (function(p352)
			local v353, v354, v355 = pairs(p352:GetChildren())
			local v356 = {}
			while true do
				local v357
				v355, v357 = v353(v354, v355)
				if v355 == nil then
					break
				end
				if v357:IsA("BasePart") then
					local v358, v359, v360 = pairs(v357:GetChildren())
					while true do
						local v361
						v360, v361 = v358(v359, v360)
						if v360 == nil then
							break
						end
						if v361:IsA("Motor6D") and (v361.Part1 and v361.Part1.Parent == p352) then
							local v362 = v361.Part1.Name
							v356[v362] = v361
							if v362 == "Left Arm" then
								v356.LeftArm = v361
							elseif v362 == "Right Arm" then
								v356.RightArm = v361
							elseif v362 == "Left Leg" then
								v356.LeftLeg = v361
							elseif v362 == "Right Leg" then
								v356.RightLeg = v361
							elseif v362 == "Head" then
								v356.Head = v361
							elseif v362 == "HumanoidRootPart" then
								v356.Torso = v361
							end
						end
					end
				end
			end
			return v356
		end)(v334)
	end
	local v_u_363 = {}
	if not originalMotorData then
		originalMotorData = {}
	end
	local v364, v365, v366 = pairs(v335)
	while true do
		local v367
		v366, v367 = v364(v365, v366)
		if v366 == nil then
			break
		end
		if v367 and v367:IsA("Motor6D") then
			v_u_363[v366] = v367
			if not originalMotorData[v367] then
				originalMotorData[v367] = {
					["C0"] = v367.C0,
					["C1"] = v367.C1
				}
			end
		end
	end
	if not animPlayback.connection then
		local v368 = cloneChar
		local v369, v370, v371 = pairs(v368:GetChildren())
		while true do
			local v372
			v371, v372 = v369(v370, v371)
			if v371 == nil then
				break
			end
			if v372:IsA("LocalScript") and (v372.Enabled and v372 ~= animateScript) then
				v372.Enabled = false
			end
		end
		animPlayback.connection = RunService.Heartbeat:Connect(function(p373)
			if not (animPlayback.isRunning and cloneChar) then
				stopAnimation()
				return
			end
			if not animPlayback.keyframes then
				return
			end
			animPlayback.elapsedTime = animPlayback.elapsedTime + p373 * animPlayback.speed
			if animPlayback.totalDuration > 0 then
				animPlayback.elapsedTime = animPlayback.elapsedTime % animPlayback.totalDuration
			end
			local v374 = nil
			local v375 = nil
			for v376 = 1, #animPlayback.keyframes - 1 do
				if animPlayback.elapsedTime >= animPlayback.keyframes[v376].Time then
					if animPlayback.elapsedTime < animPlayback.keyframes[v376 + 1].Time then
						v374 = animPlayback.keyframes[v376]
						v375 = animPlayback.keyframes[v376 + 1]
						break
					end
				end
			end
			if not v374 then
				v374 = animPlayback.keyframes[#animPlayback.keyframes]
				v375 = animPlayback.keyframes[1]
			end
			local v377 = v375.Time - v374.Time
			if v377 <= 0 then
				v377 = animPlayback.totalDuration
			end
			local v378 = animPlayback.elapsedTime - v374.Time
			local v379 = 0 < v377 and v378 / v377 or 0
			local v380 = math.clamp(v379, 0, 1)
			if v374.Data then
				local v381, v382, v383 = pairs(v374.Data)
				while true do
					local v384
					v383, v384 = v381(v382, v383)
					if v383 == nil then
						break
					end
					local v385 = v_u_363[v383]
					if v385 and (originalMotorData and originalMotorData[v385]) then
						local v386 = originalMotorData[v385].C0 * v384
						local v387 = v375.Data
						if v387 then
							v387 = v375.Data[v383]
						end
						if v387 then
							v385.C0 = v386:Lerp(originalMotorData[v385].C0 * v387, v380)
						else
							v385.C0 = v386
						end
					end
				end
			else
				local v388, v389, v390 = pairs(v374:GetDescendants())
				while true do
					local v391
					v390, v391 = v388(v389, v390)
					if v390 == nil then
						break
					end
					if v391:IsA("Pose") then
						local v392 = v_u_363[v391.Name]
						if v392 and (originalMotorData and originalMotorData[v392]) then
							local v393 = originalMotorData[v392].C0 * v391.CFrame
							local v394 = v375:FindFirstChild(v391.Name, true)
							if v394 and v394:IsA("Pose") then
								v392.C0 = v393:Lerp(originalMotorData[v392].C0 * v394.CFrame, v380)
							else
								v392.C0 = v393
							end
						end
					end
				end
			end
			if sizeScale.heightScale ~= 1 or sizeScale.widthScale ~= 1 then
				local v395, v396, v397 = pairs(originalMotorData)
				while true do
					local v398
					v397, v398 = v395(v396, v397)
					if v397 == nil then
						break
					end
					if v397 and v397:IsA("Motor6D") then
						local v399 = v397.C0 - v397.C0.Position
						local v400 = v398.C0.Position
						local v401 = Vector3.new(v400.X * sizeScale.widthScale, v400.Y * sizeScale.heightScale, v400.Z * sizeScale.widthScale)
						v397.C0 = CFrame.new(v401) * v399
					end
				end
			end
		end)
	end
end
local function playStateAnim(p403)
	if not (cloneChar and reanimEnabled) then
		return
	end
	local v_u_404 = stateAnimations[p403]
	local v405 = false
	if animPlayback.isRunning and animPlayback.currentId then
		local v406, v407, v408 = pairs(stateAnimations)
		while true do
			local v409
			v408, v409 = v406(v407, v408)
			if v408 == nil then
				break
			end
			if v409 and (v409 ~= "" and tostring(v409) == tostring(animPlayback.currentId)) then
				v405 = true
				break
			end
		end
	end
	if v_u_404 and v_u_404 ~= "" then
		if cloneChar then
			if cloneChar:FindFirstChildWhichIsA("Humanoid") then
				if animPlayback.isRunning and animPlayback.currentId then
					if not v405 then
						return
					end
					if tostring(animPlayback.currentId) == tostring(v_u_404) then
						return
					end
				end
				if animPlayback.isRunning then
					stopAnimation()
					task.wait(0.05)
				end
				if cloneChar and reanimEnabled then
					pcall(function()
						playAnimation(tostring(v_u_404))
					end)
				end
			else
				return
			end
		else
			return
		end
	else
		if v405 then
			stopAnimation()
		end
		return
	end
end
local function setupStateMonitor()
	if not (cloneChar and reanimEnabled) then
		return
	end
	if not cloneChar:FindFirstChildWhichIsA("Humanoid") then
		return
	end
	local v411, v412, v413 = pairs(stateConnections)
	while true do
		local v414, v_u_415 = v411(v412, v413)
		if v414 == nil then
			break
		end
		v413 = v414
		if v_u_415 then
			pcall(function()
				v_u_415:Disconnect()
			end)
		end
	end
	stateConnections = {}
	if animPlayback.isRunning and animPlayback.currentId then
		local v416, v417, v418 = pairs(stateAnimations)
		while true do
			local v419
			v418, v419 = v416(v417, v418)
			if v418 == nil then
				break
			end
			if v419 and (v419 ~= "" and tostring(v419) == tostring(animPlayback.currentId)) then
				stopAnimation()
				break
			end
		end
	end
	local function v_u_424()
		if not cloneChar then
			return "idle"
		end
		local v_u_420 = cloneChar:FindFirstChildWhichIsA("Humanoid")
		if not v_u_420 then
			return "idle"
		end
		local v421 = v_u_420.MoveDirection.Magnitude
		local v422, v423 = pcall(function()
			return v_u_420:GetState()
		end)
		return v422 and ((v423 == Enum.HumanoidStateType.Jumping or v423 == Enum.HumanoidStateType.Freefall) and "jumping" or (0.1 < v421 and "walking" or "idle")) or "idle"
	end
	local v_u_425 = v_u_424()
	local v_u_426 = v_u_425
	local v_u_427 = v_u_425
	if stateAnimations[v_u_425] and stateAnimations[v_u_425] ~= "" then
		task.defer(function()
			if cloneChar and reanimEnabled then
				playStateAnim(v_u_425)
			end
		end)
	end
	stateConnections.stateMonitor = RunService.Heartbeat:Connect(function(_)
		if not (cloneChar and reanimEnabled) then
			if stateConnections.stateMonitor then
				pcall(function()
					stateConnections.stateMonitor:Disconnect()
				end)
				stateConnections.stateMonitor = nil
			end
			return
		end
		if not cloneChar:FindFirstChildWhichIsA("Humanoid") then
			if stateConnections.stateMonitor then
				pcall(function()
					stateConnections.stateMonitor:Disconnect()
				end)
				stateConnections.stateMonitor = nil
			end
			return
		end
		local v_u_428 = v_u_424()
		if v_u_428 ~= v_u_427 then
			v_u_427 = v_u_428
			local v429 = false
			if animPlayback.isRunning and animPlayback.currentId then
				local v430, v431, v432 = pairs(stateAnimations)
				while true do
					local v433
					v432, v433 = v430(v431, v432)
					if v432 == nil then
						break
					end
					if v433 and (v433 ~= "" and tostring(v433) == tostring(animPlayback.currentId)) then
						v429 = true
						break
					end
				end
			end
			if v429 then
				stopAnimation()
			end
			if stateAnimations[v_u_428] and (stateAnimations[v_u_428] ~= "" and (cloneChar and reanimEnabled)) then
				task.defer(function()
					if cloneChar and reanimEnabled then
						playStateAnim(v_u_428)
					end
				end)
			end
		end
		v_u_426 = v_u_428
		if (sizeScale.heightScale ~= 1 or sizeScale.widthScale ~= 1) and originalMotorData then
			local v434, v435, v436 = pairs(originalMotorData)
			while true do
				local v437
				v436, v437 = v434(v435, v436)
				if v436 == nil then
					break
				end
				if v436 and (v436:IsA("Motor6D") and v436.Parent) then
					local v438 = v436.C0 - v436.C0.Position
					local v439 = v437.C0.Position
					local v440 = Vector3.new(v439.X * sizeScale.widthScale, v439.Y * sizeScale.heightScale, v439.Z * sizeScale.widthScale)
					v436.C0 = CFrame.new(v440) * v438
				end
			end
		end
	end)
end

-- GUI BUILD  —  Black & Silver Theme
local function buildGui()

	local C = {
		-- Backgrounds — black base with subtle grey buttons
		panelBg      = Color3.fromRGB(0, 0, 0),        -- main panel (pure black)
		panelBg2     = Color3.fromRGB(0, 0, 0),        -- secondary panels (pure black)
		rowBg        = Color3.fromRGB(28, 28, 30),     -- list rows (subtle dark grey)
		rowBgHover   = Color3.fromRGB(50, 50, 55),     -- row hover
		tabActive    = Color3.fromRGB(50, 50, 55),     -- selected tab pill (visible grey)
		tabIdle      = Color3.fromRGB(22, 22, 24),     -- unselected tab (very dark grey)
		inputBg      = Color3.fromRGB(18, 18, 20),     -- text boxes / search (near-black)
		toggleOff    = Color3.fromRGB(50, 52, 65),     -- toggle off
		accentPlay   = Color3.fromRGB(200, 210, 235),  -- playing anim highlight
		btnBg        = Color3.fromRGB(28, 28, 30),     -- generic button (subtle grey)

		-- Text — bright silver for maximum readability
		textPrimary  = Color3.fromRGB(235, 238, 248),-- main text (bright silver-white)
		textSecond   = Color3.fromRGB(180, 185, 205),-- secondary (mid silver)
		textDim      = Color3.fromRGB(115, 120, 140),-- dim/placeholder
		textGold     = Color3.fromRGB(255, 215, 80), -- favorites star
		textRed      = Color3.fromRGB(240, 80,  80), -- delete / error
		textGreen    = Color3.fromRGB(100, 220, 130),-- success
		textYellow   = Color3.fromRGB(240, 210, 80), -- warning / binding

		-- Scrollbar
		scrollbar    = Color3.fromRGB(145, 150, 170),

		-- Toggle on (bright silver-blue)
		toggleOn     = Color3.fromRGB(145, 160, 210),
		knobOff      = Color3.fromRGB(105, 110, 130),
		knobOn       = Color3.fromRGB(235, 240, 255),

		-- Borders
		stroke       = Color3.fromRGB(70, 75, 95),
		strokeBright = Color3.fromRGB(120, 128, 155),
	}

	local ALPHA = {
		panel   = 0.0,    -- main frame: fully solid
		panel2  = 0.0,
		row     = 0.0,
		rowH    = 0.0,
		tab     = 0.0,
		tabA    = 0.0,
		input   = 0.0,
		btn     = 0.0,
		btnH    = 0.2,
		overlay = 0.0,
	}

	local v442 = LocalPlayer:WaitForChild("PlayerGui")
	if not v442:FindFirstChild("AKReanimGUI") then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "AKReanimGUI"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = v442

		local mainFrame = Instance.new("Frame")
		mainFrame.Size = UDim2.new(0, 315, 0, 480)
		mainFrame.Position = UDim2.new(1, -330, 0, 20)
		mainFrame.BackgroundColor3 = C.panelBg
		mainFrame.BackgroundTransparency = ALPHA.panel
		mainFrame.BorderSizePixel = 0
		mainFrame.Parent = screenGui

		-- Panel border stroke — bright silver like screenshot
		local mainStroke = Instance.new("UIStroke")
		mainStroke.Color = Color3.fromRGB(160, 168, 200)
		mainStroke.Thickness = 1
		mainStroke.Transparency = 0.0
		mainStroke.Parent = mainFrame

		local v445 = Instance.new("UICorner")
		v445.CornerRadius = UDim.new(0, 12)
		v445.Parent = mainFrame

		local headerBar = Instance.new("Frame")
		headerBar.Size = UDim2.new(1, 0, 0, 30)
		headerBar.Position = UDim2.new(0, 0, 0, 0)
		headerBar.BackgroundColor3 = C.panelBg2
		headerBar.BackgroundTransparency = ALPHA.panel2
		headerBar.BorderSizePixel = 0
		headerBar.Parent = mainFrame
		local headerStroke = Instance.new("UIStroke")
		headerStroke.Color = C.stroke
		headerStroke.Thickness = 1
		headerStroke.Transparency = 0.4
		headerStroke.Parent = headerBar
		local headerCorner = Instance.new("UICorner")
		headerCorner.CornerRadius = UDim.new(0, 12)
		headerCorner.Parent = headerBar

		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(1, -110, 1, 0)
		titleLabel.Position = UDim2.new(0, 52, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "AC REANIM"
		titleLabel.TextColor3 = C.textPrimary
		titleLabel.TextSize = 16
		titleLabel.Font = Enum.Font.GothamBlack
		titleLabel.TextXAlignment = Enum.TextXAlignment.Center
		titleLabel.Parent = headerBar

		-- Player ID badge
		local idLabel = Instance.new("TextLabel")
		idLabel.Size = UDim2.new(0, 80, 0, 14)
		idLabel.Position = UDim2.new(0, 52, 0.5, 4)
		idLabel.BackgroundTransparency = 1
		idLabel.Text = "ID: " .. playerID
		idLabel.TextColor3 = C.textDim
		idLabel.TextSize = 8
		idLabel.Font = Enum.Font.Gotham
		idLabel.TextXAlignment = Enum.TextXAlignment.Center
		idLabel.Parent = headerBar

		local reanimToggleBg = Instance.new("TextButton")
		reanimToggleBg.Size = UDim2.new(0, 65, 0, 24)
		reanimToggleBg.Position = UDim2.new(0, 6, 0, 3)
		reanimToggleBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		reanimToggleBg.BackgroundTransparency = 0
		reanimToggleBg.BorderSizePixel = 0
		reanimToggleBg.Text = "OFF"
		reanimToggleBg.TextColor3 = C.textPrimary
		reanimToggleBg.TextSize = 13
		reanimToggleBg.Font = Enum.Font.GothamBold
		reanimToggleBg.Parent = headerBar

		local tgCorner = Instance.new("UICorner")
		tgCorner.CornerRadius = UDim.new(0, 7)
		tgCorner.Parent = reanimToggleBg

		local tgStroke = Instance.new("UIStroke")
		tgStroke.Color = Color3.fromRGB(120, 128, 155)
		tgStroke.Thickness = 1
		tgStroke.Parent = reanimToggleBg

		-- dummy knob (unused but kept so references below don't break)
		local reanimToggleKnob = Instance.new("Frame")
		reanimToggleKnob.Size = UDim2.new(0, 0, 0, 0)
		reanimToggleKnob.BackgroundTransparency = 1
		reanimToggleKnob.Parent = reanimToggleBg

		local reanimToggleBtn = reanimToggleBg  -- same object handles clicks

		local reanimToggleState = false

		reanimToggleBg.MouseButton1Click:Connect(function()
			if reanimBusy then return end
			reanimToggleState = not reanimToggleState
			if reanimToggleState then
				reanimToggleBg.Text = "ON"
				reanimToggleBg.BackgroundColor3 = Color3.fromRGB(145, 160, 210)
			else
				reanimToggleBg.Text = "OFF"
				reanimToggleBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			end
			task.defer(function()
				setReanimEnabled(reanimToggleState)
				if reanimToggleState then
					task.spawn(function()
						task.wait(0.3)
						if reanimEnabled and cloneChar then
							setupStateMonitor()
						end
					end)
				end
			end)
		end)

		local minimizeBtn = Instance.new("TextButton")
		minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
		minimizeBtn.Position = UDim2.new(1, -48, 0, 4)
		minimizeBtn.BackgroundColor3 = C.btnBg
		minimizeBtn.BackgroundTransparency = ALPHA.btn
		minimizeBtn.Text = "-"
		minimizeBtn.TextColor3 = C.textPrimary
		minimizeBtn.TextScaled = true
		minimizeBtn.Font = Enum.Font.GothamBlack
		minimizeBtn.BorderSizePixel = 0
		minimizeBtn.Parent = headerBar

		local v459 = Instance.new("UICorner")
		v459.CornerRadius = UDim.new(0, 7)
		v459.Parent = minimizeBtn

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 22, 0, 22)
		closeBtn.Position = UDim2.new(1, -24, 0, 4)
		closeBtn.BackgroundColor3 = C.btnBg
		closeBtn.BackgroundTransparency = ALPHA.btn
		closeBtn.Text = "X"
		closeBtn.TextColor3 = C.textPrimary
		closeBtn.TextScaled = true
		closeBtn.Font = Enum.Font.Gotham
		closeBtn.BorderSizePixel = 0
		closeBtn.Parent = headerBar

		local v461 = Instance.new("UICorner")
		v461.CornerRadius = UDim.new(0, 7)
		v461.Parent = closeBtn

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(1, -16, 0, 12)
		statusLabel.Position = UDim2.new(0, 8, 0, 32)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "Ready | " .. playerFolder
		statusLabel.TextColor3 = C.textDim
		statusLabel.TextSize = 10
		statusLabel.Font = Enum.Font.GothamSemibold
		statusLabel.Parent = mainFrame

		local tabBar = Instance.new("Frame")
		tabBar.Size = UDim2.new(1, -16, 0, 24)
		tabBar.Position = UDim2.new(0, 8, 0, 47)
		tabBar.BackgroundTransparency = 1
		tabBar.Parent = mainFrame

		local tabNames = { "All", "Favs", "Custom", "States", "Size", "Others" }
		local tabKeys  = { "all", "favorites", "custom", "states", "size", "others" }
		local tabBtns  = {}
		local tabW = 1 / #tabNames
		for i, tName in ipairs(tabNames) do
			local tb = Instance.new("TextButton")
			tb.Size = UDim2.new(tabW, -2, 1, 0)
			tb.Position = UDim2.new((i - 1) * tabW, (i == 1 and 0 or 2), 0, 0)
			tb.BackgroundColor3 = i == 1 and C.tabActive or C.tabIdle
			tb.BackgroundTransparency = i == 1 and ALPHA.tabA or ALPHA.tab
			tb.Text = tName
			tb.TextColor3 = i == 1 and C.textPrimary or C.textSecond
			tb.TextSize = 11
			tb.Font = Enum.Font.GothamBold
			tb.BorderSizePixel = 0
			tb.Parent = tabBar
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 7)
			corner.Parent = tb
			tabBtns[tabKeys[i]] = tb
		end

		local searchBox = Instance.new("TextBox")
		searchBox.Size = UDim2.new(1, -16, 0, 22)
		searchBox.Position = UDim2.new(0, 8, 0, 76)
		searchBox.BackgroundColor3 = C.inputBg
		searchBox.BackgroundTransparency = ALPHA.input
		searchBox.Text = ""
		searchBox.PlaceholderText = "Search..."
		searchBox.TextColor3 = C.textPrimary
		searchBox.PlaceholderColor3 = C.textDim
		searchBox.TextSize = 12
		searchBox.Font = Enum.Font.GothamSemibold
		searchBox.BorderSizePixel = 0
		searchBox.Parent = mainFrame

		local sbStroke = Instance.new("UIStroke")
		sbStroke.Color = Color3.fromRGB(90, 96, 120)
		sbStroke.Thickness = 1
		sbStroke.Transparency = 0.0
		sbStroke.Parent = searchBox

		local v477 = Instance.new("UICorner")
		v477.CornerRadius = UDim.new(0, 8)
		v477.Parent = searchBox

		local animScrollFrame = Instance.new("ScrollingFrame")
		animScrollFrame.Size = UDim2.new(1, -16, 1, -175)
		animScrollFrame.Position = UDim2.new(0, 8, 0, 104)
		animScrollFrame.BackgroundTransparency = 1
		animScrollFrame.ScrollBarThickness = 3
		animScrollFrame.ScrollBarImageColor3 = C.scrollbar
		animScrollFrame.ScrollBarImageTransparency = 0.3
		animScrollFrame.BorderSizePixel = 0
		animScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
		animScrollFrame.Parent = mainFrame

		local animListLayout = Instance.new("UIListLayout")
		animListLayout.Padding = UDim.new(0, 3)
		animListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		animListLayout.Parent = animScrollFrame

		local addAnimPanel = Instance.new("Frame")
		addAnimPanel.Size = UDim2.new(1, -16, 0, 80)
		addAnimPanel.Position = UDim2.new(0, 8, 0, 104)
		addAnimPanel.BackgroundTransparency = 1
		addAnimPanel.Visible = false
		addAnimPanel.Parent = mainFrame

		local newAnimNameBox = Instance.new("TextBox")
		newAnimNameBox.Size = UDim2.new(1, 0, 0, 22)
		newAnimNameBox.Position = UDim2.new(0, 0, 0, 0)
		newAnimNameBox.BackgroundColor3 = C.inputBg
		newAnimNameBox.BackgroundTransparency = ALPHA.input
		newAnimNameBox.Text = ""
		newAnimNameBox.PlaceholderText = "Animation Name..."
		newAnimNameBox.TextColor3 = C.textPrimary
		newAnimNameBox.PlaceholderColor3 = C.textDim
		newAnimNameBox.TextSize = 11
		newAnimNameBox.Font = Enum.Font.Gotham
		newAnimNameBox.BorderSizePixel = 0
		newAnimNameBox.Parent = addAnimPanel

		local v482 = Instance.new("UICorner")
		v482.CornerRadius = UDim.new(0, 8)
		v482.Parent = newAnimNameBox

		local newAnimCodeBox = Instance.new("TextBox")
		newAnimCodeBox.Size = UDim2.new(1, 0, 0, 45)
		newAnimCodeBox.Position = UDim2.new(0, 0, 0, 27)
		newAnimCodeBox.BackgroundColor3 = C.inputBg
		newAnimCodeBox.BackgroundTransparency = ALPHA.input
		newAnimCodeBox.Text = ""
		newAnimCodeBox.PlaceholderText = "Keyframe Code or Asset ID..."
		newAnimCodeBox.TextColor3 = C.textPrimary
		newAnimCodeBox.PlaceholderColor3 = C.textDim
		newAnimCodeBox.TextSize = 9
		newAnimCodeBox.Font = Enum.Font.Code
		newAnimCodeBox.TextWrapped = true
		newAnimCodeBox.TextXAlignment = Enum.TextXAlignment.Left
		newAnimCodeBox.TextYAlignment = Enum.TextYAlignment.Top
		newAnimCodeBox.ClearTextOnFocus = false
		newAnimCodeBox.MultiLine = true
		newAnimCodeBox.BorderSizePixel = 0
		newAnimCodeBox.Parent = addAnimPanel

		local v484 = Instance.new("UICorner")
		v484.CornerRadius = UDim.new(0, 8)
		v484.Parent = newAnimCodeBox

		local statesPanel = Instance.new("Frame")
		statesPanel.Size = UDim2.new(1, -16, 1, -175)
		statesPanel.Position = UDim2.new(0, 8, 0, 104)
		statesPanel.BackgroundTransparency = 1
		statesPanel.Visible = false
		statesPanel.Parent = mainFrame

		local statesScrollFrame = Instance.new("ScrollingFrame")
		statesScrollFrame.Size = UDim2.new(1, 0, 1, 0)
		statesScrollFrame.Position = UDim2.new(0, 0, 0, 0)
		statesScrollFrame.BackgroundTransparency = 1
		statesScrollFrame.ScrollBarThickness = 3
		statesScrollFrame.ScrollBarImageColor3 = C.scrollbar
		statesScrollFrame.ScrollBarImageTransparency = 0.3
		statesScrollFrame.BorderSizePixel = 0
		statesScrollFrame.Parent = statesPanel

		local statesListLayout = Instance.new("UIListLayout")
		statesListLayout.Padding = UDim.new(0, 10)
		statesListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		statesListLayout.Parent = statesScrollFrame

		local function makeStateCard(p_u_488, p_u_489, p490)
			local v491 = Instance.new("Frame")
			v491.Size = UDim2.new(1, 0, 0, 110)
			v491.BackgroundColor3 = C.panelBg2
			v491.BackgroundTransparency = ALPHA.panel2
			v491.BorderSizePixel = 0
			v491.LayoutOrder = p490
			v491.Parent = statesScrollFrame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 55, 70)
			stroke.Thickness = 1
			stroke.Transparency = 0.5
			stroke.Parent = v491

			local v492 = Instance.new("UICorner")
			v492.CornerRadius = UDim.new(0, 10)
			v492.Parent = v491

			local v493 = Instance.new("TextLabel")
			v493.Size = UDim2.new(1, -10, 0, 20)
			v493.Position = UDim2.new(0, 5, 0, 5)
			v493.BackgroundTransparency = 1
			v493.Text = p_u_489
			v493.TextColor3 = C.textPrimary
			v493.TextSize = 12
			v493.Font = Enum.Font.GothamBold
			v493.TextXAlignment = Enum.TextXAlignment.Left
			v493.Parent = v491

			local v_u_494 = Instance.new("TextButton")
			v_u_494.Size = UDim2.new(1, -10, 0, 25)
			v_u_494.Position = UDim2.new(0, 5, 0, 30)
			v_u_494.BackgroundColor3 = C.inputBg
			v_u_494.BackgroundTransparency = ALPHA.input
			local v495 = "Select Animation..."
			local v496
			if stateAnimations[p_u_488] and stateAnimations[p_u_488] ~= "" then
				local v497, v498
				v497, v498, v496 = pairs(animationList)
				while true do
					local v499
					v496, v499 = v497(v498, v496)
					if v496 == nil then
						v496 = v495
						break
					end
					if tostring(v499) == tostring(stateAnimations[p_u_488]) then
						break
					end
				end
				if v496 == "Select Animation..." then
					v496 = "Custom Keyframes"
				end
			else
				v496 = v495
			end
			v_u_494.Text = v496
			v_u_494.TextColor3 = C.textSecond
			v_u_494.TextSize = 10
			v_u_494.Font = Enum.Font.Gotham
			v_u_494.TextXAlignment = Enum.TextXAlignment.Left
			v_u_494.BorderSizePixel = 0
			v_u_494.Parent = v491

			local v500 = Instance.new("UICorner")
			v500.CornerRadius = UDim.new(0, 7)
			v500.Parent = v_u_494

			local v501 = Instance.new("UIPadding")
			v501.PaddingLeft = UDim.new(0, 8)
			v501.Parent = v_u_494

			local v_u_502 = Instance.new("TextBox")
			v_u_502.Size = UDim2.new(1, -10, 0, 40)
			v_u_502.Position = UDim2.new(0, 5, 0, 60)
			v_u_502.BackgroundColor3 = C.inputBg
			v_u_502.BackgroundTransparency = ALPHA.input
			v_u_502.Text = ""
			v_u_502.PlaceholderText = "Or paste keyframe code..."
			v_u_502.TextColor3 = C.textPrimary
			v_u_502.PlaceholderColor3 = C.textDim
			v_u_502.TextSize = 9
			v_u_502.Font = Enum.Font.Code
			v_u_502.TextWrapped = true
			v_u_502.TextXAlignment = Enum.TextXAlignment.Left
			v_u_502.TextYAlignment = Enum.TextYAlignment.Top
			v_u_502.ClearTextOnFocus = false
			v_u_502.MultiLine = true
			v_u_502.BorderSizePixel = 0
			v_u_502.Parent = v491

			local v503 = Instance.new("UICorner")
			v503.CornerRadius = UDim.new(0, 7)
			v503.Parent = v_u_502

			local v_u_504 = false
			local v_u_505 = nil

			v_u_494.MouseButton1Click:Connect(function()
				if v_u_504 then
					if v_u_505 then
						v_u_505:Destroy()
					end
					v_u_504 = false
				else
					v_u_504 = true
					v_u_505 = Instance.new("Frame")
					v_u_505.Size = UDim2.new(1, 0, 0, 180)
					v_u_505.Position = UDim2.new(0, 0, 1, 2)
					v_u_505.BackgroundColor3 = C.panelBg2
					v_u_505.BackgroundTransparency = ALPHA.overlay
					v_u_505.BorderSizePixel = 0
					v_u_505.ZIndex = 10
					v_u_505.Parent = v_u_494

					local v506 = Instance.new("UICorner")
					v506.CornerRadius = UDim.new(0, 8)
					v506.Parent = v_u_505

					local v_u_507 = Instance.new("TextBox")
					v_u_507.Size = UDim2.new(1, -8, 0, 22)
					v_u_507.Position = UDim2.new(0, 4, 0, 4)
					v_u_507.BackgroundColor3 = C.inputBg
					v_u_507.BackgroundTransparency = ALPHA.input
					v_u_507.Text = ""
					v_u_507.PlaceholderText = "Search..."
					v_u_507.TextColor3 = C.textPrimary
					v_u_507.PlaceholderColor3 = C.textDim
					v_u_507.TextSize = 10
					v_u_507.Font = Enum.Font.Gotham
					v_u_507.BorderSizePixel = 0
					v_u_507.ZIndex = 10
					v_u_507.ClearTextOnFocus = false
					v_u_507.Parent = v_u_505

					local v508 = Instance.new("UICorner")
					v508.CornerRadius = UDim.new(0, 6)
					v508.Parent = v_u_507

					local v_u_509 = Instance.new("ScrollingFrame")
					v_u_509.Size = UDim2.new(1, -4, 1, -30)
					v_u_509.Position = UDim2.new(0, 2, 0, 28)
					v_u_509.BackgroundTransparency = 1
					v_u_509.ScrollBarThickness = 3
					v_u_509.ScrollBarImageColor3 = C.scrollbar
					v_u_509.ScrollBarImageTransparency = 0.3
					v_u_509.BorderSizePixel = 0
					v_u_509.ZIndex = 10
					v_u_509.Parent = v_u_505

					local v_u_510 = Instance.new("UIListLayout")
					v_u_510.Padding = UDim.new(0, 2)
					v_u_510.SortOrder = Enum.SortOrder.Name
					v_u_510.Parent = v_u_509

					local v_u_511 = {}
					local function v_u_540()
						local v512, v513, v514 = pairs(v_u_511)
						while true do
							local v515
							v514, v515 = v512(v513, v514)
							if v514 == nil then break end
							v515:Destroy()
						end
						v_u_511 = {}

						local v516 = v_u_507.Text:lower()

						local noneBtn = Instance.new("TextButton")
						noneBtn.Size = UDim2.new(1, 0, 0, 22)
						noneBtn.BackgroundColor3 = C.rowBg
						noneBtn.BackgroundTransparency = ALPHA.row
						noneBtn.Text = "  [None]"
						noneBtn.TextColor3 = C.textRed
						noneBtn.TextSize = 10
						noneBtn.Font = Enum.Font.GothamBold
						noneBtn.TextXAlignment = Enum.TextXAlignment.Left
						noneBtn.BorderSizePixel = 0
						noneBtn.ZIndex = 10
						noneBtn.LayoutOrder = -1
						noneBtn.Parent = v_u_509
						table.insert(v_u_511, noneBtn)

						noneBtn.MouseButton1Click:Connect(function()
							stateAnimations[p_u_488] = ""
							saveStateAnims()
							v_u_494.Text = "Select Animation..."
							v_u_502.Text = ""
							if v_u_505 then v_u_505:Destroy() end
							v_u_504 = false
							statusLabel.Text = p_u_489 .. " cleared"
							statusLabel.TextColor3 = C.textYellow
							spawn(function()
								wait(2)
								statusLabel.Text = "Ready | " .. playerFolder
								statusLabel.TextColor3 = C.textDim
							end)
							if reanimEnabled then
								local v518, v519, v520 = pairs(stateConnections)
								while true do
									local v_u_521
									v520, v_u_521 = v518(v519, v520)
									if v520 == nil then break end
									if v_u_521 then pcall(function() v_u_521:Disconnect() end) end
								end
								stateConnections = {}
								if animPlayback.isRunning then stopAnimation() end
								task.wait(0.1)
								if reanimEnabled then setupStateMonitor() end
							end
						end)

						local v522, v523, v524 = pairs(animationList)
						local v525 = {}
						local v526 = 0
						local v527 = 50
						while true do
							local v528
							v524, v528 = v522(v523, v524)
							if v524 == nil then break end
							if v516 == "" or v524:lower():find(v516, 1, true) then
								table.insert(v525, { ["name"] = v524, ["id"] = v528 })
								v526 = v526 + 1
								if v527 <= v526 then break end
							end
						end
						table.sort(v525, function(a, b) return a.name < b.name end)

						for _, entry in ipairs(v525) do
							local v535 = Instance.new("TextButton")
							v535.Size = UDim2.new(1, 0, 0, 22)
							v535.BackgroundColor3 = C.rowBg
							v535.BackgroundTransparency = ALPHA.row
							v535.Text = "  " .. entry.name
							v535.TextColor3 = C.textPrimary
							v535.TextSize = 10
							v535.Font = Enum.Font.Gotham
							v535.TextXAlignment = Enum.TextXAlignment.Left
							v535.BorderSizePixel = 0
							v535.ZIndex = 10
							v535.Parent = v_u_509
							table.insert(v_u_511, v535)

							v535.MouseButton1Click:Connect(function()
								stateAnimations[p_u_488] = tostring(entry.id)
								saveStateAnims()
								v_u_494.Text = entry.name
								v_u_502.Text = ""
								if v_u_505 then v_u_505:Destroy() end
								v_u_504 = false
								statusLabel.Text = p_u_489 .. " -> " .. entry.name
								statusLabel.TextColor3 = C.textGreen
								spawn(function()
									wait(2)
									statusLabel.Text = "Ready | " .. playerFolder
									statusLabel.TextColor3 = C.textDim
								end)
								if reanimEnabled then
									local v536, v537, v538 = pairs(stateConnections)
									while true do
										local v_u_539
										v538, v_u_539 = v536(v537, v538)
										if v538 == nil then break end
										if v_u_539 then pcall(function() v_u_539:Disconnect() end) end
									end
									stateConnections = {}
									if animPlayback.isRunning then stopAnimation() end
									task.wait(0.1)
									if reanimEnabled then setupStateMonitor() end
								end
							end)
						end

						task.defer(function()
							v_u_509.CanvasSize = UDim2.new(0, 0, 0, v_u_510.AbsoluteContentSize.Y)
						end)
					end

					v_u_540()

					local v_u_541 = false
					v_u_507:GetPropertyChangedSignal("Text"):Connect(function()
						if not v_u_541 then
							v_u_541 = true
							task.wait(0.2)
							v_u_540()
							v_u_541 = false
						end
					end)
				end
			end)

			v_u_502.FocusLost:Connect(function(_)
				if v_u_502.Text ~= "" then
					stateAnimations[p_u_488] = v_u_502.Text
					saveStateAnims()
					v_u_494.Text = "Custom Keyframes"
					statusLabel.Text = p_u_489 .. " -> custom keyframes"
					statusLabel.TextColor3 = C.textGreen
					spawn(function()
						wait(2)
						statusLabel.Text = "Ready | " .. playerFolder
						statusLabel.TextColor3 = C.textDim
					end)
					if reanimEnabled then
						local v543, v544, v545 = pairs(stateConnections)
						while true do
							local v_u_546
							v545, v_u_546 = v543(v544, v545)
							if v545 == nil then break end
							if v_u_546 then pcall(function() v_u_546:Disconnect() end) end
						end
						stateConnections = {}
						if animPlayback.isRunning then stopAnimation() end
						task.wait(0.1)
						if reanimEnabled then setupStateMonitor() end
					end
				end
			end)
		end

		makeStateCard("idle",    "IDLE Animation",    1)
		makeStateCard("walking", "WALKING Animation", 2)
		makeStateCard("jumping", "JUMPING Animation", 3)

		spawn(function()
			wait(0.1)
			statesScrollFrame.CanvasSize = UDim2.new(0, 0, 0, statesListLayout.AbsoluteContentSize.Y + 10)
		end)

		local sizePanel = Instance.new("Frame")
		sizePanel.Size = UDim2.new(1, -16, 1, -175)
		sizePanel.Position = UDim2.new(0, 8, 0, 104)
		sizePanel.BackgroundTransparency = 1
		sizePanel.Visible = false
		sizePanel.Parent = mainFrame

		local heightLabel = Instance.new("TextLabel")
		heightLabel.Size = UDim2.new(1, 0, 0, 25)
		heightLabel.Position = UDim2.new(0, 0, 0, 10)
		heightLabel.BackgroundTransparency = 1
		heightLabel.Text = "Height: 1.00x"
		heightLabel.TextColor3 = C.textPrimary
		heightLabel.TextSize = 12
		heightLabel.Font = Enum.Font.GothamBold
		heightLabel.TextXAlignment = Enum.TextXAlignment.Left
		heightLabel.Parent = sizePanel

		local heightSliderTrack = Instance.new("Frame")
		heightSliderTrack.Size = UDim2.new(1, -20, 0, 5)
		heightSliderTrack.Position = UDim2.new(0, 10, 0, 45)
		heightSliderTrack.BackgroundColor3 = C.toggleOff
		heightSliderTrack.BackgroundTransparency = 0.2
		heightSliderTrack.BorderSizePixel = 0
		heightSliderTrack.Parent = sizePanel

		local v551 = Instance.new("UICorner")
		v551.CornerRadius = UDim.new(0, 3)
		v551.Parent = heightSliderTrack

		local heightSliderKnob = Instance.new("Frame")
		heightSliderKnob.Size = UDim2.new(0, 14, 0, 14)
		heightSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
		heightSliderKnob.BackgroundColor3 = C.textPrimary
		heightSliderKnob.BackgroundTransparency = 0.1
		heightSliderKnob.BorderSizePixel = 0
		heightSliderKnob.Parent = heightSliderTrack

		local v553 = Instance.new("UICorner")
		v553.CornerRadius = UDim.new(0, 7)
		v553.Parent = heightSliderKnob

		local widthLabel = Instance.new("TextLabel")
		widthLabel.Size = UDim2.new(1, 0, 0, 25)
		widthLabel.Position = UDim2.new(0, 0, 0, 80)
		widthLabel.BackgroundTransparency = 1
		widthLabel.Text = "Width: 1.00x"
		widthLabel.TextColor3 = C.textPrimary
		widthLabel.TextSize = 12
		widthLabel.Font = Enum.Font.GothamBold
		widthLabel.TextXAlignment = Enum.TextXAlignment.Left
		widthLabel.Parent = sizePanel

		local widthSliderTrack = Instance.new("Frame")
		widthSliderTrack.Size = UDim2.new(1, -20, 0, 5)
		widthSliderTrack.Position = UDim2.new(0, 10, 0, 115)
		widthSliderTrack.BackgroundColor3 = C.toggleOff
		widthSliderTrack.BackgroundTransparency = 0.2
		widthSliderTrack.BorderSizePixel = 0
		widthSliderTrack.Parent = sizePanel

		local v556 = Instance.new("UICorner")
		v556.CornerRadius = UDim.new(0, 3)
		v556.Parent = widthSliderTrack

		local widthSliderKnob = Instance.new("Frame")
		widthSliderKnob.Size = UDim2.new(0, 14, 0, 14)
		widthSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
		widthSliderKnob.BackgroundColor3 = C.textPrimary
		widthSliderKnob.BackgroundTransparency = 0.1
		widthSliderKnob.BorderSizePixel = 0
		widthSliderKnob.Parent = widthSliderTrack

		local v558 = Instance.new("UICorner")
		v558.CornerRadius = UDim.new(0, 7)
		v558.Parent = widthSliderKnob

		local resetSizeBtn = Instance.new("TextButton")
		resetSizeBtn.Size = UDim2.new(0, 100, 0, 28)
		resetSizeBtn.Position = UDim2.new(0.5, -50, 0, 160)
		resetSizeBtn.BackgroundColor3 = C.btnBg
		resetSizeBtn.BackgroundTransparency = ALPHA.btn
		resetSizeBtn.Text = "Reset Size"
		resetSizeBtn.TextColor3 = C.textPrimary
		resetSizeBtn.TextSize = 11
		resetSizeBtn.Font = Enum.Font.GothamSemibold
		resetSizeBtn.BorderSizePixel = 0
		resetSizeBtn.Parent = sizePanel

		local v560 = Instance.new("UICorner")
		v560.CornerRadius = UDim.new(0, 9)
		v560.Parent = resetSizeBtn

		local heightDragging = false
		local widthDragging = false

		local function setHeightScale(p563)
			local v564 = 0.1
			sizeScale.heightScale = v564 * math.pow(100 / v564, p563)
			heightSliderKnob.Position = UDim2.new(p563, -7, 0.5, -7)
			heightLabel.Text = string.format("Height: %.2fx", sizeScale.heightScale)
			if reanimEnabled then applyBodyScale() end
		end

		local function v_u_568(p566)
			local v567 = 0.1
			sizeScale.widthScale = v567 * math.pow(100 / v567, p566)
			widthSliderKnob.Position = UDim2.new(p566, -7, 0.5, -7)
			widthLabel.Text = string.format("Width: %.2fx", sizeScale.widthScale)
			if reanimEnabled then applyBodyScale() end
		end

		local function v_u_570(p569)
			setHeightScale(math.clamp((p569.Position.X - heightSliderTrack.AbsolutePosition.X) / heightSliderTrack.AbsoluteSize.X, 0, 1))
		end

		local function v_u_572(p571)
			v_u_568(math.clamp((p571.Position.X - widthSliderTrack.AbsolutePosition.X) / widthSliderTrack.AbsoluteSize.X, 0, 1))
		end

		heightSliderKnob.InputBegan:Connect(function(p573)
			if p573.UserInputType == Enum.UserInputType.MouseButton1 or p573.UserInputType == Enum.UserInputType.Touch then
				heightDragging = true
				v_u_570(p573)
			end
		end)
		widthSliderKnob.InputBegan:Connect(function(p574)
			if p574.UserInputType == Enum.UserInputType.MouseButton1 or p574.UserInputType == Enum.UserInputType.Touch then
				widthDragging = true
				v_u_572(p574)
			end
		end)
		UserInputService.InputChanged:Connect(function(p575)
			if heightDragging and (p575.UserInputType == Enum.UserInputType.MouseMovement or p575.UserInputType == Enum.UserInputType.Touch) then
				v_u_570(p575)
			end
			if widthDragging and (p575.UserInputType == Enum.UserInputType.MouseMovement or p575.UserInputType == Enum.UserInputType.Touch) then
				v_u_572(p575)
			end
		end)
		UserInputService.InputEnded:Connect(function(p576)
			if p576.UserInputType == Enum.UserInputType.MouseButton1 or p576.UserInputType == Enum.UserInputType.Touch then
				heightDragging = false
				widthDragging = false
			end
		end)
		resetSizeBtn.MouseButton1Click:Connect(function()
			sizeScale.heightScale = 1
			sizeScale.widthScale = 1
			heightSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
			widthSliderKnob.Position = UDim2.new(0.5, -7, 0.5, -7)
			heightLabel.Text = "Height: 1.00x"
			widthLabel.Text = "Width: 1.00x"
			if reanimEnabled then applyBodyScale() end
		end)
		resetSizeBtn.MouseEnter:Connect(function() resetSizeBtn.BackgroundTransparency = ALPHA.btnH end)
		resetSizeBtn.MouseLeave:Connect(function() resetSizeBtn.BackgroundTransparency = ALPHA.btn end)

		local othersPanel = Instance.new("Frame")
		othersPanel.Size = UDim2.new(1, -16, 1, -175)
		othersPanel.Position = UDim2.new(0, 8, 0, 104)
		othersPanel.BackgroundTransparency = 1
		othersPanel.Visible = false
		othersPanel.Parent = mainFrame

		-- JSON drop folder info label
		local jsonInfoLabel = Instance.new("TextLabel")
		jsonInfoLabel.Size = UDim2.new(1, 0, 0, 28)
		jsonInfoLabel.Position = UDim2.new(0, 0, 0, -5)
		jsonInfoLabel.BackgroundTransparency = 1
		jsonInfoLabel.Text = 'Drop folder: "' .. jsonDropFolder .. '"'
		jsonInfoLabel.TextColor3 = C.textSecond
		jsonInfoLabel.TextSize = 10
		jsonInfoLabel.Font = Enum.Font.GothamSemibold
		jsonInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
		jsonInfoLabel.TextWrapped = true
		jsonInfoLabel.Parent = othersPanel

		-- Reload JSON button
		local reloadJsonBtn = Instance.new("TextButton")
		reloadJsonBtn.Size = UDim2.new(0, 110, 0, 22)
		reloadJsonBtn.Position = UDim2.new(0, 0, 0, 28)
		reloadJsonBtn.BackgroundColor3 = C.btnBg
		reloadJsonBtn.BackgroundTransparency = ALPHA.btn
		reloadJsonBtn.Text = "Reload JSON Files"
		reloadJsonBtn.TextColor3 = C.textPrimary
		reloadJsonBtn.TextSize = 9
		reloadJsonBtn.Font = Enum.Font.Gotham
		reloadJsonBtn.BorderSizePixel = 0
		reloadJsonBtn.Parent = othersPanel

		local rjCorner = Instance.new("UICorner")
		rjCorner.CornerRadius = UDim.new(0, 7)
		rjCorner.Parent = reloadJsonBtn

		reloadJsonBtn.MouseButton1Click:Connect(function()
			loadJsonDropFolder()
			statusLabel.Text = "JSON files reloaded"
			statusLabel.TextColor3 = C.textGreen
			spawn(function()
				wait(2)
				statusLabel.Text = "Ready | " .. playerFolder
				statusLabel.TextColor3 = C.textDim
			end)
		end)
		reloadJsonBtn.MouseEnter:Connect(function() reloadJsonBtn.BackgroundTransparency = ALPHA.btnH end)
		reloadJsonBtn.MouseLeave:Connect(function() reloadJsonBtn.BackgroundTransparency = ALPHA.btn end)

		local yOff = 57
		local v578 = Instance.new("TextLabel")
		v578.Size = UDim2.new(1, 0, 0, 20)
		v578.Position = UDim2.new(0, 0, 0, yOff)
		v578.BackgroundTransparency = 1
		v578.Text = "Hide Bodyparts"
		v578.TextColor3 = C.textPrimary
		v578.TextSize = 12
		v578.Font = Enum.Font.GothamBold
		v578.TextXAlignment = Enum.TextXAlignment.Left
		v578.Parent = othersPanel

		local hidePartsBtn = Instance.new("TextButton")
		hidePartsBtn.Size = UDim2.new(1, 0, 0, 28)
		hidePartsBtn.Position = UDim2.new(0, 0, 0, yOff + 22)
		hidePartsBtn.BackgroundColor3 = C.btnBg
		hidePartsBtn.BackgroundTransparency = ALPHA.btn
		hidePartsBtn.Text = "  Select Body Parts..."
		hidePartsBtn.TextColor3 = C.textPrimary
		hidePartsBtn.TextSize = 10
		hidePartsBtn.Font = Enum.Font.Gotham
		hidePartsBtn.TextXAlignment = Enum.TextXAlignment.Left
		hidePartsBtn.BorderSizePixel = 0
		hidePartsBtn.Parent = othersPanel

		local v580 = Instance.new("UICorner")
		v580.CornerRadius = UDim.new(0, 9)
		v580.Parent = hidePartsBtn

		local v581 = Instance.new("UIPadding")
		v581.PaddingLeft = UDim.new(0, 10)
		v581.Parent = hidePartsBtn

		local hideablePartNames = {
			"Head","UpperTorso","LowerTorso",
			"LeftUpperArm","LeftLowerArm","LeftHand",
			"RightUpperArm","RightLowerArm","RightHand",
			"LeftUpperLeg","LeftLowerLeg","LeftFoot",
			"RightUpperLeg","RightLowerLeg","RightFoot",
			"Torso","Left Arm","Right Arm","Left Leg","Right Leg"
		}

		local function hideBodyPart(p583)
			if reanimEnabled and (cloneChar and originalChar) then
				local v584 = cloneChar:FindFirstChild(p583)
				local v585 = originalChar:FindFirstChild(p583)
				if v584 and v584:IsA("BasePart") then
					if v585 and v585:IsA("BasePart") then
						v584.Transparency = 1
						v584.CanCollide = false
						if p583 == "Head" then
							for _, v589 in ipairs(v584:GetChildren()) do
								if v589:IsA("Decal") then v589.Transparency = 1 end
							end
						end
						_G.hiddenBodyParts[p583] = true
					end
				end
			end
		end

		local function showBodyPart(p591)
			_G.hiddenBodyParts[p591] = nil
		end

		local hidePartMenuOpen = false
		local hidePartMenu = nil

		hidePartsBtn.MouseButton1Click:Connect(function()
			if hidePartMenuOpen then
				if hidePartMenu then hidePartMenu:Destroy() end
				hidePartMenuOpen = false
				return
			elseif reanimEnabled and cloneChar then
				hidePartMenuOpen = true
				hidePartMenu = Instance.new("Frame")
				hidePartMenu.Size = UDim2.new(1, 0, 0, 150)
				hidePartMenu.Position = UDim2.new(0, 0, 1, 3)
				hidePartMenu.BackgroundColor3 = C.panelBg2
				hidePartMenu.BackgroundTransparency = ALPHA.overlay
				hidePartMenu.BorderSizePixel = 0
				hidePartMenu.ZIndex = 10
				hidePartMenu.Parent = hidePartsBtn

				local v595 = Instance.new("UICorner")
				v595.CornerRadius = UDim.new(0, 9)
				v595.Parent = hidePartMenu

				local hidePartScrollFrame = Instance.new("ScrollingFrame")
				hidePartScrollFrame.Size = UDim2.new(1, -6, 1, -6)
				hidePartScrollFrame.Position = UDim2.new(0, 3, 0, 3)
				hidePartScrollFrame.BackgroundTransparency = 1
				hidePartScrollFrame.ScrollBarThickness = 3
				hidePartScrollFrame.ScrollBarImageColor3 = C.scrollbar
				hidePartScrollFrame.ScrollBarImageTransparency = 0.3
				hidePartScrollFrame.BorderSizePixel = 0
				hidePartScrollFrame.ZIndex = 10
				hidePartScrollFrame.Parent = hidePartMenu

				local hidePartListLayout = Instance.new("UIListLayout")
				hidePartListLayout.Padding = UDim.new(0, 2)
				hidePartListLayout.SortOrder = Enum.SortOrder.Name
				hidePartListLayout.Parent = hidePartScrollFrame

				for _, v_u_601 in ipairs(hideablePartNames) do
					if cloneChar:FindFirstChild(v_u_601) ~= nil then
						local hidePartBtnUI = Instance.new("TextButton")
						hidePartBtnUI.Size = UDim2.new(1, 0, 0, 24)
						hidePartBtnUI.BackgroundColor3 = C.rowBg
						hidePartBtnUI.BackgroundTransparency = ALPHA.row
						hidePartBtnUI.Text = (_G.hiddenBodyParts[v_u_601] and "[x] " or "   ") .. v_u_601
						hidePartBtnUI.TextColor3 = _G.hiddenBodyParts[v_u_601] and C.accentPlay or C.textPrimary
						hidePartBtnUI.TextSize = 9
						hidePartBtnUI.Font = Enum.Font.Gotham
						hidePartBtnUI.TextXAlignment = Enum.TextXAlignment.Left
						hidePartBtnUI.BorderSizePixel = 0
						hidePartBtnUI.ZIndex = 10
						hidePartBtnUI.Parent = hidePartScrollFrame

						local v603 = Instance.new("UIPadding")
						v603.PaddingLeft = UDim.new(0, 5)
						v603.Parent = hidePartBtnUI

						hidePartBtnUI.MouseButton1Click:Connect(function()
							if _G.hiddenBodyParts[v_u_601] then
								showBodyPart(v_u_601)
								statusLabel.Text = v_u_601 .. " shown"
								statusLabel.TextColor3 = C.textYellow
							else
								hideBodyPart(v_u_601)
								statusLabel.Text = v_u_601 .. " hidden"
								statusLabel.TextColor3 = C.textGreen
							end
							spawn(function()
								wait(2)
								statusLabel.Text = "Ready | " .. playerFolder
								statusLabel.TextColor3 = C.textDim
							end)
							hidePartBtnUI.Text = (_G.hiddenBodyParts[v_u_601] and "[x] " or "   ") .. v_u_601
							hidePartBtnUI.TextColor3 = _G.hiddenBodyParts[v_u_601] and C.accentPlay or C.textPrimary
						end)
					end
				end

				spawn(function()
					wait(0.05)
					hidePartScrollFrame.CanvasSize = UDim2.new(0, 0, 0, hidePartListLayout.AbsoluteContentSize.Y)
				end)
			else
				statusLabel.Text = "Enable reanimation first!"
				statusLabel.TextColor3 = C.textRed
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			end
		end)

		hidePartsBtn.MouseEnter:Connect(function() hidePartsBtn.BackgroundTransparency = ALPHA.btnH end)
		hidePartsBtn.MouseLeave:Connect(function() hidePartsBtn.BackgroundTransparency = ALPHA.btn end)

		local function makeToggleRow(label, yPos, onToggle)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.7, 0, 0, 20)
			lbl.Position = UDim2.new(0, 0, 0, yPos)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.TextColor3 = C.textPrimary
			lbl.TextSize = 12
			lbl.Font = Enum.Font.GothamBold
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Parent = othersPanel

			local bg = Instance.new("Frame")
			bg.Size = UDim2.new(0, 40, 0, 18)
			bg.Position = UDim2.new(1, -45, 0, yPos + 1)
			bg.BackgroundColor3 = C.toggleOff
			bg.BackgroundTransparency = 0
			bg.BorderSizePixel = 0
			bg.Parent = othersPanel

			local bgC = Instance.new("UICorner")
			bgC.CornerRadius = UDim.new(0, 9)
			bgC.Parent = bg

			local knob = Instance.new("Frame")
			knob.Size = UDim2.new(0, 14, 0, 14)
			knob.Position = UDim2.new(0, 2, 0, 2)
			knob.BackgroundColor3 = C.knobOff
			knob.BorderSizePixel = 0
			knob.Parent = bg

			local knobC = Instance.new("UICorner")
			knobC.CornerRadius = UDim.new(0, 7)
			knobC.Parent = knob

			local tbtn = Instance.new("TextButton")
			tbtn.Size = UDim2.new(1, 0, 1, 0)
			tbtn.BackgroundTransparency = 1
			tbtn.Text = ""
			tbtn.Parent = bg

			tbtn.MouseButton1Click:Connect(function()
				onToggle(bg, knob)
			end)

			return bg, knob
		end

		local snkY = yOff + 58
		local snakeToggleBg, snakeToggleKnob = makeToggleRow("Snake Mode", snkY, function(bg, knob)
			if reanimEnabled then
				snakeModeEnabled = not snakeModeEnabled
				snakeCurrentPos = {}
				snakeTargetPos = {}
				snakeHistory = {}
				if snakeModeEnabled then
					bg.BackgroundColor3 = C.toggleOn
					knob.Position = UDim2.new(1, -16, 0, 2)
					knob.BackgroundColor3 = C.knobOn
					statusLabel.Text = "Snake mode on"
					statusLabel.TextColor3 = C.textGreen
				else
					bg.BackgroundColor3 = C.toggleOff
					knob.Position = UDim2.new(0, 2, 0, 2)
					knob.BackgroundColor3 = C.knobOff
					statusLabel.Text = "Snake mode off"
					statusLabel.TextColor3 = C.textYellow
				end
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			else
				statusLabel.Text = "Enable reanimation first!"
				statusLabel.TextColor3 = C.textRed
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			end
		end)

		-- Snake distance slider
		local snakeDistLabel = Instance.new("TextLabel")
		snakeDistLabel.Size = UDim2.new(1, -60, 0, 18)
		snakeDistLabel.Position = UDim2.new(0, 0, 0, snkY + 25)
		snakeDistLabel.BackgroundTransparency = 1
		snakeDistLabel.Text = "Distance: 1.00"
		snakeDistLabel.TextColor3 = C.textSecond
		snakeDistLabel.TextSize = 10
		snakeDistLabel.Font = Enum.Font.Gotham
		snakeDistLabel.TextXAlignment = Enum.TextXAlignment.Left
		snakeDistLabel.Parent = othersPanel

		local snakeSliderTrack = Instance.new("Frame")
		snakeSliderTrack.Size = UDim2.new(1, -10, 0, 4)
		snakeSliderTrack.Position = UDim2.new(0, 5, 0, snkY + 45)
		snakeSliderTrack.BackgroundColor3 = C.toggleOff
		snakeSliderTrack.BackgroundTransparency = 0.2
		snakeSliderTrack.BorderSizePixel = 0
		snakeSliderTrack.Parent = othersPanel

		local v614 = Instance.new("UICorner")
		v614.CornerRadius = UDim.new(0, 2)
		v614.Parent = snakeSliderTrack

		local snakeSliderKnob = Instance.new("Frame")
		snakeSliderKnob.Size = UDim2.new(0, 12, 0, 12)
		snakeSliderKnob.Position = UDim2.new(0.18, -6, 0.5, -6)
		snakeSliderKnob.BackgroundColor3 = C.textPrimary
		snakeSliderKnob.BackgroundTransparency = 0.1
		snakeSliderKnob.BorderSizePixel = 0
		snakeSliderKnob.Parent = snakeSliderTrack

		local v616 = Instance.new("UICorner")
		v616.CornerRadius = UDim.new(0, 6)
		v616.Parent = snakeSliderKnob

		local snakeDragging = false
		local function setSnakeDistance(p618)
			snakeDistance = 0.2 + p618 * 4.8
			snakeSliderKnob.Position = UDim2.new(p618, -6, 0.5, -6)
			snakeDistLabel.Text = string.format("Distance: %.2f", snakeDistance)
		end
		local function updateSnakeSlider(p620)
			setSnakeDistance(math.clamp((p620.Position.X - snakeSliderTrack.AbsolutePosition.X) / snakeSliderTrack.AbsoluteSize.X, 0, 1))
		end
		snakeSliderKnob.InputBegan:Connect(function(p622)
			if p622.UserInputType == Enum.UserInputType.MouseButton1 or p622.UserInputType == Enum.UserInputType.Touch then
				snakeDragging = true
				updateSnakeSlider(p622)
			end
		end)
		UserInputService.InputChanged:Connect(function(p623)
			if snakeDragging and (p623.UserInputType == Enum.UserInputType.MouseMovement or p623.UserInputType == Enum.UserInputType.Touch) then
				updateSnakeSlider(p623)
			end
		end)
		UserInputService.InputEnded:Connect(function(p624)
			if p624.UserInputType == Enum.UserInputType.MouseButton1 or p624.UserInputType == Enum.UserInputType.Touch then
				snakeDragging = false
			end
		end)

		-- Cover Sky
		local skyY = snkY + 60
		makeToggleRow("Cover Sky (need layered clothing)", skyY, function(bg, knob)
			if reanimEnabled then
				coverSkyEnabled = not coverSkyEnabled
				if coverSkyEnabled then
					bg.BackgroundColor3 = C.toggleOn
					knob.Position = UDim2.new(1, -16, 0, 2)
					knob.BackgroundColor3 = C.knobOn
					statusLabel.Text = "Cover Sky on"
					statusLabel.TextColor3 = C.textGreen
				else
					bg.BackgroundColor3 = C.toggleOff
					knob.Position = UDim2.new(0, 2, 0, 2)
					knob.BackgroundColor3 = C.knobOff
					statusLabel.Text = "Cover Sky off"
					statusLabel.TextColor3 = C.textYellow
				end
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			else
				statusLabel.Text = "Enable reanimation first!"
				statusLabel.TextColor3 = C.textRed
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			end
		end)

		-- Cover Ground
		local grdY = skyY + 28
		makeToggleRow("Cover Ground (need layered clothing)", grdY, function(bg, knob)
			if reanimEnabled then
				groundModeEnabled = not groundModeEnabled
				if groundModeEnabled then
					bg.BackgroundColor3 = C.toggleOn
					knob.Position = UDim2.new(1, -16, 0, 2)
					knob.BackgroundColor3 = C.knobOn
					statusLabel.Text = "Cover Ground on"
					statusLabel.TextColor3 = C.textGreen
				else
					bg.BackgroundColor3 = C.toggleOff
					knob.Position = UDim2.new(0, 2, 0, 2)
					knob.BackgroundColor3 = C.knobOff
					statusLabel.Text = "Cover Ground off"
					statusLabel.TextColor3 = C.textYellow
				end
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			else
				statusLabel.Text = "Enable reanimation first!"
				statusLabel.TextColor3 = C.textRed
				spawn(function()
					wait(2)
					statusLabel.Text = "Ready | " .. playerFolder
					statusLabel.TextColor3 = C.textDim
				end)
			end
		end)

		local addAnimBtn = Instance.new("TextButton")
		addAnimBtn.Size = UDim2.new(0, 60, 0, 22)
		addAnimBtn.Position = UDim2.new(0, 8, 0, 104)
		addAnimBtn.BackgroundColor3 = C.btnBg
		addAnimBtn.BackgroundTransparency = ALPHA.btn
		addAnimBtn.Text = "Add"
		addAnimBtn.TextColor3 = C.textPrimary
		addAnimBtn.TextSize = 10
		addAnimBtn.Font = Enum.Font.GothamSemibold
		addAnimBtn.BorderSizePixel = 0
		addAnimBtn.Parent = mainFrame

		local v642 = Instance.new("UICorner")
		v642.CornerRadius = UDim.new(0, 9)
		v642.Parent = addAnimBtn

		local helpBtn = Instance.new("TextButton")
		helpBtn.Size = UDim2.new(0, 25, 0, 25)
		helpBtn.Position = UDim2.new(1, -33, 1, -33)
		helpBtn.BackgroundColor3 = C.btnBg
		helpBtn.BackgroundTransparency = ALPHA.btn
		helpBtn.Text = "?"
		helpBtn.TextColor3 = C.textSecond
		helpBtn.TextSize = 14
		helpBtn.Font = Enum.Font.GothamBold
		helpBtn.BorderSizePixel = 0
		helpBtn.ZIndex = 10
		helpBtn.Visible = false
		helpBtn.Parent = mainFrame

		local v650 = Instance.new("UICorner")
		v650.CornerRadius = UDim.new(1, 0)
		v650.Parent = helpBtn

		helpBtn.MouseEnter:Connect(function() helpBtn.BackgroundTransparency = ALPHA.btnH end)
		helpBtn.MouseLeave:Connect(function() helpBtn.BackgroundTransparency = ALPHA.btn end)

		local helpModal = nil
		local function showHelpModal()
			if helpModal then helpModal:Destroy() end
			helpModal = Instance.new("Frame")
			helpModal.Size = UDim2.new(0, 380, 0, 310)
			helpModal.Position = UDim2.new(0.5, -190, 0.5, -155)
			helpModal.BackgroundColor3 = C.panelBg
			helpModal.BackgroundTransparency = ALPHA.panel
			helpModal.BorderSizePixel = 0
			helpModal.ZIndex = 100
			helpModal.Parent = screenGui

			local hmStroke = Instance.new("UIStroke")
			hmStroke.Color = Color3.fromRGB(70, 75, 90)
			hmStroke.Thickness = 1
			hmStroke.Transparency = 0.3
			hmStroke.Parent = helpModal

			local v652 = Instance.new("UICorner")
			v652.CornerRadius = UDim.new(0, 14)
			v652.Parent = helpModal

			local v653 = Instance.new("TextLabel")
			v653.Size = UDim2.new(1, -40, 0, 30)
			v653.Position = UDim2.new(0, 10, 0, 5)
			v653.BackgroundTransparency = 1
			v653.Text = "AC Reanim - How to Convert Animations"
			v653.TextColor3 = C.textPrimary
			v653.TextSize = 13
			v653.Font = Enum.Font.GothamBold
			v653.TextXAlignment = Enum.TextXAlignment.Left
			v653.ZIndex = 101
			v653.Parent = helpModal

			local v654 = Instance.new("TextButton")
			v654.Size = UDim2.new(0, 25, 0, 25)
			v654.Position = UDim2.new(1, -30, 0, 5)
			v654.BackgroundColor3 = C.btnBg
			v654.BackgroundTransparency = ALPHA.btn
			v654.Text = "X"
			v654.TextColor3 = C.textPrimary
			v654.TextSize = 16
			v654.Font = Enum.Font.Gotham
			v654.BorderSizePixel = 0
			v654.ZIndex = 101
			v654.Parent = helpModal

			local v655 = Instance.new("UICorner")
			v655.CornerRadius = UDim.new(0, 8)
			v655.Parent = v654

			v654.MouseButton1Click:Connect(function()
				helpModal:Destroy()
				helpModal = nil
			end)

			local v656 = Instance.new("TextLabel")
			v656.Size = UDim2.new(1, -20, 0, 160)
			v656.Position = UDim2.new(0, 10, 0, 40)
			v656.BackgroundTransparency = 1
			v656.Text = "1. Open Roblox Studio and create a new game\n\n2. Create a Folder in Workspace named \"Keyframes\"\n\n3. Put all your KeyframeSequences in the folder\n   (Each animation should be named differently)\n\n4. Publish your game to Roblox\n\n5. Join the published game with your executor\n\n6. Execute the converter script below:\n\nCustom JSON folder: " .. jsonDropFolder .. "/\n   Drop {\"Name\":\"animId\"} JSON files to auto-add to Custom tab"
			v656.TextColor3 = C.textPrimary
			v656.TextSize = 11
			v656.Font = Enum.Font.Gotham
			v656.TextXAlignment = Enum.TextXAlignment.Left
			v656.TextYAlignment = Enum.TextYAlignment.Top
			v656.TextWrapped = true
			v656.ZIndex = 101
			v656.Parent = helpModal

			local v657 = Instance.new("Frame")
			v657.Size = UDim2.new(1, -20, 0, 40)
			v657.Position = UDim2.new(0, 10, 0, 210)
			v657.BackgroundColor3 = C.inputBg
			v657.BackgroundTransparency = ALPHA.input
			v657.BorderSizePixel = 0
			v657.ZIndex = 101
			v657.Parent = helpModal

			local v658 = Instance.new("UICorner")
			v658.CornerRadius = UDim.new(0, 8)
			v658.Parent = v657

			local v_u_659 = Instance.new("TextBox")
			v_u_659.Size = UDim2.new(1, -10, 1, -10)
			v_u_659.Position = UDim2.new(0, 5, 0, 5)
			v_u_659.BackgroundTransparency = 1
			v_u_659.Text = "loadstring(game:HttpGet(\"https://akadmin-bzk.pages.dev/Converter.lua\"))()"
			v_u_659.TextColor3 = C.textGreen
			v_u_659.TextSize = 10
			v_u_659.Font = Enum.Font.Code
			v_u_659.TextWrapped = true
			v_u_659.TextEditable = false
			v_u_659.TextXAlignment = Enum.TextXAlignment.Left
			v_u_659.TextYAlignment = Enum.TextYAlignment.Center
			v_u_659.ClearTextOnFocus = false
			v_u_659.ZIndex = 102
			v_u_659.Parent = v657

			local v_u_660 = Instance.new("TextButton")
			v_u_660.Size = UDim2.new(0, 60, 0, 25)
			v_u_660.Position = UDim2.new(0.5, -30, 1, 10)
			v_u_660.BackgroundColor3 = C.btnBg
			v_u_660.BackgroundTransparency = ALPHA.btn
			v_u_660.Text = "Copy"
			v_u_660.TextColor3 = C.textPrimary
			v_u_660.TextSize = 11
			v_u_660.Font = Enum.Font.Gotham
			v_u_660.BorderSizePixel = 0
			v_u_660.ZIndex = 102
			v_u_660.Parent = v657

			local v661 = Instance.new("UICorner")
			v661.CornerRadius = UDim.new(0, 7)
			v661.Parent = v_u_660

			v_u_660.MouseEnter:Connect(function() v_u_660.BackgroundTransparency = ALPHA.btnH end)
			v_u_660.MouseLeave:Connect(function() v_u_660.BackgroundTransparency = ALPHA.btn end)
			v_u_660.MouseButton1Click:Connect(function()
				setclipboard(v_u_659.Text)
				v_u_660.Text = "Copied!"
				spawn(function()
					wait(1.5)
					v_u_660.Text = "Copy"
				end)
			end)
		end

		helpBtn.MouseButton1Click:Connect(showHelpModal)

		local speedBarFrame = Instance.new("Frame")
		speedBarFrame.Size = UDim2.new(1, -16, 0, 65)
		speedBarFrame.Position = UDim2.new(0, 8, 1, -70)
		speedBarFrame.BackgroundTransparency = 1
		speedBarFrame.Parent = mainFrame

		local v666 = Instance.new("TextLabel")
		v666.Size = UDim2.new(0, 45, 0, 18)
		v666.Position = UDim2.new(0, 0, 0, 0)
		v666.BackgroundTransparency = 1
		v666.Text = "Speed:"
		v666.TextColor3 = C.textSecond
		v666.TextSize = 9
		v666.Font = Enum.Font.Gotham
		v666.TextXAlignment = Enum.TextXAlignment.Left
		v666.Parent = speedBarFrame

		local speedSliderTrack = Instance.new("Frame")
		speedSliderTrack.Size = UDim2.new(1, -100, 0, 5)
		speedSliderTrack.Position = UDim2.new(0, 45, 0, 7)
		speedSliderTrack.BackgroundColor3 = C.toggleOff
		speedSliderTrack.BackgroundTransparency = 0.2
		speedSliderTrack.BorderSizePixel = 0
		speedSliderTrack.Parent = speedBarFrame

		local v668 = Instance.new("UICorner")
		v668.CornerRadius = UDim.new(0, 3)
		v668.Parent = speedSliderTrack

		local speedSliderKnob = Instance.new("Frame")
		speedSliderKnob.Size = UDim2.new(0, 12, 0, 12)
		speedSliderKnob.Position = UDim2.new(0.5, -6, 0.5, -6)
		speedSliderKnob.BackgroundColor3 = C.textPrimary
		speedSliderKnob.BackgroundTransparency = 0.1
		speedSliderKnob.BorderSizePixel = 0
		speedSliderKnob.Parent = speedSliderTrack

		local v670 = Instance.new("UICorner")
		v670.CornerRadius = UDim.new(0, 6)
		v670.Parent = speedSliderKnob

		local speedValueLabel = Instance.new("TextLabel")
		speedValueLabel.Size = UDim2.new(0, 28, 0, 18)
		-- Parented to the track so it always sits right at the track's right end
		speedValueLabel.Position = UDim2.new(1, 4, 0.5, -9)
		speedValueLabel.BackgroundTransparency = 1
		speedValueLabel.Text = "5"
		speedValueLabel.TextColor3 = C.textSecond
		speedValueLabel.TextSize = 9
		speedValueLabel.Font = Enum.Font.Gotham
		speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
		speedValueLabel.ZIndex = 2
		speedValueLabel.Parent = speedSliderTrack

		local resetSpeedBtn = Instance.new("TextButton")
		resetSpeedBtn.Size = UDim2.new(0, 32, 0, 14)
		resetSpeedBtn.Position = UDim2.new(1, -32, 0, 2)
		resetSpeedBtn.BackgroundColor3 = C.btnBg
		resetSpeedBtn.BackgroundTransparency = ALPHA.btn
		resetSpeedBtn.Text = "Reset"
		resetSpeedBtn.TextColor3 = C.textSecond
		resetSpeedBtn.TextSize = 7
		resetSpeedBtn.Font = Enum.Font.Gotham
		resetSpeedBtn.BorderSizePixel = 0
		resetSpeedBtn.Parent = speedBarFrame

		local v673 = Instance.new("UICorner")
		v673.CornerRadius = UDim.new(0, 7)
		v673.Parent = resetSpeedBtn

		local speedSlotsFrame = Instance.new("Frame")
		speedSlotsFrame.Size = UDim2.new(1, 0, 0, 38)
		speedSlotsFrame.Position = UDim2.new(0, 0, 0, 22)
		speedSlotsFrame.BackgroundTransparency = 1
		speedSlotsFrame.Parent = speedBarFrame

		local currentTab = "all"
		local isMinimized = false
		local minimizeAnimating = false
		local isBindingKey = false
		local bindingAnimName = nil
		local addAnimPanelOpen = false

		local uiStatusLabel = statusLabel
		local v_u_679 = {}

		for v680 = 1, 5 do
			local v_u_681 = v680
			local slotFrame = Instance.new("Frame")
			slotFrame.Size = UDim2.new(0.18, 0, 1, 0)
			slotFrame.Position = UDim2.new((v_u_681 - 1) * 0.2 + 0.01, 0, 0, 0)
			slotFrame.BackgroundTransparency = 1
			slotFrame.Parent = speedSlotsFrame

			local v_u_683 = Instance.new("TextBox")
			v_u_683.Size = UDim2.new(1, 0, 0, 16)
			v_u_683.Position = UDim2.new(0, 0, 0, 0)
			v_u_683.BackgroundColor3 = C.inputBg
			v_u_683.BackgroundTransparency = ALPHA.input
			v_u_683.Text = speedSlots and speedSlots[v_u_681] and tostring(speedSlots[v_u_681].speed) or tostring(v_u_681 * 2 - 1)
			v_u_683.TextColor3 = C.textPrimary
			v_u_683.TextSize = 8
			v_u_683.Font = Enum.Font.Gotham
			v_u_683.BorderSizePixel = 0
			v_u_683.Parent = slotFrame

			local v684 = Instance.new("UICorner")
			v684.CornerRadius = UDim.new(0, 5)
			v684.Parent = v_u_683

			local v_u_685 = Instance.new("TextButton")
			v_u_685.Size = UDim2.new(1, 0, 0, 16)
			v_u_685.Position = UDim2.new(0, 0, 0, 20)
			v_u_685.BackgroundColor3 = C.btnBg
			v_u_685.BackgroundTransparency = ALPHA.btn
			v_u_685.Text = "Key"
			v_u_685.TextColor3 = C.textSecond
			v_u_685.TextSize = 7
			v_u_685.Font = Enum.Font.Gotham
			v_u_685.BorderSizePixel = 0
			v_u_685.Parent = slotFrame

			local v686 = Instance.new("UICorner")
			v686.CornerRadius = UDim.new(0, 5)
			v686.Parent = v_u_685

			v_u_679[v_u_681] = {
				["speedInput"] = v_u_683,
				["keybindButton"] = v_u_685,
				["connection"] = nil
			}

			v_u_683.FocusLost:Connect(function()
				if not speedSlots[v_u_681] then
					speedSlots[v_u_681] = { ["speed"] = v_u_681 * 2 - 1, ["key"] = "" }
				end
				local v687 = tonumber(v_u_683.Text)
				if v687 and (0 <= v687 and v687 <= 10) then
					speedSlots[v_u_681].speed = v687
					saveSpeedSlots()
				else
					v_u_683.Text = tostring(speedSlots[v_u_681].speed)
				end
			end)

			v_u_685.MouseButton1Click:Connect(function()
				if not speedSlots[v_u_681] then
					speedSlots[v_u_681] = { ["speed"] = v_u_681 * 2 - 1, ["key"] = "" }
				end
				if speedSlots[v_u_681].key == "" then
					v_u_685.Text = "..."
					uiStatusLabel.Text = "Press any key for slot " .. v_u_681 .. "..."
					uiStatusLabel.TextColor3 = C.textYellow
					local v_u_688 = nil
					v_u_688 = UserInputService.InputBegan:Connect(function(p_u_689, p690)
						if not p690 then
							if p_u_689.KeyCode == Enum.KeyCode.Escape or p_u_689.KeyCode == Enum.KeyCode.Backspace then
								v_u_685.Text = "Key"
								uiStatusLabel.Text = "Cancelled"
								uiStatusLabel.TextColor3 = C.textDim
								spawn(function() wait(2) uiStatusLabel.Text = "Ready | " .. playerFolder end)
								v_u_688:Disconnect()
							elseif p_u_689.KeyCode ~= Enum.KeyCode.Unknown then
								speedSlots[v_u_681].key = p_u_689.KeyCode.Name
								v_u_685.Text = p_u_689.KeyCode.Name:sub(1, 3)
								v_u_685.TextColor3 = C.textPrimary
								saveSpeedSlots()
								if v_u_679[v_u_681].connection then
									v_u_679[v_u_681].connection:Disconnect()
								end
								v_u_679[v_u_681].connection = UserInputService.InputBegan:Connect(function(p691, p692)
									if not p692 then
										if p691.KeyCode == p_u_689.KeyCode then
											local v693 = speedSlots[v_u_681].speed / 10
											animPlayback.speed = speedSlots[v_u_681].speed / 5
											speedSliderKnob.Position = UDim2.new(v693, -6, 0.5, -6)
											speedValueLabel.Text = string.format("%d", speedSlots[v_u_681].speed)
										end
									end
								end)
								uiStatusLabel.Text = "Bound slot " .. v_u_681 .. " -> " .. p_u_689.KeyCode.Name
								uiStatusLabel.TextColor3 = C.textGreen
								spawn(function()
									wait(2)
									uiStatusLabel.Text = "Ready | " .. playerFolder
									uiStatusLabel.TextColor3 = C.textDim
								end)
								v_u_688:Disconnect()
							end
						end
					end)
				else
					speedSlots[v_u_681].key = ""
					v_u_685.Text = "Key"
					v_u_685.TextColor3 = C.textSecond
					saveSpeedSlots()
					if v_u_679[v_u_681].connection then
						v_u_679[v_u_681].connection:Disconnect()
						v_u_679[v_u_681].connection = nil
					end
					uiStatusLabel.Text = "Unbound slot " .. v_u_681
					uiStatusLabel.TextColor3 = C.textRed
					spawn(function()
						wait(2)
						uiStatusLabel.Text = "Ready | " .. playerFolder
						uiStatusLabel.TextColor3 = C.textDim
					end)
				end
			end)
		end

		for v694 = 1, 5 do
			local v_u_695 = v694
			if speedSlots[v_u_695] then
				v_u_679[v_u_695].speedInput.Text = tostring(speedSlots[v_u_695].speed)
				if speedSlots[v_u_695].key and speedSlots[v_u_695].key ~= "" then
					v_u_679[v_u_695].keybindButton.Text = speedSlots[v_u_695].key:sub(1, 3)
					v_u_679[v_u_695].keybindButton.TextColor3 = C.textPrimary
					local v_u_696 = Enum.KeyCode[speedSlots[v_u_695].key]
					if v_u_696 then
						v_u_679[v_u_695].connection = UserInputService.InputBegan:Connect(function(p697, p698)
							if not p698 then
								if p697.KeyCode == v_u_696 then
									local v699 = speedSlots[v_u_695].speed / 10
									animPlayback.speed = speedSlots[v_u_695].speed / 5
									speedSliderKnob.Position = UDim2.new(v699, -6, 0.5, -6)
									speedValueLabel.Text = string.format("%d", speedSlots[v_u_695].speed)
								end
							end
						end)
					end
				end
			end
		end

		local allUiElements = {
			uiStatusLabel,
			tabBar,
			searchBox,
			animScrollFrame,
			speedBarFrame,
			addAnimPanel,
			statesPanel,
			helpBtn,
			addAnimBtn,
			sizePanel,
			othersPanel
		}

		local function buildAnimEntry(p_u_701)
			local v702 = Instance.new("Frame")
			v702.Size = UDim2.new(1, 0, 0, 34)
			v702.BackgroundTransparency = 1
			v702.Parent = animScrollFrame

			local isCustom = customAnims[p_u_701.name] ~= nil
			local nameWidth = isCustom and (currentTab == "custom" and -102 or -70) or -70

			local animNameBtn = Instance.new("TextButton")
			animNameBtn.Size = UDim2.new(1, nameWidth, 1, 0)
			animNameBtn.Position = UDim2.new(0, 0, 0, 0)
			animNameBtn.BackgroundColor3 = C.rowBg
			animNameBtn.BackgroundTransparency = ALPHA.row
			animNameBtn.Text = "  " .. p_u_701.name
			animNameBtn.TextColor3 = C.textPrimary
			animNameBtn.TextSize = 12
			animNameBtn.Font = Enum.Font.GothamSemibold
			animNameBtn.TextXAlignment = Enum.TextXAlignment.Left
			animNameBtn.BorderSizePixel = 0
			animNameBtn.Parent = v702

			local nameCorner = Instance.new("UICorner")
			nameCorner.CornerRadius = UDim.new(0, 8)
			nameCorner.Parent = animNameBtn

			local deleteBtn = nil
			if isCustom and currentTab == "custom" then
				deleteBtn = Instance.new("TextButton")
				deleteBtn.Size = UDim2.new(0, 32, 1, 0)
				deleteBtn.Position = UDim2.new(1, -98, 0, 0)
				deleteBtn.BackgroundTransparency = 1
				deleteBtn.Text = "X"
				deleteBtn.TextColor3 = C.textRed
				deleteBtn.TextSize = 14
				deleteBtn.BorderSizePixel = 0
				deleteBtn.Parent = v702
			end

			local favBtn = Instance.new("TextButton")
			favBtn.Size = UDim2.new(0, 32, 1, 0)
			favBtn.Position = UDim2.new(1, -66, 0, 0)
			favBtn.BackgroundTransparency = 1
			favBtn.Text = favoriteAnims[p_u_701.name] and "★" or "☆"
			favBtn.TextColor3 = favoriteAnims[p_u_701.name] and C.textGold or C.textDim
			favBtn.TextSize = 16
			favBtn.BorderSizePixel = 0
			favBtn.Parent = v702

			local keybindBtn = Instance.new("TextButton")
			keybindBtn.Size = UDim2.new(0, 32, 1, 0)
			keybindBtn.Position = UDim2.new(1, -32, 0, 0)
			keybindBtn.BackgroundTransparency = 1
			keybindBtn.Text = animKeybinds[p_u_701.name] and (animKeybinds[p_u_701.name].Name:gsub("KeyCode%.", ""):sub(1, 3)) or "Bind"
			keybindBtn.TextColor3 = animKeybinds[p_u_701.name] and C.textPrimary or C.textDim
			keybindBtn.TextSize = 8
			keybindBtn.Font = Enum.Font.Gotham
			keybindBtn.BorderSizePixel = 0
			keybindBtn.Parent = v702

			animNameBtn.MouseEnter:Connect(function()
				if animPlayback.currentId ~= tostring(p_u_701.id) then
					animNameBtn.BackgroundTransparency = ALPHA.rowH
				end
			end)
			animNameBtn.MouseLeave:Connect(function()
				if animPlayback.currentId ~= tostring(p_u_701.id) then
					animNameBtn.BackgroundTransparency = ALPHA.row
				end
			end)

			animNameBtn.MouseButton1Click:Connect(function()
				task.spawn(function()
					playAnimation(tostring(p_u_701.id))
				end)
			end)

			if deleteBtn then
				deleteBtn.MouseButton1Click:Connect(function()
					customAnims[p_u_701.name] = nil
					animationList[p_u_701.name] = nil
					animKeybinds[p_u_701.name] = nil
					favoriteAnims[p_u_701.name] = nil
					saveCustomAnims()
					saveKeybinds()
					saveFavorites()
					loadGUI()
				end)
			end

			favBtn.MouseButton1Click:Connect(function()
				if favoriteAnims[p_u_701.name] then
					favoriteAnims[p_u_701.name] = nil
					favBtn.Text = "☆"
					favBtn.TextColor3 = C.textDim
				else
					favoriteAnims[p_u_701.name] = tostring(p_u_701.id)
					favBtn.Text = "★"
					favBtn.TextColor3 = C.textGold
				end
				saveFavorites()
				if currentTab == "favorites" then
					spawn(function() wait(0.1) loadGUI() end)
				end
			end)

			keybindBtn.MouseButton1Click:Connect(function()
				if animKeybinds[p_u_701.name] then
					animKeybinds[p_u_701.name] = nil
					saveKeybinds()
					keybindBtn.Text = "Bind"
					keybindBtn.TextColor3 = C.textDim
					uiStatusLabel.Text = "Unbound " .. p_u_701.name
					uiStatusLabel.TextColor3 = C.textRed
					spawn(function()
						wait(2)
						uiStatusLabel.Text = "Ready | " .. playerFolder
						uiStatusLabel.TextColor3 = C.textDim
					end)
					return
				elseif not isBindingKey then
					isBindingKey = true
					bindingAnimName = p_u_701.name
					uiStatusLabel.Text = "Press any key to bind..."
					uiStatusLabel.TextColor3 = C.textYellow
					keybindBtn.Text = "..."
					local v_u_710 = nil
					v_u_710 = UserInputService.InputBegan:Connect(function(p711, p712)
						if p712 then return
						elseif isBindingKey and bindingAnimName == p_u_701.name then
							if p711.KeyCode == Enum.KeyCode.Escape or p711.KeyCode == Enum.KeyCode.Backspace then
								keybindBtn.Text = "Bind"
								keybindBtn.TextColor3 = C.textDim
								uiStatusLabel.Text = "Binding cancelled"
								uiStatusLabel.TextColor3 = C.textDim
								spawn(function() wait(2) uiStatusLabel.Text = "Ready | " .. playerFolder end)
								isBindingKey = false
								bindingAnimName = nil
								v_u_710:Disconnect()
							elseif p711.KeyCode ~= Enum.KeyCode.Unknown then
								animKeybinds[p_u_701.name] = p711.KeyCode
								saveKeybinds()
								keybindBtn.Text = p711.KeyCode.Name:gsub("KeyCode%.", ""):sub(1, 3)
								keybindBtn.TextColor3 = C.textPrimary
								uiStatusLabel.Text = "Bound -> " .. p711.KeyCode.Name:gsub("KeyCode%.", "")
								uiStatusLabel.TextColor3 = C.textGreen
								spawn(function()
									wait(2)
									uiStatusLabel.Text = "Ready | " .. playerFolder
									uiStatusLabel.TextColor3 = C.textDim
								end)
								isBindingKey = false
								bindingAnimName = nil
								v_u_710:Disconnect()
							end
						else
							v_u_710:Disconnect()
						end
					end)
				end
			end)

			animEntryRefs[p_u_701.name] = {
				["Container"]      = v702,
				["NameButton"]     = animNameBtn,
				["FavoriteButton"] = favBtn,
				["KeybindButton"]  = keybindBtn,
				["DeleteButton"]   = deleteBtn
			}
		end

		function loadGUI()
			for _, child in pairs(animScrollFrame:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			animEntryRefs = {}

			local showAddPanel
			if currentTab ~= "custom" then
				showAddPanel = false
			else
				showAddPanel = addAnimPanelOpen
			end
			addAnimPanel.Visible = showAddPanel
			addAnimBtn.Visible = currentTab == "custom"
			statesPanel.Visible = currentTab == "states"
			sizePanel.Visible = currentTab == "size"
			othersPanel.Visible = currentTab == "others"
			animScrollFrame.Visible = currentTab ~= "states" and currentTab ~= "size" and currentTab ~= "others"
			searchBox.Visible = currentTab ~= "states" and currentTab ~= "size" and currentTab ~= "others"
			helpBtn.Visible = currentTab == "custom" or currentTab == "states"

			if animScrollFrame.Visible then
				if currentTab ~= "custom" then
					animScrollFrame.Size = UDim2.new(1, -16, 1, -175)
					animScrollFrame.Position = UDim2.new(0, 8, 0, 104)
				elseif addAnimPanelOpen then
					animScrollFrame.Size = UDim2.new(1, -16, 1, -270)
					animScrollFrame.Position = UDim2.new(0, 8, 0, 195)
				else
					animScrollFrame.Size = UDim2.new(1, -16, 1, -205)
					animScrollFrame.Position = UDim2.new(0, 8, 0, 134)
				end

				local v721 = {}
				local v722 = searchBox.Text:lower()
				local v723 = currentTab == "custom" and customAnims or animationList

				for v726, v727 in pairs(v723) do
					if (currentTab ~= "favorites" or favoriteAnims[v726] ~= nil) and (v722 == "" or v726:lower():find(v722)) then
						table.insert(v721, { ["name"] = v726, ["id"] = v727 })
					end
				end
				table.sort(v721, function(a, b) return a.name < b.name end)
				for _, entry in pairs(v721) do
					buildAnimEntry(entry)
				end
				spawn(function()
					wait(0.1)
					animScrollFrame.CanvasSize = UDim2.new(0, 0, 0, animListLayout.AbsoluteContentSize.Y + 10)
				end)
			end
		end

		local speedDragging = false
		local function setAnimSpeed(p735)
			local v736 = math.floor(p735 * 10 + 0.5)
			animPlayback.speed = v736 / 5
			speedSliderKnob.Position = UDim2.new(p735, -6, 0.5, -6)
			speedValueLabel.Text = string.format("%d", v736)
		end
		local function updateSpeedSlider(p738)
			setAnimSpeed(math.clamp((p738.Position.X - speedSliderTrack.AbsolutePosition.X) / speedSliderTrack.AbsoluteSize.X, 0, 1))
		end
		local function resetAnimSpeed()
			animPlayback.speed = 1
			speedSliderKnob.Position = UDim2.new(0.5, -6, 0.5, -6)
			speedValueLabel.Text = "5"
		end
		spawn(function()
			wait(0.1)
			speedSliderKnob.Position = UDim2.new(0.5, -6, 0.5, -6)
			speedValueLabel.Text = "5"
		end)
		speedSliderTrack.InputBegan:Connect(function(p741)
			if p741.UserInputType == Enum.UserInputType.MouseButton1 or p741.UserInputType == Enum.UserInputType.Touch then
				speedDragging = true
				updateSpeedSlider(p741)
			end
		end)
		UserInputService.InputChanged:Connect(function(p742)
			if speedDragging and (p742.UserInputType == Enum.UserInputType.MouseMovement or p742.UserInputType == Enum.UserInputType.Touch) then
				updateSpeedSlider(p742)
			end
		end)
		UserInputService.InputEnded:Connect(function(p743)
			if p743.UserInputType == Enum.UserInputType.MouseButton1 or p743.UserInputType == Enum.UserInputType.Touch then
				speedDragging = false
			end
		end)
		resetSpeedBtn.MouseButton1Click:Connect(resetAnimSpeed)
		resetSpeedBtn.MouseEnter:Connect(function() resetSpeedBtn.BackgroundTransparency = ALPHA.btnH end)
		resetSpeedBtn.MouseLeave:Connect(function() resetSpeedBtn.BackgroundTransparency = ALPHA.btn end)

		closeBtn.MouseButton1Click:Connect(function()
			stopAnimation()
			if reanimEnabled then setReanimEnabled(false) end
			screenGui:Destroy()
		end)
		closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundTransparency = ALPHA.btnH end)
		closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundTransparency = ALPHA.btn end)

		minimizeBtn.MouseButton1Click:Connect(function()
			if not minimizeAnimating then
				minimizeAnimating = true
				if isMinimized then
					local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ["Size"] = UDim2.new(0, 315, 0, 480) })
					minimizeBtn.Text = "-"
					isMinimized = false
					tw:Play()
					tw.Completed:Connect(function()
						for _, el in pairs(allUiElements) do
							if el == addAnimPanel then
								el.Visible = currentTab == "custom" and addAnimPanelOpen
							elseif el == addAnimBtn then
								el.Visible = currentTab == "custom"
							elseif el == statesPanel then
								el.Visible = currentTab == "states"
							elseif el == sizePanel then
								el.Visible = currentTab == "size"
							elseif el == othersPanel then
								el.Visible = currentTab == "others"
							elseif el == helpBtn then
								el.Visible = currentTab == "custom" or currentTab == "states"
							elseif el == animScrollFrame or el == searchBox then
								el.Visible = currentTab ~= "states" and currentTab ~= "size" and currentTab ~= "others"
							else
								el.Visible = true
							end
						end
						minimizeAnimating = false
					end)
				else
					for _, el in pairs(allUiElements) do el.Visible = false end
					local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ["Size"] = UDim2.new(0, 315, 0, 30) })
					minimizeBtn.Text = "+"
					isMinimized = true
					tw:Play()
					tw.Completed:Connect(function() minimizeAnimating = false end)
				end
			end
		end)
		minimizeBtn.MouseEnter:Connect(function() minimizeBtn.BackgroundTransparency = ALPHA.btnH end)
		minimizeBtn.MouseLeave:Connect(function() minimizeBtn.BackgroundTransparency = ALPHA.btn end)

		searchBox:GetPropertyChangedSignal("Text"):Connect(loadGUI)

		local function setTab(key)
			currentTab = key
			addAnimPanelOpen = false
			for k, btn in pairs(tabBtns) do
				if k == key then
					btn.BackgroundColor3 = C.tabActive
					btn.BackgroundTransparency = ALPHA.tabA
					btn.TextColor3 = C.textPrimary
				else
					btn.BackgroundColor3 = C.tabIdle
					btn.BackgroundTransparency = ALPHA.tab
					btn.TextColor3 = C.textSecond
				end
			end
			loadGUI()
		end
		for key, btn in pairs(tabBtns) do
			local k = key
			btn.MouseButton1Click:Connect(function() setTab(k) end)
		end

		addAnimBtn.MouseButton1Click:Connect(function()
			if addAnimPanelOpen then
				local v755 = newAnimNameBox.Text
				local v756 = newAnimCodeBox.Text
				if v755 == "" or v756 == "" then
					uiStatusLabel.Text = "Name and code required!"
					uiStatusLabel.TextColor3 = C.textRed
					spawn(function()
						wait(2)
						uiStatusLabel.Text = "Ready | " .. playerFolder
						uiStatusLabel.TextColor3 = C.textDim
					end)
					return
				end
				customAnims[v755] = v756
				animationList[v755] = v756
				saveCustomAnims()
				newAnimNameBox.Text = ""
				newAnimCodeBox.Text = ""
				addAnimPanelOpen = false
				addAnimPanel.Visible = false
				addAnimBtn.Text = "Add"
				addAnimBtn.BackgroundColor3 = C.btnBg
				animScrollFrame.Size = UDim2.new(1, -16, 1, -175)
				animScrollFrame.Position = UDim2.new(0, 8, 0, 104)
				uiStatusLabel.Text = "Added: " .. v755
				uiStatusLabel.TextColor3 = C.textGreen
				spawn(function()
					wait(2)
					uiStatusLabel.Text = "Ready | " .. playerFolder
					uiStatusLabel.TextColor3 = C.textDim
				end)
				loadGUI()
			else
				addAnimPanelOpen = true
				addAnimPanel.Visible = true
				addAnimBtn.Text = "Save"
				addAnimBtn.BackgroundColor3 = C.toggleOn
				animScrollFrame.Size = UDim2.new(1, -16, 1, -270)
				animScrollFrame.Position = UDim2.new(0, 8, 0, 195)
			end
		end)
		addAnimBtn.MouseEnter:Connect(function() addAnimBtn.BackgroundTransparency = ALPHA.btnH end)
		addAnimBtn.MouseLeave:Connect(function() addAnimBtn.BackgroundTransparency = ALPHA.btn end)

		local isDraggingWindow = false
		local dragStartPos = nil
		local dragStartFramePos = nil

		headerBar.InputBegan:Connect(function(p766)
			if p766.UserInputType == Enum.UserInputType.MouseButton1 or p766.UserInputType == Enum.UserInputType.Touch then
				isDraggingWindow = true
				dragStartPos = p766.Position
				dragStartFramePos = mainFrame.Position
			end
		end)
		UserInputService.InputChanged:Connect(function(p767)
			if isDraggingWindow and (p767.UserInputType == Enum.UserInputType.MouseMovement or p767.UserInputType == Enum.UserInputType.Touch) then
				local delta = p767.Position - dragStartPos
				mainFrame.Position = UDim2.new(dragStartFramePos.X.Scale, dragStartFramePos.X.Offset + delta.X, dragStartFramePos.Y.Scale, dragStartFramePos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(p768)
			if p768.UserInputType == Enum.UserInputType.MouseButton1 or p768.UserInputType == Enum.UserInputType.Touch then
				isDraggingWindow = false
			end
		end)

		uiStatusLabel.Text = "Loading animations..."
		uiStatusLabel.TextColor3 = C.textYellow
		spawn(function()
			wait(1)
			local count = 0
			for _ in pairs(animationList) do count = count + 1 end
			uiStatusLabel.Text = "Loaded " .. count .. " anims  •  " .. playerFolder
			uiStatusLabel.TextColor3 = C.textGreen
			loadGUI()
			spawn(function()
				wait(3)
				uiStatusLabel.Text = "Ready | " .. playerFolder
				uiStatusLabel.TextColor3 = C.textDim
			end)
		end)
	end
end

UserInputService.InputBegan:Connect(function(p774, p775)
	if p775 then return end
	for v778, v779 in pairs(animKeybinds) do
		if p774.KeyCode == v779 then
			local v780 = customAnims[v778] or animationList[v778] or favoriteAnims[v778]
			if v780 then
				playAnimation(tostring(v780))
			end
			break
		end
	end
end)

task.spawn(function()
	loadAllData()
	loadSpeedSlots()
	buildGui()
end)

print("Custom emotes drop folder: " .. jsonDropFolder)
print("JSON format: {\"AnimName\":\"animId\"} or [{\"name\":\"AnimName\",\"id\":\"animId\"}]")