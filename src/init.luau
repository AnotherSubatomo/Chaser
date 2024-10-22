
--[=[
	Chaser
		A module that attempts to recreate @Jam2go (YouTube)'s
	vision of what a second-person view would look like.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict

local Chaser = {}

Chaser.Enable = require(script.Enable)
Chaser.Disable = function()
	require(script.internal.Cameraman):Dismiss()
end

return Chaser