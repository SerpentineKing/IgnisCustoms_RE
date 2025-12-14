-- Flame Swordsman, the Red-Eyes Black Dragon Master
local s,id,o=GetID()
-- c220000004
function s.initial_effect(c)
	-- 1 Level 7 "Red-Eyes" monster + 1 "Flame Swordsman" monster
	-- Must be either Fusion Summoned, or Special Summoned by sending the above monsters you control to the GY (in which case you do not use "Polymerization").
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	Fusion.AddContactProc(c,s.cffil,s.cfevt,s.cflim,nil,nil,nil,false)
	c:EnableReviveLimit()
	-- This card's name becomes "Flame Swordsman" while on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_FLAME_SWORDSMAN)
	c:RegisterEffect(e1)
	-- Cannot be destroyed by battle.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--[[
	This card can attack a number of times each Battle Phase,
	up to the number of Normal Monsters used as Fusion Material for this card.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3a:SetOperation(s.e3evt)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE)
	e3b:SetCode(EFFECT_MATERIAL_CHECK)
	e3b:SetValue(s.e3val)
	e3b:SetLabelObject(e3a)
	c:RegisterEffect(e3b)
	--[[
	[HOPT]
	You can target 1 Level 7 or lower Dragon monster in your GY;
	equip it to this card as an Equip Spell that gives this card ATK equal to half that monster's original ATK.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,{id,0})
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	At the end of the Damage Step, when this card attacks an opponent's monster,
	but the opponent's monster was not destroyed by the battle:
	You can target 1 card in your banishment;
	either add it to your hand or shuffle it into the Deck.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	[HOPT]
	If this card is destroyed by card effect and sent to the GY: Inflict 2400 damage to your opponent,
	and if you do, you can return 1 other Fusion Monster from your GY to the Extra Deck.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DAMAGE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.e6con)
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
end
-- Mentions : "Flame Swordsman"
s.listed_names={CARD_FLAME_SWORDSMAN,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES,0xfe2}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
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
function s.cflim(e,se,sp,st)
	return (st&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.cffil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,nil)
end
function s.cfevt(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end
function s.e3val(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsType,nil,TYPE_NORMAL)
	e:GetLabelObject():SetLabel(ct)
end
function s.e3fil(c,tp)
	return c:IsRace(RACE_DRAGON)
	and c:IsLevelBelow(7)
	and c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	local ct=e:GetLabel()

	local e3a1=Effect.CreateEffect(c)
	e3a1:SetType(EFFECT_TYPE_SINGLE)
	e3a1:SetCode(EFFECT_EXTRA_ATTACK)
	e3a1:SetValue(ct-1)
	e3a1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e3a1)
end
function s.e4fil(c,tp)
	return c:IsRace(RACE_DRAGON)
	and c:IsLevelBelow(7)
	and c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.e4fil,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e4lim(e,c)
	return c==e:GetLabelObject()
end
function s.e4evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e4a=Effect.CreateEffect(c)
		e4a:SetType(EFFECT_TYPE_SINGLE)
		e4a:SetCode(EFFECT_EQUIP_LIMIT)
		e4a:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4a:SetValue(s.e4lim)
		e4a:SetLabelObject(c)
		tc:RegisterEffect(e4a)
		-- Gain ATK
		local e4b=Effect.CreateEffect(c)
		e4b:SetType(EFFECT_TYPE_EQUIP)
		e4b:SetCode(EFFECT_UPDATE_ATTACK)
		e4b:SetValue(tc:GetBaseAttack()/2)
		e4b:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4b)
	end
end
function s.e5con(e,tp)
	local c=e:GetHandler()
	local d=c:GetBattleTarget()

	if not d then return false end

	return c==Duel.GetAttacker()
	and c:IsStatus(STATUS_OPPO_BATTLE)
	and d:IsOnField()
	and d:IsRelateToBattle()
end
function s.e5fil(c,tp)
	return (c:IsAbleToDeck()
	or c:IsAbleToHand())
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsLocation(LOCATION_REMOVED)
		and chkc:IsControler(tp)
		and s.e5fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e5fil,tp,LOCATION_REMOVED,0,1,nil,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.e5fil,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function s.e5evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local b1=tc:IsAbleToHand()
		local b2=tc:IsAbleToDeck()

		if not (b1 or b2) then return end

		local op=1
		if b1 and b2 then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)})
		elseif (not b1) and b2 then
			op=2
		end
		
		if op==1 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		elseif op==2 then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.e6con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_EFFECT)
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(2400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2400)
end
function s.e6fil(c)
	return c:IsType(TYPE_FUSION)
	and c:IsAbleToExtra()
end
function s.e6evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if Duel.IsExistingMatchingCard(s.e6fil,tp,LOCATION_GRAVE,0,1,c) then
			if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
				local g=Duel.SelectMatchingCard(tp,s.e6fil,tp,LOCATION_GRAVE,0,1,1,c)
				if g:GetCount()>0 then
					Duel.SendtoHand(g,nil,REASON_EFFECT)
				end
			end
		end
	end
end
