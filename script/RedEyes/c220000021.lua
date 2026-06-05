-- Megacyber with Eyes of Red
local s,id,o=GetID()
-- c220000021
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control no monsters, you can Special Summon this card (from your hand).
	]]--
	--[[
	[HOPT]
	If this card is Special Summoned, and your opponent controls more monsters than you do:
	You can Special Summon Level 7 or lower "Red-Eyes" monsters with different names from your hand or GY,
	up to the difference.
	You cannot Special Summon monsters from the Extra Deck the turn you activate this effect,
	except Fusion or Xyz Monsters.
	]]--
	--[[
	[HOPT]
	If this card is sent to the GY:
	You can target 1 "Red-Eyes" Gemini Monster you control;
	it is treated as an Effect Monster, and gains its effect(s).
	]]--
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
