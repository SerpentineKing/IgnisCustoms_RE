-- Gearfried, Master of the Red-Eyes Black Dragon Sword
local s,id,o=GetID()
-- c220000005
function s.initial_effect(c)
	-- 1 Level 7 “Red-Eyes” monster + 1 Level 8 Warrior monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	--[[
	When this card is Summoned:
	You can send 1 “The Claw of Hermos” and 1 Dragon monster from your Deck to the GY;
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

	local e1b=e1:Clone()
	e1b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	
	local e1c=e1:Clone()
	e1c:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1c)
	-- This card gains 1000 ATK, and 500 ATK/DEF for each Dragon monster on the field and in the GYs.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)

	local e2b=Effect.CreateEffect(c)
	e2b:SetCategory(CATEGORY_ATKCHANGE)
	e2b:SetType(EFFECT_TYPE_SINGLE)
	e2b:SetCode(EFFECT_UPDATE_ATTACK)
	e2b:SetValue(s.e2bval)
	c:RegisterEffect(e2b)
	
	local e2c=e2b:Clone()
	e2c:SetCategory(CATEGORY_DEFCHANGE)
	e2c:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2c)
	--[[
	[HOPT]
	If a “Red-Eyes Black Dragon Sword” equipped to this card
	is sent from your field to the GY by an opponent’s card effect (except during the Damage Step):
	You can target 1 card your opponent controls; destroy it.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect and sent to the GY:
	You can banish this card from your GY; return all Fusion and Xyz Monsters in your GY to the Extra Deck.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
end
-- Mentions : "The Claw of Hermos","Red-Eyes Black Dragon Sword"
s.listed_names={46232525,19747827,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR)
	and c:IsLevel(8)
end
function s.e1fil1(c)
	return c:IsCode(46232525)
	and c:IsAbleToGraveAsCost()
end
function s.e1fil2(c)
	return c:IsRace(RACE_DRAGON)
	and c:IsAbleToGraveAsCost()
end
function s.e1fil3(c,e,tp)
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
function s.e1lim(e,c)
	return c==e:GetLabelObject()
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.e1fil3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if Duel.Equip(tp,tc,c,true) then
		local e1d=Effect.CreateEffect(c)
		e1d:SetType(EFFECT_TYPE_SINGLE)
		e1d:SetCode(EFFECT_EQUIP_LIMIT)
		e1d:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1d:SetValue(s.e1lim)
		e1d:SetLabelObject(c)
		tc:RegisterEffect(e1d)
	end
end
function s.e2bval(e,c)
	return 500*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
end
function s.e3fil(c,tp,ec)
	-- Red-Eyes Black Dragon Sword
	return c:IsCode(19747827)
	and c:IsPreviousControler(tp)
	and c:GetPreviousEquipTarget()==ec
	and c:IsReasonPlayer(1-tp)
end
function s.e3con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(s.e3fil,1,nil,tp,c)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.e3evt(e)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e4con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.e4fil(c)
	return (c:IsType(TYPE_FUSION) or c:IsType(TYPE_XYZ))
	and c:IsAbleToExtra()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e4fil,tp,LOCATION_GRAVE,0,1,e:GetHandler())
	end
end
function s.e4evt(e,tp)
	local g=Duel.GetMatchingGroup(s.e4fil,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
