--[[
  FE Punch Script
  By minishakk

  R15 ONLY

  Click to punch NPCs [FE] and turn them to dust ;)

  Don't redistribute without permission, or before contacting @minishakk on Discord.
]]

local Players = game:GetService("Players")
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

game:GetService("StarterGui"):SetCore("SendNotification", {
	Title = "FE Punch",
	Text = "by @minishakk. Ragdolls and kills NPCs",
	Icon = "rbxassetid://16952938318"
})

local equipped = false
local mouseDownConnection
local isPunching = false

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

local function pSounds()
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
			task.spawn(pSounds)
			bleed(head.Position)

			task.wait(2.5)
			if humanoid and humanoid.Health > 0 then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				task.wait(0.2)
				humanoid:ChangeState(Enum.HumanoidStateType.Dead)
			end
		end
	end
end

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

tool.Parent = player.Backpack
