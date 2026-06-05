-- Red-Eyes Dark Flare Fusion
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	--[[
	[HOPT]
	Fusion Summon 1 DARK or FIRE Fusion Monster from your Extra Deck,
	using monsters from your hand and/or field as material, including a Normal Monster,
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except Fusion or Xyz Monsters.
	If Summoning a Fusion Monster that mentions "Red-Eyes Black Dragon" as material this way,
	you can also use 1 monster in your Deck as material.
	]]--
	--[[
	[HOPT]
	If this Set card in its owner's control is destroyed by an opponent's card effect and sent to the GY:
	You can Tribute 1 monster your opponent controls, and if you do, inflict 1200 damage to your opponent.
	]]--
	-- This card's name becomes "Red-Eyes Fusion" while in the GY.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetValue(CARD_RED_EYES_FUSION)
	c:RegisterEffect(e3)
end
local CARD_RED_EYES_FUSION = 6172122
-- Mentions : "Red-Eyes Black Dragon","Red-Eyes Fusion"
s.listed_names={CARD_REDEYES_B_DRAGON,CARD_RED_EYES_FUSION,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
