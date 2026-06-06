-- Voracious Insect Queen
local s,id,o=GetID()
-- c220000029
function s.initial_effect(c)
	-- Gains 400 ATK for all other Insect monsters and monsters that mentions "Dark Time Wizard" on the field.
	--[[
	[SOPT]
	Once per turn, when this card destroys an opponent's monster by battle:
	You can Special Summon 1 "Insect Monster Token" (Insect/EARTH/Level 1/ATK 100/DEF 100) to either field.
	While that Token is in the Monster Zone,
	all monsters on its controller's field become Insects, and they cannot be Tributed for a Tribute Summon.
	]]--
	--[[
	[HOPT]
	When your opponent activates a card or effect
	that targets a card(s) in your field or GY that mentions "Dark Time Wizard" (Quick Effect):
	You can Tribute 1 other monster;
	negate the activation, and if you do, destroy that card.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
