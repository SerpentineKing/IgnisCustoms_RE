-- Red-Eyes Potential
local s,id,o=GetID()
-- c220000030
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[
	[HOPT]
	During your Main Phase: Apply these effects in sequence, based on the number of “Red-Eyes” monsters on the field and in the GYs.
	• 1+:
	Add 1 Level 7 or lower “Red-Eyes” monster from your Deck or GY to your hand,
	also, once this turn, if you Normal or Special Summon a “Red-Eyes” monster(s), you can draw 1 card.
	• 2+:
	You can select 1 “Red-Eyes” monster you control,
	this turn, your opponent cannot activate cards or effects when that monster declares an attack.
	• 3+:
	You can select 1 “Red-Eyes” monster you control,
	Special Summon 1 “Red-Eyes” monster from your hand, Deck, or GY whose Level is less than or equal to that monster's Level,
	but negate its effects until the end of this turn.
	• 4+:
	You can Special Summon 1 “Red-Eyes” monster from your hand, Deck, or GY, ignoring its Summoning conditions.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e1con(e,tp)
	return Duel.GetMatchingGroupCount(s.e1fil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)>0
end
function s.e1fil1(c)
	return c:IsLevelBelow(7)
	and c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(s.e1fil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		if ct<=1 then
			return Duel.IsExistingMatchingCard(s.e1fil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		end
		return true
	end
end
function s.e1fil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e1fil3(c,e,tp,lv)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:GetLevel()<=lv
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e1fil4(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.e1fil,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local c=e:GetHandler()

	local ct=g:GetCount()
	if ct>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)

		local g=Duel.SelectMatchingCard(tp,s.e1fil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end

		local e1ct1=Effect.CreateEffect(c)
		e1ct1:SetCategory(CATEGORY_DRAW)
		e1ct1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1ct1:SetCode(EVENT_SUMMON_SUCCESS)
		e1ct1:SetRange(LOCATION_SZONE)
		e1ct1:SetProperty(EFFECT_FLAG_DELAY)
		e1ct1:SetCountLimit(1,{id,1})
		e1ct1:SetCondition(s.e1ct1con)
		e1ct1:SetTarget(s.e1ct1tgt)
		e1ct1:SetOperation(s.e1ct1evt)
		e1ct1:SetReset(RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1ct1)

		local e1ct1b=e1ct1:Clone()
		e1ct1b:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e1ct1b)
	end
	if ct>=2 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then
		local g=Duel.SelectMatchingCard(tp,s.e1fil2,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()

			local e1ct2=Effect.CreateEffect(c)
			e1ct2:SetType(EFFECT_TYPE_FIELD)
			e1ct2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1ct2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1ct2:SetTargetRange(0,1)
			e1ct2:SetCondition(function(e)
				return Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE)
				and Duel.GetAttacker()==tc
			end)
			e1ct2:SetValue(1)
			e1ct2:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1ct2,tp)
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if ct>=3 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,3)) then
		local g=Duel.SelectMatchingCard(tp,s.e1fil2,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			local lv=tc:GetLevel()

			if Duel.IsExistingMatchingCard(s.e1fil3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,lv) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

				local g2=Duel.SelectMatchingCard(tp,s.e1fil3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
				if g2:GetCount()>0 then
					local sc=g2:GetFirst()
					if Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
						local e1ct3b=Effect.CreateEffect(c)
						e1ct3b:SetType(EFFECT_TYPE_SINGLE)
						e1ct3b:SetCode(EFFECT_DISABLE)
						e1ct3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
						e1ct3b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
						sc:RegisterEffect(e1ct3b)

						local e1ct3c=e1ct3b:Clone()
						e1ct3c:SetCode(EFFECT_DISABLE_EFFECT)
						e1ct3c:SetValue(RESET_TURN_SET)
						sc:RegisterEffect(e1ct3c)
					end
					Duel.SpecialSummonComplete()
				end
			end
		end
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if ct>=4 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

		local g=Duel.SelectMatchingCard(tp,s.e1fil4,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function s.e1ct1fil(c,tp)
	return c:IsFaceup()
	and c:IsSetCard(SET_RED_EYES)
	and c:IsSummonPlayer(tp)
end
function s.e1ct1con(e,tp)
	return eg:IsExists(s.e1ct1fil,1,nil,tp)
end
function s.e1ct1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e1ct1evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
