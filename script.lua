--[[
	FE Punch Script (v2)
	By minishakk

	R15 ONLY | ONLY WORKS ON NPCs or DUMMYS AND NOT REAL PLAYERS!!!
	
	Controls:
		Left Click - Punch
		R - Ragdoll Mode (ragdolls the character instead of killing)
		E - Kill Mode (immediately kills the character)
		F - Progressive Mode (increasing damage, on by default)
		
	Changelog:
		7/22/2025 [9:44 PM] - Initial release (v1.0)
		7/23/2025 [10:23 AM] - Updated animations (v1.05)
		7/23/2025 [11:45 AM] - Added ragdoll/kill modes (v1.1)
		7/24/2025 [1:30 PM] - Added realistic blood/camera effects (v1.2)
		
		7/24/2025 [3:18 PM] - Update was so big, had to make this v2. Here is a list of changes:
			- New "Progressive" mode, which damages the character using ragdoll, and when low, uses the kill mode.
			- Default mode switched to "Progressive".
			- New mode icons and sounds on switch to match.
			- Revamped blood, audio, and camera effects.

	Click to punch NPCs [FE] and turn them to dust ;)

	Don't redistribute without permission, or before contacting @minishakk on Discord.
]]

local mode = "Progressive" -- change for ragdoll or kill mode at script launch. You can always switch while running the script.

local punchCounts = {} -- used for progressive mode.
local healthPerHit = 30 -- also used for progressive mode.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
repeat task.wait() until player and player:FindFirstChild("Backpack")
local mouse = player:GetMouse()

local tool = Instance.new("Tool")
tool.Name = "Iron Fist"
tool.CanBeDropped = false
tool.RequiresHandle = true

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 1, 1)
handle.Transparency = 1
handle.CanCollide = false
handle.Parent = tool

local fistSound = Instance.new("Sound")
fistSound.SoundId = "rbxassetid://2885006854"
fistSound.Volume = 1
fistSound.Parent = handle

local smackSound = Instance.new("Sound")
smackSound.SoundId = "rbxassetid://9117970193"
smackSound.Volume = 1
smackSound.Parent = handle

local equipSound = Instance.new("Sound")
equipSound.SoundId = "rbxassetid://6784421247"
equipSound.Parent = handle

local rscreamSound = Instance.new("Sound")
rscreamSound.SoundId = "rbxassetid://6108565657"
rscreamSound.Parent = handle

local kscreamSound = Instance.new("Sound")
kscreamSound.SoundId = "rbxassetid://7772283448"
kscreamSound.Parent = handle

-- BONE SOUNDS

local boneSound1 = Instance.new("Sound")
boneSound1.SoundId = "rbxassetid://9113544629"
boneSound1.Volume = 1
boneSound1.Parent = handle

local boneSound2 = Instance.new("Sound")
boneSound2.SoundId = "rbxassetid://7837512412"
boneSound2.Volume = 1
boneSound2.Parent = handle

local boneSound3 = Instance.new("Sound")
boneSound3.SoundId = "rbxassetid://82176913611683"
boneSound3.Volume = 1
boneSound3.Parent = handle

StarterGui:SetCore("SendNotification", {
	Title = "FE Punch",
	Text = "by minishakk. Tortures NPCs. Controls: E, R, F",
	Icon = "rbxassetid://16952938318"
})

local function ragdoll(character)
	local motors = {}

	for _, motor in ipairs(character:GetDescendants()) do
		if motor:IsA("Motor6D") then
			local part0, part1 = motor.Part0, motor.Part1
			if part0 and part1 then
				table.insert(motors, {
					Name = motor.Name,
					Parent = motor.Parent,
					Part0 = part0,
					Part1 = part1,
					C0 = motor.C0,
					C1 = motor.C1,
				})

				local a0 = Instance.new("Attachment")
				a0.CFrame = motor.C0
				a0.Name = "RagdollAttachment0"
				a0.Parent = part0

				local a1 = Instance.new("Attachment")
				a1.CFrame = motor.C1
				a1.Name = "RagdollAttachment1"
				a1.Parent = part1

				local constraint = Instance.new("BallSocketConstraint")
				constraint.Attachment0 = a0
				constraint.Attachment1 = a1
				constraint.Name = "RagdollConstraint"
				constraint.Parent = part0
			end
			motor:Destroy()
		end
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local force = Instance.new("BodyVelocity")
		force.Velocity = root.CFrame.LookVector * 50
		force.MaxForce = Vector3.new(1e5, 0, 1e5)
		force.P = 1e4
		force.Parent = root
		Debris:AddItem(force, 0.5)
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	end

	task.wait(3)

	for _, desc in ipairs(character:GetDescendants()) do
		if desc:IsA("BallSocketConstraint") and desc.Name == "RagdollConstraint" then
			desc:Destroy()
		elseif desc:IsA("Attachment") and (desc.Name == "RagdollAttachment0" or desc.Name == "RagdollAttachment1") then
			desc:Destroy()
		end
	end

	for _, data in ipairs(motors) do
		local m = Instance.new("Motor6D")
		m.Name = data.Name
		m.Part0 = data.Part0
		m.Part1 = data.Part1
		m.C0 = data.C0
		m.C1 = data.C1
		m.Parent = data.Parent
	end

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

