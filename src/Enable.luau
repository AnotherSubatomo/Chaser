
--[=[
	Responsible for managing the cameraman's pathfinding.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict


local Run = game:GetService('RunService')
local Client = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local root = script.Parent
local internal = root.internal
local Pathfinder = require(internal.Pathfinder)
local MCameraman = require(internal.Cameraman)
local EXCEPTION = require(internal.Exception)

local CameramanConfig = {
	AgentRadius = 3 ;
	AgentHeight = 6 ;
	AgentCanJump = true ;
	AgentCanClimb = false ;
	Costs = {
		Water = 20
	};
}

local function FetchClientChar()
	local Char = Client.Character or Client.CharacterAdded:Wait()
	task.wait()
	return Char
end

return function ( self : { Distance : number } )
	assert(Run:IsClient(), EXCEPTION(1))
	
	local Character = FetchClientChar()
	local Cameraman = MCameraman.create()
	local CameramanPF = Pathfinder.new(Cameraman, CameramanConfig)

	local Primary = {
		OfUser = Character.Head ;
		OfCamera = Cameraman.Head ;
	}
	
	Cameraman.Humanoid.WalkSpeed *= 0.75
	
	-- Responsible for moving the cameraman
	local MovingConnection = Run.Stepped:Connect( function ()
		if self.IsWalking then return end
		if (Primary.OfUser.Position - Primary.OfCamera.Position).Magnitude < self.Distance then
			CameramanPF:Halt()
			return
		end
		CameramanPF:Compute(Character.PrimaryPart.Position)
		CameramanPF:Walk()
	end)

	-- Responsible for making the camera focus on the client
	local RenderConnection = Run.RenderStepped:Connect( function()
		Camera.CFrame = CFrame.lookAt(Primary.OfCamera.Position, Primary.OfUser.Position)
	end)

	-- For cases when the client resets / dies
	local CharConnection = Client:GetPropertyChangedSignal('Character'):Connect( function ()
		Character = Client.Character
		if not Character then return end
		Primary.OfUser = Character:WaitForChild('Head')
		Cameraman:PivotTo(CFrame.new(Character.PrimaryPart.Position + Vector3.new(4, 0, 4)))
	end)

	Cameraman.Destroying:Connect( function()
		MovingConnection:Disconnect()
		RenderConnection:Disconnect()
		CharConnection:Disconnect()
	end)
end