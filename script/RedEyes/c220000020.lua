-- Red-Eyes Furious Six
local s,id,o=GetID()
-- c220000020
function s.initial_effect(c)
	-- 2 Level 6 DARK monsters
	c:EnableReviveLimit()
	--[[
	If this card is Xyz Summoned: You can roll a six-sided die.
	All face-up monsters your opponent currently controls lose ATK/DEF equal to the result x 300,
	until the end of this turn.
	]]--
	--[[
	[HOPT]
	You can detach 1 material from this card;
	Special Summon from your Extra Deck, 1 Rank 7 "Red-Eyes" Xyz Monster,
	by using this face-up card you control as material,
	but destroy it during your opponent's next End Phase.
	(This is treated as an Xyz Summon. Transfer its materials to the Summoned monster.)
	]]--
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
