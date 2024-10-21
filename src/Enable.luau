
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
local __Cameraman = require(internal.Cameraman)
local EXCEPTION = require(internal.Exception)

local CameramanConfig = {
	AgentRadius = 5 ;
	AgentHeight = 6 ;
	AgentCanJump = true ;
	AgentCanClimb = true ;
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
	local Cameraman = __Cameraman.employ()
	local CameramanPF = Pathfinder.new(Cameraman, CameramanConfig)

	-- # For easy referencing of the primary part of each rig
	local Primary = {
		OfUser = Character.Head ;
		OfCamera = Cameraman.Head ;
	}
	
	--Cameraman.Humanoid.WalkSpeed *= 0.75
	
	-- Responsible for moving the cameraman
	local MovingConnection = Run.Heartbeat:Connect( function ()
		CameramanPF:Compute(Primary.OfUser.Position - Camera.CFrame.LookVector.Unit * self.Distance)
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
		Cameraman:PivotTo( CFrame.new(
			Primary.OfUser.Position -
			Camera.CFrame.LookVector.Unit * self.Distance
		))
	end)

	__Cameraman.Dismissing:Connect( function()
		MovingConnection:Disconnect()
		RenderConnection:Disconnect()
		CharConnection:Disconnect()
		CameramanPF:Destroy()
	end)
	
	-- # DEBUGGING
	workspace:SetAttribute('IsDebuggingCameraman', false)
	workspace:GetAttributeChangedSignal('IsDebuggingCameraman'):Connect( function()
		print('detected')
		local IsDebugging = workspace:GetAttribute('IsDebuggingCameraman')
		Camera.CameraSubject = IsDebugging and FetchClientChar().Humanoid
		RenderConnection = IsDebugging and RenderConnection:Disconnect() or Run.RenderStepped:Connect( function()
			Camera.CFrame = CFrame.lookAt(Primary.OfCamera.Position, Primary.OfUser.Position)
		end)
	end)
end