-- Giltia the Assault Spear
local s,id,o=GetID()
-- c220000028
function s.initial_effect(c)
	--[[
	[HOPT]
	You can banish this card from your hand or field;
	add 1 monster that mentions “Dark Time Wizard” from your Deck or GY to your hand, except a Level 6 monster,
	then if this effect was activated on the field, you can add a second such card to your hand,
	also you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Fusion Monsters.
	]]--
	--[[
	[HOPT]
	If a face-up monster(s) that mentions “Dark Time Wizard” you control is destroyed by card effect,
	while this card is in your GY (except during the Damage Step):
	You can Special Summon this card.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
