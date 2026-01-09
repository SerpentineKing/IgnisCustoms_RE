-- Red-Eyes Zombie Battle-Scarred Warrior
local s,id,o=GetID()
-- c220000053
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control no monsters, or your opponent controls a Zombie monster:
	You can Special Summon this card from your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can target 1 face-up monster your opponent controls;
	change its ATK to 0,
	also if this card was Special Summoned by the effect of a Synchro Monster, negate that target's effects (if any).
	]]--
	local e2a1=Effect.CreateEffect(c)
	e2a1:SetDescription(aux.Stringid(id,1))
	e2a1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2a1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a1:SetCode(EVENT_SUMMON_SUCCESS)
	e2a1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2a1:SetCountLimit(1,{id,1})
	e2a1:SetTarget(s.e2tgt)
	e2a1:SetOperation(s.e2evt)
	c:RegisterEffect(e2a1)
	
	local e2a2=e2a1:Clone()
	e2a2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2a2)
	--[[
	[HOPT]
	If this card is sent from the Monster Zone to the GY:
	You can send 1 monster that mentions "Zombie World" or 1 Level 4 or lower Dragon monster from your Deck to the GY,
	except "Red-Eyes Zombie Battle-Scarred Warrior".
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Zombie World"
s.listed_names={4064256,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_ZOMBIE),tp,0,LOCATION_MZONE,1,nil)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e2fil(c,alt_chk)
	local alt_res = true
	if alt_chk then
		alt_res = not c:IsDisabled()
	end

	return c:IsFaceup()
	and not c:IsAttack(0)
	and alt_res
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local alt_chk=re and c:IsSpecialSummoned() and re:IsMonsterEffect() and re:GetHandler():IsOriginalType(TYPE_SYNCHRO)

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsControler(1-tp)
		and s.e2fil(chkc,alt_chk)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil,tp,0,LOCATION_MZONE,1,nil,alt_chk)
	end

	e:SetLabel(alt_chk and 1 or 0)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.e2fil,tp,0,LOCATION_MZONE,1,1,nil,alt_chk)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local alt_chk=e:GetLabel()==1

	local tc=Duel.GetFirstTarget()

	if tc and tc:IsRelateToEffect(e) and s.e2fil(tc,alt_chk) then
		local e2b1=Effect.CreateEffect(c)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2b1:SetValue(0)
		e2b1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2b1)

		if alt_chk then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			
			local e2b2=Effect.CreateEffect(c)
			e2b2:SetType(EFFECT_TYPE_SINGLE)
			e2b2:SetCode(EFFECT_DISABLE)
			e2b2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2b2)

			local e2b3=e2b2:Clone()
			e2b3:SetCode(EFFECT_DISABLE_EFFECT)
			e2b3:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2b3)
		
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e2b4=e2b2:Clone()
				e2b4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				tc:RegisterEffect(e2b4)
			end
		end
	end
end
function s.e3con(e,tp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
function s.e3fil(c)
	return not c:IsCode(id)
	and ((c:IsSetCard(0xfe3)
		or c:IsCode(4064256)
		or c:IsCode(32485518)
		or c:IsCode(92964816)
		or c:IsCode(66570171))
		or (c:IsRace(RACE_DRAGON) and c:IsLevelBelow(4)))
	and c:IsMonster()
	and c:IsAbleToGrave()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_DECK,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_DECK,0,1,1,nil)

	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
