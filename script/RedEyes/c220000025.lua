-- Legendary Gambler of Landstar
local s,id,o=GetID()
-- c220000025
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned, or if this card is Tributed:
	You can activate this effect;
	for the rest of this turn, apply the following effects.
	•
	Once, during this turn, if you activate a card or effect that requires a die roll,
	you can choose 1 die result and treat it as a number between 1 and 6 (inclusive).
	•
	Once, during this turn, if you activate a card or effect that requires a coin toss,
	you can choose 1 result and treat it as either heads or tails.
	]]--
	--[[
	[HOPT]
	When an attack is declared involving this card:
	You can target 1 Quick-Play Spell or Normal Trap in your GY or banishment that mentions "Dark Time Wizard";
	shuffle that target into the Deck,
	and if you do, apply that target's activation effect.
	]]--
end
-- Mentions : "Dark Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,id}
-- Helpers
