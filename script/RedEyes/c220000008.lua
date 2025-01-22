-- Old Swordmaster of the Flame
local s,id,o=GetID()
-- c220000008
function s.initial_effect(c)
	-- 1 "Flame Swordsman" monster + 1 Spellcaster monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	--[[
	While this card is equipped an Equip Card, this card gains the following effects.
	•
	This card is unaffected by your opponent's Spell/Trap effects during the Battle Phase.
	•
	If this card battles a monster, that monster's ATK becomes 0 during the Damage Step only.
	]]--
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_IMMUNE_EFFECT)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.e1acon)
	e1a:SetValue(s.e1aval)
	c:RegisterEffect(e1a)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD)
	e1b:SetCode(EFFECT_SET_ATTACK)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1b:SetCondition(s.e1bcon)
	e1b:SetTarget(function(e,_c) return _c==e:GetHandler():GetBattleTarget() end)
	e1b:SetValue(0)
	c:RegisterEffect(e1b)
	--[[
	Each time your opponent activates a card or effect,
	you can make 1 face-up monster your opponent controls lose 400 ATK when it resolves,
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e2a=Effect.CreateEffect(c)
	e2a:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(s.e2acon)
	e2a:SetOperation(s.e2aevt)
	c:RegisterEffect(e2a)

	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_CHAIN_SOLVED)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(s.e2bcon)
	e2b:SetOperation(s.e2bevt)
	c:RegisterEffect(e2b)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect:
	You can Special Summon 1 Level 4 or lower Warrior or Spellcaster monster from your hand, Deck, or GY.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e5)
end
-- Mentions : "Flame Swordsman"
s.listed_names={CARD_FLAME_SWORDSMAN,id}
-- Archetype : N/A
s.listed_series={0xfe2}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	-- "Flame Swordsman" monsters
	return (c:IsSetCard(0xfe2)
	or c:IsCode(45231177)
	or c:IsCode(73936388)
	or c:IsCode(27704731)
	or c:IsCode(1047075)
	or c:IsCode(50903514)
	or c:IsCode(324483)
	or c:IsCode(98642179))
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER)
end
function s.e1acon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()

	return g:GetCount()>0
	and Duel.IsBattlePhase()
end
function s.e1aval(e,te)
	return (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP))
	and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.e1bcon(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()

	return g:GetCount()>0
	and Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
function s.e2acon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.e2aevt(e)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN&~RESET_TURN_SET,0,1)
end
function s.e2bcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return rp==1-tp
	and c:HasFlagEffect(id)
end
function s.e2bevt(e,tp)
	Duel.Hint(HINT_CARD,0,id)

	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then
		local c=e:GetHandler()
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
			if g:GetCount()>0 then
				if g:GetFirst():UpdateAttack(-400)<0 then
					Duel.Damage(1-tp,500,REASON_EFFECT)
				end
			end
		end
	end
end
function s.e3fil(c,e,tp)
	return c:IsLevelBelow(4)
	and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_SPELLCASTER))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
	and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e3fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.e3evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=Duel.SelectMatchingCard(tp,s.e3fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
