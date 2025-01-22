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
		local e2b0=Effect.CreateEffect(c)
		e2b0:SetType(EFFECT_TYPE_SINGLE)
		e2b0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2b0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW,2) -- RESET_OPPO_TURN

		local e2b1=e2b0:Clone()
		e2b1:SetDescription(3313)
		e2b1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e2b1)

		local e2b2=e2b0:Clone()
		e2b2:SetDescription(3303)
		e2b2:SetCode(EFFECT_UNRELEASABLE_SUM)
		e2b2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2b2:SetValue(1)
		tc:RegisterEffect(e2b2,true)

		local e2b3=e2b0:Clone()
		e2b3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2b3:SetValue(1)
		tc:RegisterEffect(e2b3,true)

		local e2b4=e2b0:Clone()
		e2b4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e2b4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		tc:RegisterEffect(e2b4)
	end
end
function s.e2lim(e,c)
	return c~=e:GetLabelObject()
end
