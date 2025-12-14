-- Black Flame Swordsman with Eyes of Red
local s,id,o=GetID()
-- c220000021
function s.initial_effect(c)
	--[[
	[HOPT]
	If you control a "Red-Eyes" or Warrior monster, you can Special Summon this card (from your hand).
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	-- Gains 700 ATK for each Equip Card equipped to it.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.e2val)
	c:RegisterEffect(e2)
	--[[
	While this card is equipped with an Equip Card,
	it can attack twice during each Battle Phase, also, it is unaffected by your opponent’s card effects.
	]]--
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetCode(EFFECT_EXTRA_ATTACK)
	e3a:SetCondition(s.e3con)
	e3a:SetValue(1)
	c:RegisterEffect(e3a)

	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE)
	e3b:SetCode(EFFECT_IMMUNE_EFFECT)
	e3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCondition(s.e3con)
	e3b:SetValue(s.e3bval)
	c:RegisterEffect(e3b)
	--[[
	[SOPT]
	Once per turn, when this card is targeted by a card effect (Quick Effect):
	You can negate the activation, and if you do, equip that card to this card.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	If this card attacks or is attacked:
	You can target 1 other card on the field; equip it to this card.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	If this card would be destroyed by battle, you can destroy 1 Equip Card equipped to this card instead.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
	--[[
	If this card is destroyed by card effect: Banish all cards that were equipped to it while on the field.
	]]--
	local e7a=Effect.CreateEffect(c)
	e7a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7a:SetCode(EVENT_LEAVE_FIELD_P)
	e7a:SetOperation(s.e7aevt)
	c:RegisterEffect(e7a)

	local e7b=Effect.CreateEffect(c)
	e7b:SetCategory(CATEGORY_DESTROY)
	e7b:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7b:SetCode(EVENT_DESTROYED)
	e7b:SetCondition(s.e7bcon)
	e7b:SetTarget(s.e7btgt)
	e7b:SetOperation(s.e7bevt)
	e7b:SetLabelObject(e7a)
	c:RegisterEffect(e7b)
	--[[
	[HOPT]
	If this card is Tribute Summoned: You can Special Summon 1 “Flame Swordsman” monster from your hand.
	]]--
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,3))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,{id,1})
	e8:SetCondition(s.e8con)
	e8:SetTarget(s.e8tgt)
	e8:SetOperation(s.e8evt)
	c:RegisterEffect(e8)
	--[[
	[HOPT]
	If this card is sent from the field to the GY, while it is equipped with a Monster Card:
	You can inflict 1000 damage to your opponent.
	]]--
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,4))
	e9:SetCategory(CATEGORY_DAMAGE)
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e9:SetCode(EVENT_TO_GRAVE)
	e9:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e9:SetCountLimit(1,{id,2})
	e9:SetCondition(s.e9con)
	e9:SetTarget(s.e9tgt)
	e9:SetOperation(s.e9evt)
	e9:SetLabelObject(e7a)
	c:RegisterEffect(e9)
	--[[
	[HOPT]
	When this attacking card destroys an opponent's monster by battle and sends it to the GY:
	You can equip the destroyed monster to this card.
	]]--
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,5))
	e10:SetCategory(CATEGORY_EQUIP)
	e10:SetCode(EVENT_BATTLE_DESTROYING)
	e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e10:SetCountLimit(1,{id,3})
	e10:SetCondition(s.e10con)
	e10:SetTarget(s.e10tgt)
	e10:SetOperation(s.e10evt)
	c:RegisterEffect(e10)
	--[[
	[HOPT]
	If this card you control is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY,
	then target 1 FIRE Warrior or DARK Dragon monster in your GY;
	Special Summon that target.
	]]--
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,6))
	e11:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e11:SetCode(EVENT_TO_GRAVE)
	e11:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e11:SetCountLimit(1,{id,4})
	e11:SetCost(aux.bfgcost)
	e11:SetCondition(s.e11con)
	e11:SetTarget(s.e11tgt)
	e11:SetOperation(s.e11evt)
	c:RegisterEffect(e11)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES,0xfe2}
-- Helpers
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	or c:IsRace(RACE_WARRIOR)
end
function s.e1con(e,c)
	if c==nil then return true end

	local tp=c:GetControler()

	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.e1fil,tp,LOCATION_MZONE,0,1,nil))
