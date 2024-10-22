
--[=[
	Chaser
		A module that attempts to recreate @Jam2go (YouTube)'s
	vision of what a second-person view would look like.
	
	Author:			@AnotherSubatomo (GitHub)
	Version:		0.1.0
	Last Committed:	22/10/2024 - 11:34 PM
]=]

--!native

local Run = game:GetService('RunService')
local Camera = workspace.CurrentCamera

local Pathfinder = require(script.Pathfinder)
local Cameraman = require(script.Cameraman)

export type Character = Cameraman.Character
export type ChaserConfig = {
	Subject : Player? ;
	Distance : number? ;
	WalkSpeedRatio : number? ;
}

local function raise( msg : string )
	return '@Chaser: '..msg
end

local CAM_CONFIG = {
	AgentRadius = 5 ;
	AgentHeight = 6 ;
	AgentCanJump = true ;
	AgentCanClimb = true ;
	Costs = {
		Water = 20
	};
}

local Chaser = {}

function Chaser.enable()
	assert(Run:IsClient(), raise("Function can only be ran on the client side."))
	
	local Subject = Cameraman:GetSubjectChar()
	local Operator = Cameraman:Employ()
	CAM_CONFIG.AgentHeight = Operator:GetExtentsSize().Y

	local CameramanPF = Pathfinder.new(Operator, CAM_CONFIG)

	-- For easy referencing of the primary part of each rig
	local Primary = {
		OfUser = Subject.Head :: BasePart ;
		OfCamera = Operator.Head :: BasePart ;
	}
	
	-- Responsible for moving the Operator
	local MovingConnection = Run.Heartbeat:Connect( function ()
		if (Primary.OfUser.Position - Primary.OfCamera.Position).Magnitude > 30 then
			Cameraman:Snap()
		end
		CameramanPF:WalkTo(Primary.OfUser.Position - Camera.CFrame.LookVector.Unit * Cameraman.Distance)
	end)

	local DismissingConnection : RBXScriptConnection = nil
	DismissingConnection = Cameraman.Dismissing:Connect( function()
		MovingConnection:Disconnect()
		DismissingConnection:Disconnect()
		CameramanPF:Destroy()
	end)
end

function Chaser.disable()
	Cameraman:Dismiss()
end

function Chaser.set( Config : ChaserConfig )
	for Property : string, Value : any in Config do
		local OldValue = Cameraman[Property]
		assert( typeof(OldValue) ~= "Instance" or typeof(OldValue) ~= "function",
				raise("Tried to set a non-existent config property's value."))
		Cameraman[Property] = Value
	end
	Chaser.disable()
	Chaser.enable()
end

return Chaser