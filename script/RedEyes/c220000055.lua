-- Red-Eyes Zombie Swordsman
local s,id,o=GetID()
-- c220000055
function s.initial_effect(c)
	--[[
	While you control a Zombie Synchro Monster, you choose the attack targets for your opponent's attacks.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.e1con)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	If this card is in your hand:
	You can target 1 monster that mentions "Zombie World" in your GY or banishment, except a Level 5 monster;
	Special Summon both this card and that monster, ignoring their Summoning conditions, in face-up Defense Position,
	but for each one, as long as it remains face-up in the Monster Zone, you cannot Special Summon, except Zombie monsters.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If a Dragon or Zombie monster(s) is Tributed, or banished face-up, from your face-up field or GY,
	while this card is in your GY (except during the Damage Step):
	You can add this card to your hand.
	]]--
	local e3a1=Effect.CreateEffect(c)
	e3a1:SetDescription(aux.Stringid(id,2))
	e3a1:SetCategory(CATEGORY_TOHAND)
	e3a1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3a1:SetCode(EVENT_RELEASE)
	e3a1:SetRange(LOCATION_GRAVE)
	e3a1:SetLabel(0)
	e3a1:SetCountLimit(1,{id,1})
	e3a1:SetCondition(s.e3con)
	e3a1:SetTarget(s.e3tgt)
	e3a1:SetOperation(s.e3evt)
	c:RegisterEffect(e3a1)
	
	local e3a2=e3a1:Clone()
	e3a2:SetCode(EVENT_REMOVE)
	e3a2:SetLabel(1)
	c:RegisterEffect(e3a2)
end
-- Mentions : "Zombie World"
s.listed_names={4064256,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES}
-- Helpers
function s.e1fil(c)
	return c:IsFaceup()
	and c:IsRace(RACE_ZOMBIE)
	and c:IsType(TYPE_SYNCHRO)
end
function s.e1con(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.e1fil,tp,LOCATION_MZONE,0,1,nil)
end
function s.e2fil(c,e,tp)
	return c:IsMonster()
	and not c:IsLevel(5)
	and (c:IsSetCard(0xfe3)
		or c:IsCode(4064256)
		or c:IsCode(32485518)
		or c:IsCode(92964816)
		or c:IsCode(66570171))
	and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE)
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and Duel.IsExistingTarget(s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)

	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g+c,2,tp,0)
end
function s.e2evt(e,tp)
	local c=e:GetHandler()

	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and s.e2fil(tc, e,tp) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE) then
		local sg=Group.CreateGroup()
		sg:AddCard(c)
		sg:AddCard(tc)

		if Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP_DEFENSE)>0 then
			for sc in sg:Iter() do
				sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
				
				local e2b1=Effect.CreateEffect(c)
				e2b1:SetType(EFFECT_TYPE_FIELD)
				e2b1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
				e2b1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e2b1:SetRange(LOCATION_MZONE)
				e2b1:SetAbsoluteRange(tp,1,0)
				e2b1:SetCondition(function(e) return e:GetHandler():IsControler(e:GetOwnerPlayer()) end)
				e2b1:SetTarget(function(e,c) return not c:IsRace(RACE_ZOMBIE) end)
				e2b1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2b1,true)
			end
		end
	end
end
function s.e3fil(c,label)
	if label==1 and c:IsFacedown() then return false end

	if c:IsPreviousLocation(LOCATION_MZONE) then
		return (c:GetPreviousPosition()&POS_FACEUP>0)
		and (c:GetPreviousRaceOnField()&RACE_DRAGON>0 or c:GetPreviousRaceOnField()&RACE_ZOMBIE>0)
	elseif c:IsPreviousLocation(LOCATION_GRAVE) then
		return c:IsMonster()
		and (c:IsOriginalRace(RACE_DRAGON) or c:IsOriginalRace(RACE_ZOMBIE))
	end
	return false
end
function s.e3con(e,tp,eg)
	return eg:IsExists(s.e3fil,1,nil,e:GetLabel())
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return c:IsAbleToHand()
	end

	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.e3evt(e,tp)
	local c=e:GetHandler()

	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
