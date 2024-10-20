
--[=[
	[INTERNAL] Responsible for moving a character, and managing
	the internal states of a moving character.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict

local PathfindingService = game:GetService("PathfindingService")

local Pathfinder = {}

export type Character = Model & { Humanoid : Humanoid }
export type PathConfig = {
	AgentRadius : number? ;
	AgentHeight : number? ;
	AgentCanJump : boolean? ;
	AgentCanClimb : boolean? ;
	WaypointSpacing : number? ;
	Costs : { [string] : number }? ;
}

export type Pathfinder = typeof(Pathfinder) & {
	Path : Path ;
	Character : Character ;
	Humanoid : Humanoid ;
	NextWaypointIndex : number? ;
	BlockedConnection : RBXScriptConnection? ;
	ReachedConnection : RBXScriptConnection? ;
	Waypoints : {}? ;
	IsWalking : boolean ;
}

function Pathfinder.new( Character : Character , PathConfig : PathConfig ) : Pathfinder
	local self = setmetatable({}, {__index = Pathfinder})
	self.Path = PathfindingService:CreatePath(PathConfig)
	self.Character = Character
	self.Humanoid = Character.Humanoid
	self.IsWalking = false
	return self
end

-- [ Computes a path to the destination given ]
function Pathfinder.Compute( self : Pathfinder , Destination : Vector3 )
	local Path, Character = self.Path, self.Character
	local Success, Result = pcall( function()
		Path:ComputeAsync(Character.PrimaryPart.Position, Destination)
	end)

	return Success, Result
end

-- [ Makes the character walk the computed path ]
function Pathfinder.Walk( self : Pathfinder )
	local Path, Humanoid = self.Path, self.Humanoid
	-- Get the path waypoints
	local Waypoints = Path:GetWaypoints()
	self.Waypoints = Waypoints
	-- If there is barely any waypoints then don't bother
	if #Waypoints < 3 then return end

	-- Detect when movement to next waypoint is complete
	if not self.ReachedConnection then
		self.ReachedConnection = Humanoid.MoveToFinished:Connect(function(Reached)
			if Reached and self.NextWaypointIndex < #Waypoints then
				-- Increase waypoint index and move to next waypoint
				self.NextWaypointIndex += 1
				local Waypoint = Waypoints[self.NextWaypointIndex] :: PathWaypoint
				if Waypoint.Action == Enum.PathWaypointAction.Jump then
					Humanoid.Jump = true
				end
				Humanoid:MoveTo(Waypoint.Position)
				
			else
				self.ReachedConnection:Disconnect()
				if self.BlockedConnection then
					self.BlockedConnection:Disconnect()
				end
				self.IsWalking = false
			end
		end)
	end

	-- Initially move to second waypoint (first waypoint is path start; skip it)
	self.NextWaypointIndex = 2
	Humanoid:MoveTo(Waypoints[self.NextWaypointIndex].Position)
	self.IsWalking = true
end

-- [ Halts all movement ]
function Pathfinder.Halt( self : Pathfinder )
	if self.ReachedConnection then
		self.ReachedConnection:Disconnect()
	end
	if self.BlockedConnection then
		self.BlockedConnection:Disconnect()
	end
	self.NextWaypointIndex = nil
	self.Waypoints = nil
end

function Pathfinder.WalkTo( self : Pathfinder , Destination : Vector3 )
	-- Compute the path
	local Success, Result = self:Compute(Destination)
	local Path = self.Path

	if Success and Path.Status == Enum.PathStatus.Success then
		-- Detect if path becomes blocked
		self.BlockedConnection = Path.Blocked:Connect(function(BlockedWaypointIndex)
			-- Check if the obstacle is further down the path
			if BlockedWaypointIndex >= self.NextWaypointIndex then
				-- Stop detecting path blockage until path is re-computed
				self.BlockedConnection:Disconnect()
				-- Call function to re-compute new path
				self:WalkTo(Destination)
			end
		end)
		
		self:Walk()
	else
		warn("Path not computed!", Result)
	end
end

return Pathfinder