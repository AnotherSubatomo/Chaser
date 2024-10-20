
--[=[
	[INTERNAL] Responsible for managing
	the existance of the cameraman.

	* ONLY ONE CAMERAMAN MUST EXIST AT A TIME.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict

local Run = game:GetService('RunService')
local EXCEPTION = require(script.Parent.Exception)

local Client = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Cameraman = {}
local ReferenceName = 'CameramanReference'

export type Character = Model & { Humanoid : Humanoid }

local function FetchClientChar() : Character
	local Char = Client.Character or Client.CharacterAdded:Wait()
	task.wait()
	return Char
end

function Cameraman.create() : Character
	assert(Run:IsClient(), EXCEPTION(1))
	if Camera:FindFirstChild(ReferenceName) then return end

	local Character = FetchClientChar()
	Character.Archivable = true

	local Dummy = Character:Clone()
	Character.Archivable = false
	Dummy.Name ..= "_Cameraman"
	
	local DummyHumanoid = Dummy.Humanoid
	local DummyReference = Instance.new('ObjectValue')
	
	DummyReference.Parent = Camera
	DummyReference.Name = ReferenceName
	DummyReference.Value = Dummy
	DummyHumanoid:RemoveAccessories()

	for _, Child : Instance in Dummy:GetChildren() do
		if not Child:IsA('BasePart') then continue end
		Child.Material = Enum.Material.ForceField
		Child.Transparency = 1
	end
	
	Dummy:PivotTo(CFrame.new(Character.PrimaryPart.Position + Vector3.new(4, 0, 4)))
	Dummy.Parent = workspace

	Camera.CameraSubject = DummyHumanoid
	return Dummy
end

function Cameraman.destroy()
	assert(Run:IsClient(), EXCEPTION(1))

	local DummyReference = Camera:FindFirstChild(ReferenceName)
	
	if DummyReference then
		local Dummy = DummyReference.Value
		Camera.CameraSubject = FetchClientChar().Humanoid
		Dummy:Destroy()
		return
	end

	warn( '@SECOND-Cameraman: Destroy operation failed. '..
		  'CameramanReference did not exist within the camera.' )
end

return table.freeze(setmetatable({}, {__index = Cameraman}))