end
function s.e2val(e,c)
	return c:GetEquipCount()*700
end
function s.e3con(e)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()

	return g:GetCount()>0
end
function s.e3bval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.e4con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end

	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,eg,1,0,0)
	end
end
function s.e4evt(e,tp,eg,ep,ev,re)
	local c=e:GetHandler()
	local tc=eg:GetFirst()

	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Equip(tp,c,tc) then
			local e4b=Effect.CreateEffect(c)
			e4b:SetType(EFFECT_TYPE_SINGLE)
			e4b:SetCode(EFFECT_EQUIP_LIMIT)
			e4b:SetReset(RESET_EVENT+RESETS_STANDARD)
			e4b:SetValue(function(e,c) return c==e:GetLabelObject() end)
			e4b:SetLabelObject(tc)
			c:RegisterEffect(e4b)
		end
	end
end
function s.e5con(e,tp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()

	return (c==a or c==d)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		return chkc:IsOnField()
		and chkc~=c
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_ONFIELD)
end
function s.e5evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if tc:IsRelateToEffect(e) and Duel.Equip(tp,c,tc) then
		local e5b=Effect.CreateEffect(c)
		e5b:SetType(EFFECT_TYPE_SINGLE)
		e5b:SetCode(EFFECT_EQUIP_LIMIT)
		e5b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e5b:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e5b:SetLabelObject(tc)
		c:RegisterEffect(e5b)
	end
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipGroup():GetFirst()

	if chk==0 then
		return c:IsReason(REASON_BATTLE)
		and ec
		and ec:IsHasCardTarget(c)
		and ec:IsDestructable(e)
		and not ec:IsStatus(STATUS_DESTROY_CONFIRMED)
	end
	
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.e6evt(e,tp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup()
	local sg=g:Select(tp,1,1,nil)

	local ec=sg:GetFirst()
	Duel.Destroy(ec,REASON_EFFECT+REASON_REPLACE)
end
function s.e7aevt(e,tp)
	if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end

	local g=e:GetHandler():GetEquipGroup()
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.e7bcon(e,tp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
function s.e7bfil(c,e,tp)
	return c:IsAbleToRemove(tp)
end
function s.e7btgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()

	if chk==0 then
		return g
		and g:IsExists(s.e7bfil,1,nil,e,tp)
	end
	
	local sg=g:Filter(s.e7bfil,nil,e,tp)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
function s.e7bevt(e,tp)
	local g=Duel.GetTargetCards(e)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.e8con(e,tp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.e8fil(c,e,tp)
	return (c:IsSetCard(0xfe2)
	or c:IsCode(45231177)
	or c:IsCode(73936388)
	or c:IsCode(27704731)
	or c:IsCode(1047075)
	or c:IsCode(50903514)
	or c:IsCode(324483)
	or c:IsCode(98642179))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e8tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e8fil,tp,LOCATION_HAND,0,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.e8evt(e,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e8fil,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.e9con(e)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e9fil(c,e,tp)
	return c:IsMonster()
end
function s.e9tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()

	if chk==0 then
		return g
		and g:IsExists(s.e9fil,1,nil,e,tp)
	end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.e9evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.e10con(e,tp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()

	return c==Duel.GetAttacker()
	and c:IsRelateToBattle()
	and c:IsStatus(STATUS_OPPO_BATTLE)
	and bc:IsLocation(LOCATION_GRAVE)
	and bc:IsMonster()
end
function s.e10tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	local tc=e:GetHandler():GetBattleTarget()
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
function s.e10lim(e,c)
	return c==e:GetLabelObject()
end
function s.e10evt(e,tp)
	local c=e:GetHandler()
	
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e10b=Effect.CreateEffect(c)
		e10b:SetType(EFFECT_TYPE_SINGLE)
		e10b:SetCode(EFFECT_EQUIP_LIMIT)
		e10b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e10b:SetValue(s.e10lim)
		e10b:SetLabelObject(c)
		tc:RegisterEffect(e10b)
	end
end
function s.e11con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) 
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e11fil(c,e,tp)
	return ((c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR))
	or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e11tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e11fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e11fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectTarget(tp,s.e11fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.e11evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
