-- Rise from Ashes
local s,id,o=GetID()
-- c220000044
function s.initial_effect(c)
	--[[
	When a “Red-Eyes” monster is destroyed by battle and sent to the GY:
	Special Summon the destroyed monster to your field in the same position it was in when it was destroyed,
	then equip the monster that destroyed it to the Summoned monster as an Equip Spell with the following effects.
	•
	The equipped monster gains 800 ATK/DEF.
	•
	If the equipped monster would be destroyed by battle or card effect, destroy this card instead.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this Set card is sent from the field to the GY: You can banish this card from your GY; draw 2 cards.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.e2con)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
-- Archetype : N/A
s.listed_series={0xfe1}
-- Helpers
function s.e1fil(c,e,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsMonster()
	and c:IsLocation(LOCATION_GRAVE)
	and c:IsReason(REASON_BATTLE)
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false,c:GetPreviousPosition(),tp)
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(s.e1fil,1,nil,e,tp)
	end

	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
end
function s.e1lim(e,c)
	return c==e:GetLabelObject()
end
function s.e1val(e,re,r,rp)
	return (r&REASTON_EFFECT+REASON_BATTLE)~=0
end
function s.e1evt(e,tp,eg)
	local g=eg:FilterSelect(tp,s.e1fil,1,1,nil,e,tp)
	local sc=g:GetFirst()

	if Duel.SpecialSummon(sc,0,tp,tp,false,false,sc:GetPreviousPosition())>0 then
		Duel.BreakEffect()

		local ec=Duel.GetAttacker()
		if sc==ec then ec=Duel.GetAttackTarget() end
		if not ec:IsRelateToBattle() then return end

		local c=e:GetHandler()

		if Duel.Equip(tp,ec,sc,true) then
			local e1b=Effect.CreateEffect(c)
			e1b:SetType(EFFECT_TYPE_SINGLE)
			e1b:SetCode(EFFECT_EQUIP_LIMIT)
			e1b:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1b:SetValue(s.e1lim)
			e1b:SetLabelObject(sc)
			ec:RegisterEffect(e1b)

			local e1c=Effect.CreateEffect(c)
			e1c:SetType(EFFECT_TYPE_EQUIP)
			e1c:SetCode(EFFECT_UPDATE_ATTACK)
			e1c:SetValue(800)
			e1c:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1c)

			local e1d=e1c:Clone()
			e1d:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e1d)

			local e1e=Effect.CreateEffect(c)
			e1e:SetType(EFFECT_TYPE_EQUIP)
			e1e:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1e:SetCode(EFFECT_DESTROY_SUBSTITUTE)
			e1e:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1e:SetValue(s.e1val)
			ec:RegisterEffect(e1e)
		end
	end
end
function s.e2con(e,tp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,2)
	end

	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.e2evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
