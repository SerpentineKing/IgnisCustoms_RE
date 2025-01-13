-- Red-Eyes Zombification
local s,id,o=GetID()
-- c220000032
function s.initial_effect(c)
	-- [Activation]
	--[[
	[HOPT]
	When this card is activated:
	You can send 1 “Red-Eyes” monster from your hand or Deck to the GY.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	-- All “Red-Eyes” monsters on the field and in your GY become Zombie monsters.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_ZOMBIE)
	e2:SetTarget(s.e2tgt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	You can target 1 “Red-Eyes” monster in your GY;
	Special Summon it,
	then if that target is a Tuner monster, you can, immediately after this effect resolves,
	Synchro Summon 1 Synchro Monster from your Extra Deck using monsters you control, including the Summoned monster.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
	--[[
	[HOPT]
	If a Synchro Monster(s) that lists a “Red-Eyes” monster as material is Special Summoned to your field (except during the Damage Step):
	You can draw 1 card, then send 1 card from your hand to the GY.
	]]--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tgt)
	e4:SetOperation(s.e4evt)
	c:RegisterEffect(e4)
	--[[
	[HOPT]
	When a “Red-Eyes” monster declares an attack:
	You can target 1 monster in either GY;
	equip it to a “Red-Eyes” Synchro Monster you control as an Equip Spell that gives it 200 ATK.
	]]--
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,{id,3})
	e5:SetCondition(s.e5con)
	e5:SetTarget(s.e5tgt)
	e5:SetOperation(s.e5evt)
	c:RegisterEffect(e5)
	--[[
	[HOPT]
	If either player equips an Equip Card(s) to a monster(s) on the field, even during the Damage Step:
	You can destroy those Equip Cards,
	then you can destroy 1 Spell/Trap your opponent controls.
	]]--
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,4))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_EQUIP)
	e6:SetRange(LOCATION_SZONE)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,{id,4})
	e6:SetTarget(s.e6tgt)
	e6:SetOperation(s.e6evt)
	c:RegisterEffect(e6)
	--[[
	[HOPT]
	If this card is sent to the GY by card effect: You can banish this card from your GY;
	Special Summon 1 “Red-Eyes” monster from your GY.
	]]--
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,6))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCountLimit(1,{id,5})
	e7:SetCost(aux.bfgcost)
	e7:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e7:SetTarget(s.e7tgt)
	e7:SetOperation(s.e7evt)
	c:RegisterEffect(e7)
end
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsAbleToGrave()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.e1evt(e,tp)
	if Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		
		local g=Duel.SelectMatchingCard(tp,s.e1fil,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
function s.e2tgt(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end

		c:ResetFlagEffect(1)
		
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
end
function s.e3fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e3fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.e3fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	
	local g=Duel.SelectTarget(tp,s.e3fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.e3evt(e,tp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()

	if tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsType(TYPE_TUNER) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
			Duel.BreakEffect()

			local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
			if g:GetCount()>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

				local sg=g:Select(tp,1,1,nil)
				Duel.SynchroSummon(tp,sg:GetFirst(),nil)
			end
		end
	end
end
function s.e4fil1(c,tp)
	return c:IsType(TYPE_SYNCHRO)
	and c:ListsArchetypeAsMaterial(SET_RED_EYES)
	and c:IsFaceup()
	and c:IsControler(tp)
end
function s.e4con(e,tp,eg)
	return eg:IsExists(s.e4fil1,1,nil,tp)
end
function s.e4fil2(c)
	return c:IsAbleToGrave()
end
function s.e4tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e4evt(e,tp)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		Duel.BreakEffect()

		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		
		local g=Duel.SelectMatchingCard(tp,s.e4fil2,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
function s.e5con(e)
	return Duel.GetAttacker():IsSetCard(SET_RED_EYES)
end
function s.e5fil1(c,tp)
	return c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e5fil2(c)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsType(TYPE_SYNCHRO)
end
function s.e5tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and s.e5fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e5fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.e5fil2,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	
	local g=Duel.SelectTarget(tp,s.e5fil1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e5lim(e,c)
	return c==e:GetLabelObject()
end
function s.e5evt(e,tp)
	local c=e:GetHandler()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.e5fil2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	local ec=g:GetFirst()

	local tc=Duel.GetFirstTarget()
	if g:GetCount()>0 and tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,ec,true) then
		local e5b=Effect.CreateEffect(c)
		e5b:SetType(EFFECT_TYPE_SINGLE)
		e5b:SetCode(EFFECT_EQUIP_LIMIT)
		e5b:SetReset(RESET_EVENT+RESETS_STANDARD)
		e5b:SetValue(s.e5lim)
		e5b:SetLabelObject(ec)
		tc:RegisterEffect(e5b)
		
		local e5c=Effect.CreateEffect(c)
		e5c:SetType(EFFECT_TYPE_EQUIP)
		e5c:SetCode(EFFECT_UPDATE_ATTACK)
		e5c:SetValue(200)
		e5c:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e5c)
	end
end
function s.e6fil1(c)
	return c:GetEquipTarget()
end
function s.e6fil2(c)
	return c:IsSpellTrap()
end
function s.e6tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.e6fil,1,nil)
	end

	local g=eg:Filter(s.e6fil,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.e6evt(e,tp)
	local g=eg:Filter(s.e6fil,nil)
	local sg=Duel.GetMatchingGroup(s.e6fil2,tp,0,LOCATION_ONFIELD,nil)

	if Duel.Destroy(g,REASON_EFFECT)>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.BreakEffect()
		
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		
		local tg=sg:Select(tp,1,1,nil)
		Duel.HintSelection(tg)
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
function s.e7fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e7tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.e7fil,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.e7evt(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectMatchingCard(tp,s.e7fil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
