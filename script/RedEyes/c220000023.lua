-- Axe Raider with Eyes of Red
local s,id,o=GetID()
-- c220000023
function s.initial_effect(c)
	--[[
	[HOPT]
	When an opponent's monster, that was Normal or Special Summoned this turn, declares an attack:
	You can discard this card;
	destroy that attacking monster, and if you do, inflict damage to your opponent equal to half the original ATK of that monster.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.e1con)
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is Normal or Special Summoned:
	You can Special Summon 1 Level 4 or lower "Red-Eyes" or Warrior monster from your Deck or GY, except "Axe Raider with Eyes of Red",
	also, you cannot Special Summon monsters from the Extra Deck for the rest of this turn,
	except "Red-Eyes" monsters or monsters that list a "Red-Eyes" monster as material.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)

	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--[[
	[HOPT]
	When your opponent activates a monster effect (Quick Effect):
	You can negate the activation, and if you do, banish it.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	During the Battle Phase (Quick Effect):
	You can return all Spells / Traps on the field to the hand.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetCountLimit(1,{id,3})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	During damage calculation, if this card battles (Quick Effect):
	You can make this card gain ATK equal to its current DEF until the end of your opponent's next turn.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,4})
	e5:SetCondition(s.e5con)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	[HOPT]
	If this card is sent from the field to the GY:
	You can target 5 other cards that have "Red-Eyes" in their text in your GY and/or banishment;
	shuffle them into the Deck, and if you do, draw 2 cards.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,4))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,{id,5})
	e6:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1con(e,tp)
	local a=Duel.GetAttacker()

	return a:IsControler(1-tp)
	and a:IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable()
	end

	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()

	if chk==0 then
		return a:IsRelateToBattle()
	end
	
	local dmg=math.max(a:GetBaseAttack()/2,0)

	Duel.SetOperationInfo(0,CATEGORY_DESTROY,a,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end
function s.e1evt(e,tp)
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() and Duel.Destroy(a,REASON_EFFECT)>0 then
		local atk=a:GetBaseAttack()/2
		if atk>0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
function s.e2fil(c,e,tp)
	return (c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_WARRIOR))
	and c:IsLevelBelow(4)
	and not c:IsCode(id)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.e2lim(e,c)
	return (not (c:IsSetCard(SET_RED_EYES) or c:ListsArchetypeAsMaterial(SET_RED_EYES)))
	and c:IsLocation(LOCATION_EXTRA)
end
function s.e2evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e2fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end

	local c=e:GetHandler()

	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_FIELD)
	ge1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	ge1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	ge1:SetDescription(aux.Stringid(id,1))
	ge1:SetTargetRange(1,0)
	ge1:SetTarget(s.e2lim)
	ge1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(ge1,tp)
end
function s.e3con(e,tp,eg,ep,ev,re)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and ep==1-tp
	and re:IsMonsterEffect()
	and Duel.IsChainNegatable(ev)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)

	if rc:IsAbleToRemove(tp) and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,tp,0)
	end
end
function s.e3evt(e,tp,eg,ep,ev,re)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.e4con(e,tp)
	return Duel.IsBattlePhase()
end
function s.e4fil(c)
	return c:IsSpellTrap()
	and c:IsAbleToHand()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
	end

	local g=Duel.GetMatchingGroup(s.e4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function s.e4evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.e4fil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)

	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
function s.e5con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	return c==a or c==d
end
function s.e5evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_SINGLE)
	e5a:SetCode(EFFECT_UPDATE_ATTACK)
	e5a:SetValue(c:GetDefense())
	e5a:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	c:RegisterEffect(e5a)
end
function s.e6fil(c)
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
	and c:IsAbleToDeck()
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return (chkc:IsLocation(LOCATION_GRAVE) or chkc:IsLocation(LOCATION_REMOVED))
		and chkc:IsControler(tp)
		and s.e6fil(chkc)
	end
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
		and Duel.IsExistingTarget(s.e6fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,5,5,c)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	
	local g=Duel.SelectTarget(tp,s.e6fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.e6evt(e,tp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end

	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
	end
	
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end
