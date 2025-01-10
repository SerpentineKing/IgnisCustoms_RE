-- Old Swordmaster of the Flame
local s,id,o=GetID()
-- c220000008
function s.initial_effect(c)
	-- 1 “Flame Swordsman” monster + 1 Spellcaster monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- If this card is equipped with an Equip Card, it gains 400 ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(aux.NOT(s.e1con))
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--[[
	If this card is equipped with “Metalmorph”, this card gains the following effects.
	•
	This card is unaffected by your opponent’s Spell/Trap effects.
	•
	If this card battles a monster, during damage calculation:
	This card gains ATK equal to half the ATK of that monster during the Damage Step only.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.e2con)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.e3con)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	Each time your opponent activates a card or effect,
	you can make 1 face-up monster your opponent controls lose 400 ATK when it resolves,
	and if you do, inflict 500 damage to your opponent.
	]]--
	local e4a=Effect.CreateEffect(c)
	e4a:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e4a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4a:SetCode(EVENT_CHAINING)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetCondition(s.e4acon)
	e4a:SetOperation(s.e4aevt)
	c:RegisterEffect(e4a)

	local e4b=Effect.CreateEffect(c)
	e4b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4b:SetCode(EVENT_CHAIN_SOLVED)
	e4b:SetRange(LOCATION_MZONE)
	e4b:SetCondition(s.e4bcon)
	e4b:SetOperation(s.e4bevt)
	c:RegisterEffect(e4b)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect:
	You can Special Summon 1 Level 4 or lower Warrior or Spellcaster monster from your hand, Deck, or GY.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,{id,0})
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
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
function s.e1con(e)
	return e:GetHandler():GetEquipCount()>0
end
function s.e2con(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()

	-- Metalmorph
	return g:GetCount()>0
	and g:IsExists(Card.IsCode,1,nil,68540058)
end
function s.e2val(e,te)
	return (te:IsActiveType(TYPE_SPELL) or te:IsActiveType(TYPE_TRAP))
	and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.e3con(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	local d=c:GetBattleTarget()

	if not d then return false end

	local atk=d:GetAttack()/2
	e:SetLabel(atk)

	-- Metalmorph
	return atk>0
	and g:GetCount()>0
	and g:IsExists(Card.IsCode,1,nil,68540058)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	local atk=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() and atk then
		local e3b=Effect.CreateEffect(c)
		e3b:SetType(EFFECT_TYPE_SINGLE)
		e3b:SetCode(EFFECT_UPDATE_ATTACK)
		e3b:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e3b:SetValue(atk)
		c:RegisterEffect(e3b)
	end
end
function s.e4acon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function s.e4aevt(e)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN&~RESET_TURN_SET,0,1)
end
function s.e4bcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	return rp==1-tp
	and c:HasFlagEffect(id)
end
function s.e4bevt(e,tp,eg,ep,ev,re,r,rp)
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
function s.e5fil(c,e,tp)
	return c:IsLevelBelow(4)
	and (c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_SPELLCASTER))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e5con(e,tp,eg,ep,ev,re,r)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
	and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e5fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.e5evt(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e5fil,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
