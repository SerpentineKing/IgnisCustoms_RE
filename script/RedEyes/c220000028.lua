-- Time Magic Fusion
local s,id,o=GetID()
-- c220000028
function s.initial_effect(c)
	-- This card's name becomes "Dark Time Wizard" while in the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(CARD_DARK_TIME_WIZARD)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	Set 1 Trap that mentions "Dark Time Wizard" from your hand or Deck. It can be activated this turn.
	]]--
	--[[
	[HOPT]
	Fusion Summon 1 Fusion Monster that mentions either "Dark Time Wizard" or "Time Wizard" from your Extra Deck,
	by Tributing monsters from either field as material.
	If a monster(s) you controlled was destroyed by your monster or Spell effect this turn,
	you can also shuffle monsters from your GY into the Deck as material.
	]]--
end
local CARD_TIME_WIZARD = 71625222
-- Mentions : "Dark Time Wizard","Time Wizard"
s.listed_names={CARD_DARK_TIME_WIZARD,CARD_TIME_WIZARD,id}
-- Helpers
