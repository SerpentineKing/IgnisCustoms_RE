-- Shield & Flame Swordsman
local s,id,o=GetID()
-- c220000027
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
	If card is in your hand:
	You can target 1 face-up monster your opponent controls;
	switch the original ATK and DEF of that monster until the end of this turn,
	then immediately after this effect resolves, Normal Summon this card without Tributing.
	]]--
	--[[
	[HOPT]
	During the Main Phase (Quick Effect):
	You can Fusion Summon 1 Fusion Monster that mentions "Dark Time Wizard" or "Flame Swordsman"
	from your Extra Deck, using monsters from your hand and/or field as material, including this card.
	]]--
end
-- Mentions : "Flame Swordsman","Dark Time Wizard"
s.listed_names={CARD_FLAME_SWORDSMAN,CARD_DARK_TIME_WIZARD,id}
-- Helpers
