-- Harpie Lady the Red-Eyes Cyber Nightingale
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	--[[
	This card's name becomes "Harpie Lady" while on the field or in the GY,
	but is still treated as a "Red-Eyes" card.
	]]--
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can discard 1 card;
	place 1 "Return of the Red-Eyes" from your hand, Deck, or GY face-up in your Spell & Trap Zone,
	then if you discarded a Normal Monster to activate this effect,
	you can destroy all face-up Spells your opponent controls.
	]]--
	--[[
	[HOPT]
	You can target 1 Level 5 or higher "Harpie" or "Red-Eyes" monster you control;
	until the end of this turn, the Level of that monster or this card becomes the Level of the other,
	also you cannot declare an attack for the rest of this turn, except with DARK or WIND monsters.
	]]--
end
local CARD_RETURN_OF_THE_RED_EYES = 39387565
-- Mentions : "Harpie Lady","Return of the Red-Eyes"
s.listed_names={CARD_HARPIE_LADY,CARD_RETURN_OF_THE_RED_EYES,id}
-- Archetype : Harpie, Red-Eyes
s.listed_series={SET_HARPIE,SET_RED_EYES}
-- Helpers
