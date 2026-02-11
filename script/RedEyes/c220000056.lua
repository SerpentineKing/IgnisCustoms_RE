-- Red-Eyes Zombie Miasma Dragon
local s,id,o=GetID()
-- c220000056
function s.initial_effect(c)
	--[[
	If this card on the field would be used as Synchro Material,
	1 Tuner that mentions "Zombie World" in your hand can be used as 1 of the other materials.
	]]--
	Synchro.AddHandMaterialEffect(c,id,s.e1fil)
	--[[
	[HOPT]
	During your opponent's Main Phase, you can (Quick Effect):
	Immediately after this effect resolves, Synchro Summon 1 Zombie Synchro Monster,
	using materials including this card you control.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	When your opponent activates a monster effect on the field or in the GY (Quick Effect):
	You can Special Summon this card from your hand or GY (but banish it when it leaves the field),
	then if you activated this effect in response to a Dragon or Zombie monster's effect, you can inflict 1200 damage to your opponent.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
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
function s.e1fil(c)
	return (c:IsSetCard(0xfe3)
		or c:IsCode(4064256)
		or c:IsCode(32485518)
		or c:IsCode(92964816)
		or c:IsCode(66570171))
	and c:IsType(TYPE_TUNER)
	and c:IsMonster()
end
function s.e2con(e,tp)
	return Duel.IsTurnPlayer(1-tp)
	and Duel.IsMainPhase()
end
function s.e2fil(c)
	return c:IsSynchroSummonable(nil)
	and c:IsRace(RACE_ZOMBIE)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_EXTRA,0,1,nil)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end

	local g=Duel.GetMatchingGroup(s.e2fil,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local trig_typ,trig_race=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_RACE)

	e:SetLabel((trig_typ&TYPE_MONSTER>0 and trig_race&(RACE_DRAGON+RACE_ZOMBIE)>0) and 1 or 0)

	return rp==1-tp
	and re:IsMonsterEffect()
	and trig_loc&(LOCATION_MZONE+LOCATION_GRAVE)>0
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)

	local dmg = 600
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dmg)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e3b=Effect.CreateEffect(c)
		e3b:SetDescription(3300)
		e3b:SetType(EFFECT_TYPE_SINGLE)
		e3b:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3b:SetValue(LOCATION_REMOVED)
		e3b:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e3b,true)

		Duel.BreakEffect()

		if e:GetLabel()==1 and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Damage(p,d,REASON_EFFECT)
		end
	end
end
