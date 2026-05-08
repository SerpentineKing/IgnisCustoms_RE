-- Red-Eyes Arsenal Dragon
local s,id,o=GetID()
-- c220000061
function s.initial_effect(c)
	--[[
	1 "Red-Eyes" monster equipped with a Monster Card + 1 Effect Monster Card
	Must first be Special Summoned (from your Extra Deck) by sending the above cards from your hand and/or face-up field to the GY.
	]]--
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	Fusion.AddContactProc(c,s.fs1fil,s.fs2fil,s.fslim)
	--[[
	[H1PT]
	If this card is Special Summoned from the Extra Deck:
	You can add 1 "The Claw of Hermos" or 1 Spell/Trap that mentions it from your Deck or GY to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	(Quick Effect):
	You can target 1 face-up monster on the field;
	equip this card to it as an Equip Spell with the following effect.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local RESETS_ON_LEAVE = RESET_EVENT+RESETS_STANDARD
local CARD_THE_CLAW_OF_HERMOS = 46232525
-- Mentions : "The Claw of Hermos"
s.listed_names={CARD_THE_CLAW_OF_HERMOS,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.m1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:GetEquipGroup():IsExists(Card.IsMonsterCard,1,nil)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsType(TYPE_EFFECT)
	and c:IsMonsterCard()
end
function s.fs1fil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
end
function s.fs2fil(g)
	return Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.fslim(e,se,sp,st)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_EXTRA)
end
function s.e1con(e)
	local c=e:GetHandler()
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.e1fil(c)
	return (c:IsCode(CARD_THE_CLAW_OF_HERMOS)
	or (c:ListsCode(CARD_THE_CLAW_OF_HERMOS) and c:IsSpellTrap()))
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e1evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

	local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.e2fil(c)
	return c:IsFaceup()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and s.e2fil(chkc)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	
	Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)

	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.Equip(tp,c,tc) then
		-- [Equip Limit]
		local e2b0=Effect.CreateEffect(c)
		e2b0:SetType(EFFECT_TYPE_SINGLE)
		e2b0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2b0:SetCode(EFFECT_EQUIP_LIMIT)
		e2b0:SetValue(s.eqlim)
		e2b0:SetLabelObject(tc)
		e2b0:SetReset(RESETS_ON_LEAVE)
		c:RegisterEffect(e2b0)
		-- The equipped monster cannot be destroyed by card effects, except during the Battle Phase.
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetType(EFFECT_TYPE_EQUIP)
		e2b1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2b1:SetCondition(s.e2b1con)
		e2b1:SetValue(1)
		e2b1:SetReset(RESETS_ON_LEAVE)
		c:RegisterEffect(e2b1)
	end
end
function s.eqlim(e,c)
	return c==e:GetLabelObject()
end
function s.e2b1con(c)
	return not Duel.IsBattlePhase()
end
