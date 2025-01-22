-- Little-Winguard with Eyes of Red
local s,id,o=GetID()
-- c220000046
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 Level 1 Dragon monster in your GY;
	add it to your hand.
	]]--
	--[[
	[SOPT]
	Once per turn, when your opponent’s monster effect activated on the field resolves,
	while this card is equipped to a "Red-Eyes" monster,
	you can change the monster that activated that effect to face-down Defense Position.
	]]--
	--[[
	[SOPT]
	Once per turn, during the Battle Phase (Quick Effect):
	You can switch the ATK and DEF of 1 face-up monster your opponent controls until the end of this Battle Phase.
	]]--
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
