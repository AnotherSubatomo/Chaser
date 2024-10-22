
--[=[
	[INTERNAL] Responsible for managing
	the existance of the cameraman.

	* The abstraction is called a 'Cameraman'
	* The actual rig behind the abstraction is referenced as the 'Operator'

	Last Committed:	22/10/2024 - 11:34 PM
]=]

--!native
--!nonstrict

--[[
	TODO:
	* Figure out how to cancel cameraman and userchar collisions
]]

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Run = game:GetService('RunService')
local Client = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

export type Character = Model & {
	Humanoid : Humanoid ;
	Head : BasePart ;
}

local CameramanUID = game:GetService('HttpService'):GenerateGUID(false):sub(1, 10)

local function FetchCameraman()
	-- Return it if it already exists
	local QOperator = game:GetService('CollectionService'):GetTagged(CameramanUID)[1]
	if QOperator then return QOperator end
	
	-- Make the cameraman
	repeat task.wait()
	until Client.Character ~= nil

	local Character = Client.Character
	Character.Archivable = true

	local Operator = Character:Clone()
	Operator.Name = CameramanUID.."_Cameraman"
	Operator:AddTag(CameramanUID)
	Character.Archivable = false

	Operator.Humanoid.Health = math.huge
	Operator.Humanoid:RemoveAccessories()

	for _ , Child : Instance in Operator:GetChildren() do
		if not Child:IsA('BasePart') then continue end
		Child.Material = Enum.Material.ForceField
		Child.Transparency = 1
	end
	
	return Operator
end

local Cameraman = {}

-- * Changes to these properties after employment ( :Employ() )
--	 will not reflect until the next employment after dismissal.
Cameraman.Subject = Client
Cameraman.Distance = 10
Cameraman.WalkSpeedRatio = 0.75

local DismissingSignal = Instance.new('BindableEvent')
Cameraman.Dismissing = DismissingSignal.Event

function Cameraman:GetSubjectChar() : Character
	repeat task.wait()
	until self.Subject.Character ~= nil
	return self.Subject.Character
end

-- Relocate cameraman to player
function Cameraman:Snap()
	local Character = self:GetSubjectChar()
	local Operator = FetchCameraman()

	Operator:PivotTo( CFrame.new(
		Character:GetPivot().Position -
		Character:GetPivot().LookVector.Unit * self.Distance
	))
end

function Cameraman:Employ() : Character
	local Character = self:GetSubjectChar()
	local Operator = FetchCameraman()
	if Operator:IsDescendantOf(workspace) then return Operator end
	
	self:Snap()
	Operator.Parent = workspace
	Camera.CameraSubject = Operator.Humanoid
	
	-- Match cameraman's walkspeed with the character's
	Operator.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed * self.WalkSpeedRatio
	
	self.__Connections = {
		-- Responsible for synchronizing character's walkspeed with the cameraman's
		Character.Humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect( function()
			Operator.Humanoid.WalkSpeed = Character.Humanoid.WalkSpeed * self.WalkSpeedRatio
		end);

		-- Responsible for making the camera focus on the client
		Run.RenderStepped:Connect( function()
			Camera.CFrame = CFrame.lookAt(Operator.Head.Position, Character.Head.Position)
		end);

		-- When the client dies
		Character.Humanoid.Died:Connect( function()
			self:Dismiss()
			self:Employ()
		end);
	}

	return Operator
end

function Cameraman:Dismiss()
	local Operator = FetchCameraman()
	if Operator:IsDescendantOf(ReplicatedStorage) then return Operator end

	local Character = self:GetSubjectChar()
	local ClientHumanoid = Character.Humanoid

	for _ , Connection : RBXScriptConnection in self.__Connections do
		Connection:Disconnect()
	end
	
	-- Let functions hooked to the dismissing signal finish first
	DismissingSignal:Fire()
	task.wait()

	Camera.CameraSubject = ClientHumanoid
	Operator.Parent = ReplicatedStorage
end

return Cameraman