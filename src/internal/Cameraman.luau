
--[=[
	[INTERNAL] Responsible for managing
	the existance of the cameraman.

	* The abstraction is called a 'Cameraman'
	* The actual rig behind the abstraction is referenced as the 'Operator'

	Last Committed:	22/10/2024 - 4:08 PM
]=]

--!native
--!nonstrict

local Client = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

type Character = Model & {
	Humanoid : Humanoid ;
	Head : BasePart ;
}

local function GetCharacter() : Character
	repeat task.wait() until Client.Character ~= nil
	return Client.Character
end

local CameramanUID = game:GetService('HttpService'):GenerateGUID(false)
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Run = game:GetService('RunService')

local function FetchCameraman()
	-- Return it if it already exists
	local QOperator = game:GetService('CollectionService'):GetTagged(CameramanUID)[1]
	if QOperator then return QOperator end
	
	-- Make the cameraman
	local Character = GetCharacter()
	Character.Archivable = true

	local Operator = Character:Clone()
	Operator.Name ..= CameramanUID
	Operator:AddTag(CameramanUID)
	Character.Archivable = false

	Operator.Humanoid.Health = math.huge
	Operator.Humanoid:RemoveAccessories()

	for _ , Child : Instance in Operator:GetChildren() do
		if not Child:IsA('BasePart') then continue end
		Child.Material = Enum.Material.ForceField
		Child.Transparency = 1
		
		-- TO-KNOW: how the fuck is this not working?!
		local NoCollision = Instance.new('NoCollisionConstraint')
		NoCollision.Parent = Child
		NoCollision.Part0 = Child
		NoCollision.Part1 = Character:FindFirstChild(Child.Name)
		NoCollision.Enabled = true
	end
	
	return Operator
end

local Cameraman = {}
Cameraman.Distance = 10
Cameraman.WalkSpeedRatio = 0.75

local DismissingSignal = Instance.new('BindableEvent')
Cameraman.Dismissing = DismissingSignal.Event

-- Relocate cameraman to player
function Cameraman:Snap()
	local Character = GetCharacter()
	local Operator = FetchCameraman()

	Operator:PivotTo( CFrame.new(
		Character.Head.Position -
		Character.Head.CFrame.LookVector.Unit * self.Distance
	))
end

function Cameraman:Employ() : Character
	local Character = GetCharacter()
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

		-- When the cameraman dies
		Operator.Humanoid.Died:Connect( function()
			self:Dismiss()
		end)
	}

	return Operator
end

function Cameraman:Dismiss()
	local Operator = FetchCameraman()
	if Operator:IsDescendantOf(ReplicatedStorage) then return Operator end

	local Character = GetCharacter()
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