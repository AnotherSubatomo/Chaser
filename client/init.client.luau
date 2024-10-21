
--[=[
	An example client script for using Chaser.
	Last Committed:	19/10/2024 - 2:13 PM
]=]

--!native
--!strict

local Chaser = require(game.ReplicatedStorage.Chaser)
local Client = game.Players.LocalPlayer

local function New( ClassName : string , Props : {[string] : any} )
	local Obj = Instance.new(ClassName)
	for Prop : string, Value : any in Props do
		if Prop == 'Children' then
			for _ , Child : Instance in Value do Child.Parent = Obj end
		continue end
		Obj[Prop] = Value
	end
	return Obj
end

local Enable = New('TextButton', {
	TextXAlignment = 'Center' ;
	TextYAlignment = 'Center' ;
	Position = UDim2.new(0, 10, 1, -40) ;
	Size = UDim2.new(0, 0) ;
	AutomaticSize = 'XY' ;
	Text = 'Enable' ;
}) :: TextButton

local Disable = New('TextButton', {
	TextXAlignment = 'Center' ;
	TextYAlignment = 'Center' ;
	Position = UDim2.new(0, 10, 1, -20) ;
	Size = UDim2.new(0, 0) ;
	AutomaticSize = 'XY' ;
	Text = 'Disable' ;
}) :: TextButton

local UI = New('ScreenGui', {
	Parent = Client.PlayerGui ;
	ResetOnSpawn = false ;
	IgnoreGuiInset = true ;
	['Children'] = {
		Enable ;
		Disable ;
	}
}) :: ScreenGui

Enable.Activated:Connect( function()
	Chaser:Enable()
end)


Disable.Activated:Connect( function()
	Chaser:Disable()
end)