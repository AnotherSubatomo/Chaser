
--[=[
	[INTERNAL] Responsible for moving a character, and managing
	the internal states of a moving character.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	22/10/2024 - 4:08 PM
]=]

--!native

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
	Waypoints : {PathWaypoint}? ;
	NextWaypointIndex : number? ;
	BlockedConnection : RBXScriptConnection? ;
	ReachedConnection : RBXScriptConnection? ;
	-- # The minimum acceptable distance between waypoints
	MinDistance : number ;
	__PreviousWaypoint : PathWaypoint?
}

local function Distance( a : Vector3 , b : Vector3 ) : number
	return(a - b).Magnitude
end

function Pathfinder.new(
	Character : Character ,
	PathConfig : PathConfig ,
	MinDistance : number?
) : Pathfinder
	local self = setmetatable({}, {__index = Pathfinder})
	self.Path = PathfindingService:CreatePath(PathConfig)
	self.Character = Character
	self.Humanoid = Character.Humanoid
	self.MinDistance = MinDistance or 2
	return self
end

function Pathfinder.__ReachedDisconnect( self : Pathfinder )
	if self.ReachedConnection == nil then return end
	self.ReachedConnection:Disconnect()
	self.ReachedConnection = nil
end

function Pathfinder.__BlockedDisconnect( self : Pathfinder )
	if self.BlockedConnection == nil then return end
	self.BlockedConnection:Disconnect()
	self.BlockedConnection = nil
end

-- [ Computes a path to the destination given ]
function Pathfinder.Compute( self : Pathfinder , Destination : Vector3 )
	local Path, Character = self.Path, self.Character
	local Success, Result = pcall( function()
		Path:ComputeAsync(Character.PrimaryPart.Position, Destination)
	end)
	return Success, Result
end

function Pathfinder.Jump( self : Pathfinder )
	local State = self.Humanoid:GetState()
	if State ~= Enum.HumanoidStateType.Jumping and State ~= Enum.HumanoidStateType.Freefall then
		self.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end

-- [ Fullfills a waypoint; assuming there is a waypoint bucket and a waypoint index ]
function Pathfinder.FullfillWaypoint( self : Pathfinder )
	local Humanoid, PrevWaypoint = self.Humanoid, self.__PreviousWaypoint
	local Waypoint = self.Waypoints[self.NextWaypointIndex]
	if not Waypoint then return end
	-- # Skip waypoints that are too close to the previous
	if PrevWaypoint and Distance(PrevWaypoint.Position, Waypoint.Position) < self.MinDistance then
		self.NextWaypointIndex += 1
		Waypoint = self.Waypoints[self.NextWaypointIndex]
	end
	if Waypoint.Action == Enum.PathWaypointAction.Jump then
		self:Jump()
	end
	Humanoid:MoveTo(Waypoint.Position)
	self.__PreviousWaypoint = Waypoint
	-- Increase waypoint index to move to next waypoint
	self.NextWaypointIndex += 1
end

-- [ Makes the character walk; assuming there is a computed path ]
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
				self:FullfillWaypoint()
			else
				self:__ReachedDisconnect()
				self:__BlockedDisconnect()
			end
		end)
	end

	-- Initially move to second waypoint (first waypoint is path start; skip it)
	self.NextWaypointIndex = 2
	self:FullfillWaypoint()
end

-- [ Halts all movement ]
function Pathfinder.Halt( self : Pathfinder )
	self:__ReachedDisconnect()
	self:__BlockedDisconnect()
	self.NextWaypointIndex = nil
	self.Waypoints = nil
end

function Pathfinder.WalkTo( self : Pathfinder , Destination : Vector3 )
	-- Compute the path
	local Success = self:Compute(Destination)
	local Path = self.Path

	--Stop execution if pathfinder is destroyed
	if not Path then return end

	if Success and Path.Status == Enum.PathStatus.Success then
		self.BlockedConnection = Path.Blocked:Connect(function( ... : number )
			-- Check if the obstacle is further down the path
			if  self.NextWaypointIndex <= ... and self.NextWaypointIndex + 1 >= ... then
				-- Stop detecting path blockage until path is re-computed
				self:__BlockedDisconnect()
				self:WalkTo(Destination)
			end
		end)
		
		self:Walk()
	else
		-- # Panic mode
		self:Jump()
		self.Humanoid:MoveTo(Destination)
	end
end

function Pathfinder.Destroy( self : Pathfinder )
	self.Path:Destroy()
	setmetatable(self, nil)
	if self.ReachedConnection ~= nil then
		self.ReachedConnection:Disconnect()
	end
	table.clear(self)
end

return Pathfinder