local function bleed(position)
	local dir = Vector3.new(
		math.random(-100, 100) / 100,
		math.random(-100, 100) / 100,
		math.random(-100, 100) / 100
	).Unit

	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.CFrame = CFrame.new(position, position + dir)
	part.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://12532663797"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.Speed = NumberRange.new(10, 10)
	emitter.VelocitySpread = 0
	emitter.Color = ColorSequence.new(Color3.new(0.6, 0, 0))
	emitter.EmissionDirection = Enum.NormalId.Front
	emitter.Acceleration = Vector3.new(0, -20, 0)
	emitter.Parent = part

	emitter:Emit(1)
	Debris:AddItem(part, 2)
end

local function flash()
	local gui = Instance.new("ScreenGui")
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.new(0.545098, 0.231373, 0.235294)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	local tween = TweenService:Create(frame, TweenInfo.new(0.1), {BackgroundTransparency = 0.5})
	tween:Play()
	tween.Completed:Wait()

	local outTween = TweenService:Create(frame, TweenInfo.new(0.2), {BackgroundTransparency = 1})
	outTween:Play()
	outTween.Completed:Wait()

	gui:Destroy()
end

local function shake()
	local cam = workspace.CurrentCamera
	if not cam then return end

	local originalCFrame = cam.CFrame
	local originalCameraType = cam.CameraType
	
	cam.CameraType = Enum.CameraType.Scriptable

	local shakes = 6
	local magnitude = 5

	for i = 1, shakes do
		local offset = Vector3.new(
			math.random(-100, 100) / 1000,
			math.random(-100, 100) / 1000,
			math.random(-100, 100) / 1000
		) * magnitude

		cam.CFrame = originalCFrame * CFrame.new(offset)
		task.wait(0.01)
	end

	cam.CFrame = originalCFrame
	cam.CameraType = originalCameraType
end

local punching = false
local function animations()
	if punching then return end
	punching = true

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
			local animation = Instance.new("Animation")
			animation.AnimationId = "rbxassetid://10717116749"
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = false
			track:Play()
			track.Stopped:Connect(function()
				punching = false
			end)
		else
			punching = false
		end
	else
		punching = false
	end
end

local function audio(targetCharacter)
	fistSound:Play()
	task.wait(0.5)

	local boneSounds = {boneSound1, boneSound2, boneSound3}

	for i = 1, 3 do
		if i <= 2 then
			smackSound:Play()
		end
		boneSounds[i]:Play()

		flash()
		task.spawn(shake)

		if targetCharacter then
			local torso = targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso")
			if torso then
				bleed(torso.Position + Vector3.new(
					math.random(-100, 100) / 100,
					math.random(-100, 100) / 100,
					math.random(-100, 100) / 100
				))
			end
		end

		task.wait(0.3)
	end
end

local function gotoNPC(target)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local head = target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Head")
	if not head then return end

	local look = head.CFrame.LookVector
	local offset = look * -2
	local newPos = head.Position + offset
	root.CFrame = CFrame.new(newPos, head.Position)
end

local function punch(target)
	local character = target:FindFirstAncestorOfClass("Model")
	if character and character ~= player.Character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local head = character:FindFirstChild("Head")
		if humanoid and head then
			gotoNPC(target)
			animations()
			task.spawn(function() audio(character) end)

			task.wait(2)
			if humanoid and humanoid.Health > 0 then
				if mode == "Kill" then
					humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)

					local root = character:FindFirstChild("HumanoidRootPart")
					if root then
						local force = Instance.new("BodyVelocity")
						force.Velocity = root.CFrame.LookVector * 50
						force.MaxForce = Vector3.new(1e5, 0, 1e5)
						force.P = 1e4
						force.Parent = root
						Debris:AddItem(force, 0.5)
					end
					
					kscreamSound:Play()
					humanoid.Health = 0
				elseif mode == "Ragdoll" then
					rscreamSound:Play()
					ragdoll(character)
				elseif mode == "Progressive" then
					local id = character
					punchCounts[id] = (punchCounts[id] or 0) + 1

					if punchCounts[id] < 3 then
						rscreamSound:Play()
						ragdoll(character)

						local newHealth = math.max(humanoid.Health - healthPerHit, 1)
						humanoid.Health = newHealth

					else
						humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)

						local root = character:FindFirstChild("HumanoidRootPart")
						if root then
							local force = Instance.new("BodyVelocity")
							force.Velocity = root.CFrame.LookVector * 50
							force.MaxForce = Vector3.new(1e5, 0, 1e5)
							force.P = 1e4
							force.Parent = root
							Debris:AddItem(force, 0.5)
						end

						kscreamSound:Play()
						humanoid.Health = 0
						punchCounts[id] = nil
					end
				end
			end
		end
	end
end

tool.Equipped:Connect(function()
	equipSound:Play()
end)

tool.Activated:Connect(function()
	if punching then return end

	local target = mouse.Target
	if target and target.Parent then
		punch(target)
	end
end)

mouse.KeyDown:Connect(function(key)
	if key == "r" then
		mode = "Ragdoll"
		StarterGui:SetCore("SendNotification", {
			Title = "FE Punch",
			Text = "Ragdoll mode enabled.",
			Icon = "rbxassetid://16142074920",
			Duration = 2
		})
	elseif key == "e" then
		mode = "Kill"
		StarterGui:SetCore("SendNotification", {
			Title = "FE Punch",
			Text = "Kill mode enabled.",
			Icon = "rbxassetid://9583486345",
			Duration = 2
		})
	elseif key == "f" then
		mode = "Progressive"
		StarterGui:SetCore("SendNotification", {
			Title = "FE Punch",
			Text = "Progressive mode enabled.",
			Icon = "rbxassetid://74033962087144",
			Duration = 2
		})
	end
end)

tool.Parent = player.Backpack -- gives you the power ;)
