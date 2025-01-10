-- Gearfried, Master of the Red-Eyes Black Dragon Sword
local s,id,o=GetID()
-- c220000005
function s.initial_effect(c)
	-- 1 Level 7 “Red-Eyes” monster + 1 Level 8 Warrior monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	--[[
	When this card is Summoned:
	You can send 1 “Claw of Hermos” and 1 Dragon monster from your Deck to the GY;
	equip 1 “Red-Eyes Black Dragon Sword” from your Extra Deck to this card.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1)
	e1:SetCost(s.e1cst)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- This card gains 1000 ATK, and 500 ATK/DEF for each Dragon monster on the field and in the GYs.
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(1000)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e4)

	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(s.e4val)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e5)
	
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e6)
	--[[
	[HOPT]
	If a “Red-Eyes Black Dragon Sword” equipped to this card
	is sent from your field to the GY by an opponent’s card effect (except during the Damage Step):
	You can target 1 card your opponent controls; destroy it.
	]]--
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_DESTROY)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetCountLimit(1,{id,0})
	e7:SetCondition(s.e7con)
	e7:SetTarget(s.e7tgt)
	e7:SetOperation(s.e7evt)
	c:RegisterEffect(e7)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY; return all Fusion and Xyz Monsters in your GY to the Extra Deck.
	]]--
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCountLimit(1,{id,1})
	e8:SetCost(aux.bfgcost)
	e8:SetTarget(s.e8tgt)
	e8:SetOperation(s.e8evt)
	c:RegisterEffect(e8)
end
-- Archetype : Red-Eyes
s.listed_series={0x3b}
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(0x3b)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR)
	and c:IsLevel(8)
end
function s.e1fil1(c)
	-- Claw of Hermos
	return c:IsCode(46232525)
	and c:IsAbleToGraveAsCost()
end
function s.e1fil2(c)
	return c:IsRace(RACE_DRAGON)
	and c:IsAbleToGraveAsCost()
end
function s.e1fil3(c,e,tp)
	-- Red-Eyes Black Dragon Sword
	return c:IsCode(19747827)
	and c:CheckUniqueOnField(tp)
	and not c:IsForbidden()
end
function s.e1cst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil1,tp,LOCATION_DECK,0,1,nil)
		and Duel.IsExistingMatchingCard(s.e1fil2,tp,LOCATION_DECK,0,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)

	local g1=Duel.SelectMatchingCard(tp,s.e1fil1,tp,LOCATION_DECK,0,1,1,nil)
	local s1=g1:GetFirst()
	
	local g2=Duel.SelectMatchingCard(tp,s.e1fil2,tp,LOCATION_DECK,0,1,1,nil)
	local s2=g2:GetFirst()

	local g=Group.CreateGroup()
	g:AddCard(s1)
	g:AddCard(s2)

	Duel.SendtoGrave(g,REASON_COST)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_EXTRA)
		and chkc:IsControler(tp)
		and s.e1fil3(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e1fil3,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.GetMatchingGroup(s.e1fil3,tp,LOCATION_EXTRA,0,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.e2lim(e,c)
	return c==e:GetLabelObject()
end
function s.e2evt(e)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.e1fil3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if Duel.Equip(tp,tc,c,true) then
		local e1b=Effect.CreateEffect(c)
		e1b:SetType(EFFECT_TYPE_SINGLE)
		e1b:SetCode(EFFECT_EQUIP_LIMIT)
		e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1b:SetValue(s.e2lim)
		e1b:SetLabelObject(c)
		tc:RegisterEffect(e1b)
	end
end
function s.e4val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)*500
end
function s.e7fil(c,e,tp,ec,rp)
	return c:IsLocation(LOCATION_GRAVE)
	and rp==(1-tp)
	and c:IsControler(tp)
	and c:GetEquipTarget()==ec
	and c:IsCode(46232525)
end
function s.e7con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.e7fil,1,nil,nil,tp,e:GetHandler(),rp)
end
function s.e7tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsControler(1-tp)
		and chkc:IsLocation(LOCATION_ONFIELD)
	end
	if chk==0 then
		return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)

	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e7evt(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e8con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.e8fil(c)
	return (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))
	and c:IsAbleToExtra()
end
function s.e8tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e8fil,tp,LOCATION_GRAVE,0,1,e:GetHandler())
	end
end
function s.e8evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e8fil,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
