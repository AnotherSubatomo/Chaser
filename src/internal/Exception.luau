
--[=[
	[INTERNAL] Responsible for dictating how exceptions are expressed.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict

local EXCEPTIONS = {
	"Function can only be ran on the client side." ;
}

local function ExpressException( ID : number , From : string? ) : string
	return `@SECOND{From and '-'..From or ''}: {EXCEPTIONS[ID]}`
end

return ExpressException