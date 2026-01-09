-- Red-Eyes Zombie Halberd Tiger
local s,id,o=GetID()
-- c220000054
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 Defense Position monster your opponent controls;
	change it to face-up Attack Position,
	or if this card was Special Summoned by the effect of a Synchro Monster, you can return that target to the hand instead.
	]]--
	local e1a1=Effect.CreateEffect(c)
	e1a1:SetDescription(aux.Stringid(id,1))
	e1a1:SetCategory(CATEGORY_POSITION+CATEGORY_TOHAND)
	e1a1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a1:SetCode(EVENT_SUMMON_SUCCESS)
	e1a1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1a1:SetCountLimit(1,{id,0})
	e1a1:SetTarget(s.e1tgt)
	e1a1:SetOperation(s.e1evt)
	c:RegisterEffect(e1a1)
	
	local e1a2=e1a1:Clone()
	e1a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1a2)
	--[[
	[HOPT]
	You can banish this card from your GY;
	Special Summon 1 Level 7 or 8 DARK monster (Dragon or Zombie) from your hand,
	or if "Zombie World" is in a Field Zone, you can Special Summon it from either GY instead.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Mentions : "Zombie World"
s.listed_names={4064256,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c,alt_chk)
	local alt_res = true
	if alt_chk then
		alt_res = c:IsAbleToHand()
	end

	return c:IsDefensePos()
	and alt_res
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local alt_chk=re and c:IsSpecialSummoned() and re:IsMonsterEffect() and re:GetHandler():IsOriginalType(TYPE_SYNCHRO)
	
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
		and s.e1fil(chkc,alt_chk)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e1fil,tp,0,LOCATION_MZONE,1,nil,alt_chk)
	end

	e:SetLabel(alt_chk and 1 or 0)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)

	local g=Duel.SelectTarget(tp,s.e1fil,tp,0,LOCATION_MZONE,1,1,nil,alt_chk)

	if alt_chk then
		Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	end
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local alt_chk=e:GetLabel()==1

	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local b1=tc:IsDefensePos()
		local b2=alt_chk and tc:IsAbleToHand()

		if not (b1 or b2) then return end
		
		local op=1
		if b1 and b2 then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,0)},
				{b2,aux.Stringid(id,1)})
		elseif (not b1) and b2 then
			op=2
		end

		if op==1 then
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		elseif op==2 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function s.e2fil1(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK)
	and (c:IsLevel(7) or c:IsLevel(8))
	and c:IsMonster()
	and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_ZOMBIE))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2fil2(c)
	return c:IsCode(4064256)
	and c:IsFaceup()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local alt_chk = Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)

	if chk==0 then
		local alt_res = Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_HAND,0,1,nil,e,tp)
		if alt_chk then
			alt_res = Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_HAND+LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
		end

		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and alt_res
	end

	if alt_chk then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local alt_chk = Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local b1 = Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2 = Duel.IsExistingMatchingCard(s.e2fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) and alt_chk

	if not (b1 or b2) then return end

	local op=1
	if b1 and b2 then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	elseif (not b1) and b2 then
		op=2
	end
	
	local g=nil
	if op==1 then
		g=Duel.SelectMatchingCard(tp,s.e2fil1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	elseif op==2 then
		g=Duel.SelectMatchingCard(tp,s.e2fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	end

	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
