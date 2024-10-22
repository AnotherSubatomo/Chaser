
--[=[
	An example client script for using Chaser.
	Last Committed:	22/10/2024 - 11:34 PM
]=]

--!native
--!nonstrict

local Chaser = require(game.ReplicatedStorage.Chaser)
local Client = game.Players.LocalPlayer

type Props = {[string] : any}
local function New( ClassName : string , Props : Props? )
	local Obj = Instance.new(ClassName)
	for Prop : string, Value : any in (Props or {}) :: Props do
		if Prop == 'Children' then
			for _ , Child : Instance in Value do Child.Parent = Obj end
		continue end
		Obj[Prop] = Value
	end
	return Obj
end

local Padding = UDim.new(0, 4)

local function GenericButton( Text : string , Position : UDim2 )
	return New('TextButton', {
		BackgroundColor3 = Color3.new(1, 1, 1) ;
		FontFace = Font.fromName('RobotoMono', Enum.FontWeight.Medium) ;
		TextXAlignment = 'Center' ;
		TextYAlignment = 'Center' ;
		Position = Position ;
		Size = UDim2.new(0, 0) ;
		AutomaticSize = 'XY' ;
		Text = Text ;
		Name = Text ;
		['Children'] = {
			New('UIPadding', {
				PaddingTop = Padding ;
				PaddingBottom = Padding ;
				PaddingLeft = Padding ;
				PaddingRight = Padding ;
			}) ;
			New('UICorner') ;
		}
	})
end

local Cinematic = GenericButton('Cinematic', UDim2.new(0, 10, 1, -70)) :: TextButton
local Enable = GenericButton('Enable', UDim2.new(0, 10, 1, -50)) :: TextButton
local Disable = GenericButton('Disable', UDim2.new(0, 10, 1, -30)) :: TextButton

local function MakeBlocker()
	return New('Frame', {
		BackgroundColor3 = Color3.new() ;
		Size =UDim2.fromScale(1, 1) ;
	})
end

local CinematicFrame = New('CanvasGroup', {
	Name = 'CinematicFrame' ;
	Size = UDim2.fromScale(1, 1) ;
	BackgroundTransparency = 1 ;
	BorderSizePixel = 0 ;
	Visible = false ;

	['Children'] = {
		New('UIListLayout', {
			FillDirection = 'Vertical' ;
			SortOrder = 'LayoutOrder' ;
			HorizontalAlignment = 'Center' ;
			VerticalAlignment = 'Center' ;
		}) ;
		MakeBlocker();
		New('Frame', {
			Size = UDim2.fromScale(1, 1) ;
			BackgroundTransparency = 1 ;
			BorderSizePixel = 0 ;

			['Children'] = {
				New('UIAspectRatioConstraint', { AspectRatio = 12 / 5 })
			}
		});
		MakeBlocker();
	}
}) :: CanvasGroup

local UI = New('ScreenGui', {
	Name = 'Chaser@demo-ui' ;
	Parent = Client.PlayerGui ;
	ResetOnSpawn = false ;
	IgnoreGuiInset = true ;
	['Children'] = {
		CinematicFrame ;
		Cinematic ;
		Enable ;
		Disable ;
	}
}) :: ScreenGui

Cinematic.Activated:Connect( function()
	CinematicFrame.Visible = not CinematicFrame.Visible
end)

Enable.Activated:Connect( function()
	Chaser.enable()
end)


Disable.Activated:Connect( function()
	Chaser.disable()
end)