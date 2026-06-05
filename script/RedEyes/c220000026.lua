-- Soaring Hayabusa Knight
local s,id,o=GetID()
-- c220000026
function s.initial_effect(c)
	--[[
	A Fusion Monster that was Fusion Summoned using this card as material
	can attack twice during each Battle Phase.
	]]--
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can return a number of Spells/Traps your opponent controls to the hand
	equal to the number of monsters you control that mention "Dark Time Wizard".
	]]--
	--[[
	[HOPT]
	During damage calculation, when you are about to take battle damage from a battle involving 2 monsters:
	You can banish this card from your GY;
	gain LP equal to double the damage you would take first.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
