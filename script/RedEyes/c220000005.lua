-- Gearfried the Black Dragon Swordmaster
local s,id,o=GetID()
-- c220000005
function s.initial_effect(c)
	-- 1 Level 7 "Red-Eyes" monster + 1 Level 8 Warrior monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- During the Battle Phase, all monsters you control become Dragon monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(RACE_DRAGON)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	If either player equips an Equip Card(s) to this card:
	You can target 1 card your opponent controls;
	destroy it.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_EQUIP)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[H1PT]
	(Quick Effect):
	You can target 1 Fusion Monster Card in your field or GY that mentions "The Claw of Hermos";
	return it to the Extra Deck,
	then you can Special Summon 1 Fusion Monster with a different name from your Extra Deck
	that mentions "The Claw of Hermos", except a Level 8 monster.
	(This is treated as a Special Summon by the effect of "The Claw of Hermos".)
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local CARD_THE_CLAW_OF_HERMOS = 46232525
-- Mentions : "The Claw of Hermos"
s.listed_names={CARD_THE_CLAW_OF_HERMOS,id}
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
function s.e1con(e)
	local tp=e:GetHandlerPlayer()

	return Duel.IsBattlePhase()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsOnField()
		and chkc:IsControler(1-tp)
		and chkc:IsDestructable()
	end
	if chk==0 then
		return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,c)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	
	local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_ONFIELD,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.e3fil1(c)
	return ((c:IsFaceup() and c:IsLocation(LOCATION_ONFIELD)) or c:IsLocation(LOCATION_GRAVE))
	and c:IsOriginalType(TYPE_FUSION)
	and c:IsMonsterCard()
	and (c:ListsCode(CARD_THE_CLAW_OF_HERMOS) or c.material_race)
	and c:IsAbleToExtra()
end
function s.e3fil2(c,e,tp,rc)
	return c:IsType(TYPE_FUSION)
	and c:IsMonster()
	and (c:ListsCode(CARD_THE_CLAW_OF_HERMOS) or c.material_race)
	and not c:IsCode(rc:GetCode())
	and not c:IsLevel(8)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsControler(tp)
		and s.e3fil1(chkc)
	end
	if chk==0 then
		return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e3fil1,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil))
		or Duel.IsExistingTarget(s.e3fil1,tp,LOCATION_MZONE,0,1,nil)
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.e3fil1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,e,tp)
	
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()
	
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end

			local g=Duel.GetMatchingGroup(s.e3fil2,tp,LOCATION_EXTRA,0,nil,e,tp,tc)
			if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=g:Select(tp,1,1,nil):GetFirst()
				if sc then
					Duel.BreakEffect()
					Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
				end
			end
		end
	end
end
