-- Red-Eyes Noxious Flame Dragon
local s,id,o=GetID()
-- c220000051
function s.initial_effect(c)
	-- 1 Level 7 "Red-Eyes" monster + 1 Level 7 WIND Dragon monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- If a monster you control attacks a Defense Position monster, inflict piercing battle damage to your opponent.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	c:RegisterEffect(e1)
	--[[
	[SOPT]
	Once per turn, when a monster you control destroys an opponent's monster by battle:
	You can inflict damage to your opponent equal to the destroyed monster's original ATK.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[SOPT]
	If this card is destroyed by battle or card effect:
	You can Special Summon both 1 "Red-Eyes Black Dragon" and 1 "Thousand Dragon" from your hand, Deck, Extra Deck, and/or GY.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Red-Eyes Black Dragon","Thousand Dragon"
s.listed_names={CARD_REDEYES_B_DRAGON,41462083,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WIND)
	and c:IsRace(RACE_DRAGON)
	and c:IsLevel(7)
end
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:Filter(Card.IsPreviousControler,nil,1-tp)

	if dg:GetCount()==0 or dg:GetCount()>1 then return false end
	
	local rc=dg:GetFirst():GetReasonCard()
	if rc:IsRelateToBattle() then
		return rc:IsControler(tp)
	else
		return rc:IsPreviousControler(tp)
	end
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=eg:Filter(Card.IsPreviousControler,nil,1-tp):GetFirst()
	
	if chk==0 then
		return dc
		and dc:GetBaseAttack()>0
	end
	
	local atk=dc:GetBaseAttack()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.e2evt(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)

	Duel.Damage(p,d,REASON_EFFECT)
end
function s.e3fil(c,e,tp)
	return c:IsCode(CARD_REDEYES_B_DRAGON,41462083)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3con(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,CARD_REDEYES_B_DRAGON)==1
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.e3fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)

	if chk==0 then
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.e3con,0)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA)
end
function s.e3evt(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end

	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e3fil),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.e3con,1,tp,HINTMSG_SPSUMMON)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
