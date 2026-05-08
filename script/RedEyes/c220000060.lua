-- Rampage of Hermos
local s,id,o=GetID()
-- c220000060
function s.initial_effect(c)
	-- [Activation]
	--[[
	[H1PT]
	Reveal 1 Fusion Monster in your Extra Deck that mentions "The Claw of Hermos";
	send 1 other Monster Card from your hand, field, or Extra Deck to the GY
	with the same Type as the revealed monster (if that card is Set, reveal it),
	and if you do, Special Summon the revealed monster.
	(This is treated as a Fusion Summon by the effect of "The Claw of Hermos".)
	If this effect was activated during the Battle Phase,
	your opponent cannot activate cards or effects when a monster is Special Summoned this way.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.Reveal(s.e1fil1,false,1,1,s.e1cst,LOCATION_EXTRA))
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
	--[[
	[H1PT]
	During your Main Phase:
	You can banish this card from your GY,
	then target 1 face-up monster your opponent controls equipped with a Fusion Monster Card(s) in your Spell & Trap Zone;
	take control of that target,
	but unless you controlled "Red-Eyes Black Dragon" when this effect was activated,
	negate its effects, also it cannot attack directly.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.e2con)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
end
local RESETS_ON_LEAVE = RESET_EVENT+RESETS_STANDARD
local RESETS_END_PHASE = RESET_PHASE+PHASE_END
local CARD_THE_CLAW_OF_HERMOS = 46232525
-- Mentions : "The Claw of Hermos","Red-Eyes Black Dragon"
s.listed_names={CARD_THE_CLAW_OF_HERMOS,CARD_REDEYES_B_DRAGON,id}
-- Helpers
function s.e1fil1(c)
	return c:IsType(TYPE_FUSION)
	and c:IsMonster()
	and c:ListsCode(CARD_THE_CLAW_OF_HERMOS)
end
function s.e1cst(e,tp,rg)
	local rc=rg:GetFirst()
	e:SetLabelObject(rc)
	rc:CreateEffectRelation(e)
end
function s.e1fil2(c,e)
	return c:IsMonsterCard()
	and c:IsRace(e:GetLabelObject():GetRace())
	and c:IsAbleToGrave()
end
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	local rc=e:GetLabelObject()
	if not rc then return end
	
	if chk==0 then
		return s.e1fil1(rc)
		and rc:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and ((Duel.IsExistingMatchingCard(s.e1fil2,tp,LOCATION_MZONE,0,1,rc,e))
		or (Duel.IsExistingMatchingCard(s.e1fil2,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_EXTRA,0,1,rc,e)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
	end
	
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,rc,1,0,0)
end
function s.e1evt(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	local rc=e:GetLabelObject()

	if not rc then return end

	local zn=LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
		zn=LOCATION_MZONE
	end

	local g=Duel.SelectMatchingCard(tp,s.e1fil2,tp,zn,0,1,1,rc,e)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		if tc:IsOnField() and tc:IsFacedown() then
			Duel.ConfirmCards(1-tp,tc)
		end

		Duel.SendtoGrave(tc,REASON_EFFECT)

		if tc:IsLocation(LOCATION_GRAVE) then
			if Duel.SpecialSummon(rc,0,tp,tp,true,false,POS_FACEUP)>0 then
				local e1b1=Effect.CreateEffect(c)
				e1b1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1b1:SetCode(EVENT_CHAIN_END)
				e1b1:SetCondition(s.e1b1con)
				e1b1:SetOperation(function(e)
					Duel.SetChainLimitTillChainEnd(function(e,rp,tp) return tp==rp end)
					e:Reset()
				end)
				e1b1:SetReset(RESETS_END_PHASE)
				Duel.RegisterEffect(e1b1,tp)
			end
		end
	end
end
function s.e1b1con(e)
	return Duel.IsBattlePhase()
end
function s.e2fil1(c,e,tp)
	return c:IsFaceup()
	and c:IsMonster()
	and c:IsControler(1-tp)
	and c:GetEquipGroup():IsExists(s.e2fil2,1,nil,tp)
	and c:IsControlerCanBeChanged()
end
function s.e2fil2(c,tp)
	return c:IsOriginalType(TYPE_FUSION)
	and c:IsMonsterCard()
	and c:IsControler(tp)
	and c:IsLocation(LOCATION_SZONE)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and s.e2fil1(chkc)
	end
	if chk==0 then
		return Duel.IsExistingTarget(s.e2fil1,tp,0,LOCATION_MZONE,1,nil,e,tp)
	end

	e:SetLabel(Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REDEYES_B_DRAGON),tp,LOCATION_MZONE,0,1,nil))
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)

	local g=Duel.SelectTarget(tp,s.e2fil1,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.e2evt(e,tp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)

		if e:GetLabel() then return end

		local e2b1=Effect.CreateEffect(c)
		e2b1:SetType(EFFECT_TYPE_SINGLE)
		e2b1:SetCode(EFFECT_DISABLE)
		e2b1:SetReset(RESETS_ON_LEAVE)
		tc:RegisterEffect(e2b1)

		local e2b2=e2b1:Clone()
		e2b2:SetCode(EFFECT_DISABLE_EFFECT)
		tc:RegisterEffect(e2b2)

		local e2b3=Effect.CreateEffect(c)
		e2b3:SetDescription(3207)
		e2b3:SetType(EFFECT_TYPE_SINGLE)
		e2b3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e2b3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2b3:SetReset(RESETS_ON_LEAVE)
		tc:RegisterEffect(e2b3)
	end
end
