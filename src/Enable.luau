
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

local CameramanConfig = {
	AgentRadius = 5 ;
	AgentHeight = 6 ;
	AgentCanJump = true ;
	AgentCanClimb = true ;
	Costs = {
		Water = 20
	};
}

local function GetCharacter()
	repeat task.wait() until Client.Character ~= nil
	return Client.Character
end

local function raise( msg : string )
	return '@Chaser: '..msg
end

return function ()
	assert(Run:IsClient(), raise("Function can only be ran on the client side."))
	
	local Character = GetCharacter()
	local Cameraman = __Cameraman:Employ()
	if Cameraman == nil then return end
	CameramanConfig.AgentHeight = Cameraman:GetExtentsSize().Y

	local CameramanPF = Pathfinder.new(Cameraman, CameramanConfig)

	-- # For easy referencing of the primary part of each rig
	local Primary = {
		OfUser = Character.Head :: BasePart ;
		OfCamera = Cameraman.Head :: BasePart ;
	}
	
	-- Responsible for moving the cameraman
	local MovingConnection = Run.Heartbeat:Connect( function ()
		if (Primary.OfUser.Position - Primary.OfCamera.Position).Magnitude > 30 then
			__Cameraman:Snap()
		end
		CameramanPF:WalkTo(Primary.OfUser.Position - Camera.CFrame.LookVector.Unit * __Cameraman.Distance)
	end)

	__Cameraman.Dismissing:Connect( function()
		MovingConnection:Disconnect()
		CameramanPF:Destroy()
	end)
end