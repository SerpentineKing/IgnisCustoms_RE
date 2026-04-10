-- Dimension of Chaos
local s,id,o=GetID()
-- c220000059
function s.initial_effect(c)
	-- [Activation]
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- Your opponent cannot activate cards or effects in response to the activation of your Ritual Spell Cards.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	Your opponent cannot activate cards or effects
	when a "Chaos" or "Black Luster Soldier" Ritual Monster(s) is Ritual Summoned.
	]]--
	local e2a1=Effect.CreateEffect(c)
	e2a1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a1:SetRange(LOCATION_SZONE)
	e2a1:SetOperation(s.e2a1evt)
	c:RegisterEffect(e2a1)

	local e2a2=Effect.CreateEffect(c)
	e2a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a2:SetCode(EVENT_CHAIN_END)
	e2a2:SetRange(LOCATION_SZONE)
	e2a2:SetOperation(s.e2a2evt)
	e2a2:SetLabelObject(e2a1)
	c:RegisterEffect(e2a2)
	--[[
	[H1PT]
	During your Main Phase:
	You can activate 1 of these effects,
	or if your opponent controls a monster, you can activate 2 of these effects, in sequence, instead;
	•
	Set 1 "Chaos Form" from your Deck or GY.
	•
	Reveal 1 Normal Monster in your hand;
	add 1 Ritual Monster from your Deck to your hand, with the same Type and Level as the revealed monster.
	•
	Reveal 1 Ritual Monster in your hand;
	send 1 Normal Monster from your Deck to the GY, with the same Level and ATK as the revealed monster.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
local CARD_CHAOS_FORM = 21082832
-- Mentions : "Chaos Form"
s.listed_names={CARD_CHAOS_FORM,id}
-- Archetype : Chaos
s.listed_series={SET_CHAOS}
-- Helpers
function s.e1lim(e,rp,tp)
	return tp==rp
end
function s.e1evt(e,tp,eg,ep,ev,re)
	local rc=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandlerPlayer()==tp and rc:IsRitualSpell() then
		Duel.SetChainLimit(s.e1lim)
	end
end
function s.e2a1fil(c)
	return (c:IsSetCard(SET_CHAOS) or c:IsSetCard(SET_BLACK_LUSTER_SOLDIER) or c:IsSetCard(SET_NUMBER_C))
	and c:IsRitualMonster()
	and c:IsRitualSummoned()
end
function s.e2a1evt(e,tp,eg)
	if eg:IsExists(s.e2a1fil,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.e2a2evt(e,tp)
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) and e:GetLabelObject():GetLabel()==1 then
		Duel.SetChainLimitTillChainEnd(s.e1lim)
	end
end
function s.e3a1fil(c)
	return c:IsCode(CARD_CHAOS_FORM)
	and c:IsSSetable()
end
function s.e3a2fil1(c,tp)
	return c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.e3a2fil2,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetRace())
end
function s.e3a2fil2(c,lvl,typ)
	return c:IsRitualMonster()
	and c:IsLevel(lvl)
	and c:IsRace(typ)
	and c:IsAbleToHand()
end
function s.e3a3fil1(c,tp)
	return c:IsRitualMonster()
	and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.e3a3fil2,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetBaseAttack())
end
function s.e3a3fil2(c,lvl,atk)
	return c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and c:IsLevel(lvl)
	and c:IsAttack(atk)
	and c:IsAbleToGrave()
end
-- [Chain]
function s.e3a3fil3a(c,tp)
	return c:IsType(TYPE_NORMAL)
	and c:IsMonster()
	and not c:IsPublic()
	and Duel.IsExistingMatchingCard(s.e3a3fil3b,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetRace())
end
function s.e3a2fil3b(c,lvl,typ)
	return c:IsRitualMonster()
	and c:IsLevel(lvl)
	and c:IsRace(typ)
	and c:IsAbleToHand()
	and Duel.IsExistingMatchingCard(s.e3a3fil2,tp,LOCATION_DECK,0,1,nil,c:GetLevel(),c:GetBaseAttack())
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local b1tgt=Duel.IsExistingMatchingCard(s.e3a1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	local b2tgt=Duel.IsExistingMatchingCard(s.e3a2fil1,tp,LOCATION_HAND,0,1,nil,tp)
	local b3tgt=Duel.IsExistingMatchingCard(s.e3a3fil1,tp,LOCATION_HAND,0,1,nil,tp)

	if chk==0 then
		return b1tgt or b2tgt or b3tgt
	end

	local bxtgt=Duel.IsExistingMatchingCard(s.e3a3fil3a,tp,LOCATION_HAND,0,1,nil,tp)
	local b1tgtn=(b1tgt) and 1 or 0
	local b2tgtn=(b2tgt) and 1 or 0
	local b3tgtn=(b3tgt) and 1 or 0

	local max_ct=1
	if Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0 and (b1tgtn+b2tgtn+b3tgtn>=2 or (b3tgt and bxtgt)) then
		max_ct=Duel.SelectEffect(tp,
			{aux.TRUE,aux.Stringid(id,1)},
			{aux.TRUE,aux.Stringid(id,2)}
		)
	end

	local bsel = 0
	for eff_ct=1,max_ct do
		local eff_table={}
		local val_table={}

		if b1tgt and bsel&0x1==0 then
			table.insert(eff_table, aux.Stringid(id,1))
			table.insert(val_table,0x1)
		end
		if b2tgt and bsel&0x2==0 then
			table.insert(eff_table, aux.Stringid(id,2))
			table.insert(val_table,0x2)
		end
		if (b3tgt or (bsel&0x2==0 and bxtgt)) and bsel&0x4==0 then
			table.insert(eff_table, aux.Stringid(id,3))
			table.insert(val_table,0x4)
		end

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,table.unpack(eff_table))
		bsel=bsel+val_table[op+1]
	end

	if bsel&0x2==0x2 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if bsel&0x4==0x4 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end

	e:SetLabel(bsel)
end
function s.e3evt(e,tp)
	local bsel=e:GetLabel()

	if not bsel then return end

	if bsel&0x1==0x1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.e3a1fil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SSet(tp,g)
		end
		Duel.BreakEffect()
	end
	if bsel&0x2==0x2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local rc=Duel.SelectMatchingCard(tp,s.e3a2fil1,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
		Duel.ConfirmCards(1-tp,rc)
		Duel.ShuffleHand(tp)

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.e3a2fil2,tp,LOCATION_DECK,0,1,1,nil,rc:GetLevel(),rc:GetRace())
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		Duel.BreakEffect()
	end
	if bsel&0x4==0x4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local rc=Duel.SelectMatchingCard(tp,s.e3a3fil1,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
		Duel.ConfirmCards(1-tp,rc)
		Duel.ShuffleHand(tp)

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.e3a3fil2,tp,LOCATION_DECK,0,1,1,nil,rc:GetLevel(),rc:GetBaseAttack())
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
