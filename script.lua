--[[
	FE Punch Script
	By minishakk

	R15 ONLY | ONLY WORKS ON NPCs AND NOT REAL PLAYERS!!!
	
	Controls:
		Left Click - Punch
		R - Ragdoll Mode (ragdolls the character instead of killing)
		E - KILL Mode (on by default, kills the character)

	Click to punch NPCs [FE] and turn them to dust ;)

	Don't redistribute without permission, or before contacting @minishakk on Discord.
]]

local mode = "Kill"

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
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

local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://2885006854"
hitSound.Volume = 1
hitSound.Parent = handle

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

StarterGui:SetCore("SendNotification", {
	Title = "FE Punch",
	Text = "by minishakk. Ragdolls (R) or Kills (E) NPCs",
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
		game:GetService("Debris"):AddItem(force, 0.5)
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
	wait(1)
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Position = position
	part.Parent = workspace

	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxassetid://102626391021863"
	emitter.Rate = 50
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.Speed = NumberRange.new(5, 10)
	emitter.VelocitySpread = 50
	emitter.Color = ColorSequence.new(Color3.new(0.6, 0, 0))
	emitter.Parent = part

	emitter:Emit(1)
	game:GetService("Debris"):AddItem(part, 2)
end

local isPunching = false
local function animations()
	if isPunching then return end
	isPunching = true

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
				isPunching = false
			end)
		else
			isPunching = false
		end
	else
		isPunching = false
	end
end

local function audio()
	hitSound:Play()
	task.wait(1)
	for i = 1, 3 do
		smackSound:Play()
		task.wait(0.5)
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
			task.spawn(audio)
			bleed(head.Position)

			task.wait(1.5)
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
						game:GetService("Debris"):AddItem(force, 0.5)
					end

					task.wait(0.3)
					kscreamSound:Play()
					character:BreakJoints() -- brodie is cooked
					
				elseif mode == "Ragdoll" then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					task.wait(0.1)
					rscreamSound:Play()
					ragdoll(character) -- brodie is sizzled
				end
			end
		end
	end
end

local equipped = false
local mouseDownConnection

tool.Equipped:Connect(function()
	equipped = true
	equipSound:Play()
	mouseDownConnection = mouse.Button1Down:Connect(function()
		if equipped and mouse.Target then
			punch(mouse.Target)
		end
	end)
end)

tool.Unequipped:Connect(function()
	equipped = false
	if mouseDownConnection then
		mouseDownConnection:Disconnect()
		mouseDownConnection = nil
	end
end)

mouse.KeyDown:Connect(function(key)
	key = key:lower()
	if key == "e" then
		mode = "Kill"
		StarterGui:SetCore("SendNotification", {
			Title = "Mode Changed",
			Text = "Kill Mode Activated",
			Icon = "rbxassetid://16952938318",
			Duration = 2
		})
	elseif key == "r" then
		mode = "Ragdoll"
		StarterGui:SetCore("SendNotification", {
			Title = "Mode Changed",
			Text = "Ragdoll Mode Activated",
			Icon = "rbxassetid://16952938318",
			Duration = 2
		})
	end
end)

tool.Parent = player.Backpack -- gives you the power :)
