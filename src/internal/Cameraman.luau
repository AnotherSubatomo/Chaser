
--[=[
	[INTERNAL] Responsible for managing
	the existance of the cameraman.
	Last Committed:	21/10/2024 - 9:05 PM
]=]

--!native
--!strict

local Run = game:GetService('RunService')
local EXCEPTION = require(script.Parent.Exception)

local Client = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Cameraman = {}

-- Make the cameraman
assert(Run:IsClient(), EXCEPTION(1))

repeat task.wait()
until Client.Character ~= nil

local Character = Client.Character
Character.Archivable = true

local Dummy = Character:Clone()
Dummy.Name ..= "_Cameraman"
Character.Archivable = false

local DummyHumanoid = Dummy.Humanoid
DummyHumanoid.Health = math.huge
DummyHumanoid:RemoveAccessories()

for _, Child : Instance in Dummy:GetChildren() do
	if not Child:IsA('BasePart') then continue end
	Child.Material = Enum.Material.ForceField
	Child.Transparency = 1
end

------------------------- MAIN INTERFACE -------------------------

local DismissingSignal = Instance.new('BindableEvent')
Cameraman.Dismissing = DismissingSignal.Event

function Cameraman.employ() : Model & { Humanoid : Humanoid }
	repeat task.wait() until Client.Character ~= nil
	local RootPart = Client.Character.PrimaryPart
	
	Dummy:PivotTo(CFrame.new(RootPart.Position + RootPart.CFrame.LookVector.Unit * 5))
	Dummy.Parent = workspace
	Camera.CameraSubject = DummyHumanoid
	return Dummy
end

function Cameraman.dismiss()
	repeat task.wait() until Client.Character ~= nil
	local ClientHumanoid = Client.Character.Humanoid

	DismissingSignal:Fire()
	Dummy.Parent = game.ReplicatedStorage
	Camera.CameraSubject = ClientHumanoid
end

return Cameraman