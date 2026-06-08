-- Primordial Dark Sage
local s,id,o=GetID()
-- c220000033
function s.initial_effect(c)
	-- "Dark Magician" + 1 monster that mentions "Dark Time Wizard"
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	--[[
	Must be either Fusion Summoned, or Special Summoned (from your Extra Deck)
	by Tributing 1 Level 5 or higher monster from your hand or face-up field
	during the turn you called a coin toss correctly.
	You can only Special Summon "Primordial Dark Sage" once per turn this way, no matter which method you use.
	]]--
	--[[
	During your opponent's turn,
	you can activate Quick-Play Spells that mention "Dark Time Wizard" from your hand.
	]]--
	--[[
	[HOPT]
	If this card is Special Summoned:
	You can activate this effect; during the End Phase of this turn, add 1 Spell Card from your Deck to your hand,
	then place 1 card from your hand on the top of the Deck.
	]]--
end
-- Mentions : "Dark Magician","Dark Time Wizard"
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(CARD_DARK_MAGICIAN)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD)
end
