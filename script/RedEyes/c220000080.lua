-- Shield & Flame Swordsman
local s,id,o=GetID()
-- c220000080
function s.initial_effect(c)
	-- This card's name becomes "Flame Swordsman" while on the field or in the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(CARD_FLAME_SWORDSMAN)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If "Dark Time Wizard", "Flame Swordsman", or a card that mentions either of those cards
	is in your field or GY, and this card is in your hand:
	Immediately after this effect resolves, you can Normal Summon this card without Tributing.
	]]--
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 monster that mentions either "Dark Time Wizard" or "Flame Swordsman" from your Deck to your hand,
	then you can switch the original ATK and DEF of 1 face-up monster your opponent controls
	until the end of this turn.
	]]--
end
-- Mentions : "Flame Swordsman","Dark Time Wizard"
s.listed_names={CARD_FLAME_SWORDSMAN,CARD_DARK_TIME_WIZARD,id}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsCode(CARD_FLAME_SWORDSMAN)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:ListsCode(CARD_DARK_TIME_WIZARD)
end
