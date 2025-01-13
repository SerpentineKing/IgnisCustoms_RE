-- Red-Eyes Mechanization
local s,id,o=GetID()
-- c220000029
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can add 1 DARK Machine monster, or 1 monster that mentions “Max Metalmorph”,
	and 1 “Metalmorph” Trap from your Deck or GY to your hand.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	At the start of the Damage Step, if your “Red-Eyes” or Machine monster battles:
	You can target 1 monster in either GY;
	equip it to 1 “Red-Eyes” or Machine monster you control as an Equip Spell,
	and if you do, the equipped monster gains ATK/DEF equal to that target’s ATK/DEF until the end of this Battle Phase.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If either player equips an Equip Card(s) to a monster(s) on the field, even during the Damage Step:
	You can destroy those Equip Cards, then you can destroy 1 Spell/Trap your opponent controls.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_EQUIP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If this card you control is destroyed by card effect and sent to the GY: You can banish this card from your GY;
	Special Summon 1 DARK Machine or “Red-Eyes” monster from your hand or GY.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,3})
	e4:SetCost(aux.bfgcost)
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Mentions : "Max Metalmorph"
s.listed_names={CARD_MAX_METALMORPH,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil1(c)
	return ((c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE))
	or c:ListsCode(CARD_MAX_METALMORPH))
	and c:IsMonster()
	and c:IsAbleToHand()
end
function s.e1fil2(c)
	return c:IsSetCard(SET_METALMORPH)
	and c:IsTrap()
	and c:IsAbleToHand()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end

	local g1=Duel.GetMatchingGroup(s.e1fil1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.e1fil2,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)

	if g1:GetCount()>0 and g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		
		local sg1=g1:Select(tp,1,1,nil)
		local sg2=g2:Select(tp,1,1,nil)
		
		local sg=Group.CreateGroup()
		sg:AddCard(sg1:GetFirst())
		sg:AddCard(sg2:GetFirst())

		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.e2con(e,tp)
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then
		a=Duel.GetAttackTarget()
	end
	return a and a:IsFaceup() and (a:IsSetCard(SET_RED_EYES) or a:IsRace(RACE_MACHINE))
end
function s.e2fil1(c,tp)
	return c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e2fil2(c)
	return c:IsSetCard(SET_RED_EYES) or c:IsRace(RACE_MACHINE)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and s.e2fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.e2fil2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	
	local g=Duel.SelectTarget(tp,s.e2fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e2lim(e,c)
	return c==e:GetLabelObject()
end
function s.e5evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.e2fil2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local ec=g:GetFirst()

	local tc=Duel.GetFirstTarget()
	if g:GetCount()>0 and tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,ec,true) then
		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_SINGLE)
		e2b:SetCode(EFFECT_EQUIP_LIMIT)
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2b:SetValue(s.e2lim)
		e2b:SetLabelObject(ec)
		tc:RegisterEffect(e2b)

		local e2c=Effect.CreateEffect(c)
		e2c:SetType(EFFECT_TYPE_SINGLE)
		e2c:SetCode(EFFECT_UPDATE_ATTACK)
		e2c:SetValue(tc:GetBaseAttack())
		e2c:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE)
		c:RegisterEffect(e2c)

		local e2d=Effect.CreateEffect(c)
		e2d:SetType(EFFECT_TYPE_SINGLE)
		e2d:SetCode(EFFECT_UPDATE_DEFENSE)
		e2d:SetValue(tc:GetBaseDefense())
		e2d:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE)
		c:RegisterEffect(e2d)
	end
end
function s.e3fil1(c)
	return c:GetEquipTarget()
end
function s.e3fil2(c)
	return c:IsSpellTrap()
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.e3fil,1,nil)
	end

	local g=eg:Filter(s.e3fil,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.e3evt(e,tp)
	local g=eg:Filter(s.e3fil,nil)
	local sg=Duel.GetMatchingGroup(s.e3fil2,tp,0,LOCATION_ONFIELD,nil)

	if Duel.Destroy(g,REASON_EFFECT)>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		
		local tg=sg:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.e4con(e,tp)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_EFFECT)
	and c:IsPreviousControler(tp)
	and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.e4fil(c,e,tp)
	return ((c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)) or c:IsSetCard(SET_RED_EYES))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e4fil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.e4evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.e4fil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
