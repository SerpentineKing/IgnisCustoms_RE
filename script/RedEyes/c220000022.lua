-- Alligator's Sword with Eyes of Red
local s,id,o=GetID()
-- c220000022
function s.initial_effect(c)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can add 1 Spell/Trap that has "Red-Eyes" in its text from your Deck or GY to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--[[
	[HOPT]
	If this card is targeted for an attack by a monster with a higher Level than it:
	You can change that monster to face-down Defense Position,
	and if you do, until your opponent's next turn, it cannot change its battle position, be Tributed,
	or used as material for the Summon of a monster from the Extra Deck.
	]]--
	-- TODO : Set timing to opp. turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return (c:IsSetCard(SET_RED_EYES)
	or c:IsSetCard(0xfe1)
	or c:IsCode(36262024)
	or c:IsCode(93969023)
	or c:IsCode(66574418)
	or c:IsCode(11901678)
	or c:IsCode(45349196)
	or c:IsCode(90660762)
	or c:IsCode(19025379)
	or c:IsCode(71408082)
	or c:IsCode(71408082)
	or c:IsCode(32566831)
	or c:IsCode(52684508)
	or c:IsCode(18803791))
	and c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.e2con(e,tp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	return a:GetLevel()>c:GetLevel()
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetAttacker()
	if tc and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)>0 then
		local e2b=Effect.CreateEffect(c)
		e2b:SetDescription(3313)
		e2b:SetType(EFFECT_TYPE_SINGLE)
		e2b:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2b:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2b)

		local e2c=Effect.CreateEffect(c)
		e2c:SetDescription(3303)
		e2c:SetType(EFFECT_TYPE_SINGLE)
		e2c:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2c:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2c:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2c:SetValue(1)
		tc:RegisterEffect(e2c,true)

		local e2d=Effect.CreateEffect(c)
		e2d:SetType(EFFECT_TYPE_SINGLE)
		e2d:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2d:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2d:SetValue(1)
		tc:RegisterEffect(e2d,true)

		local e2e=Effect.CreateEffect(c)
		e2e:SetType(EFFECT_TYPE_SINGLE)
		e2e:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e2e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2e:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		e2e:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2e)
	end
end
