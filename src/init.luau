
--[=[
	Chaser
		A module that attempts to recreate @Jam2go (YouTube)'s
	vision of what a second-person view would look like.
	
	Author:			@AnotherSubatomo (GitHub)
	Last Committed:	22/10/2024 - 4:08 PM
]=]

--!native

local Chaser = {}

Chaser.Enable = require(script.Enable)
Chaser.Disable = function()
	require(script.internal.Cameraman):Dismiss()
end

return Chaser