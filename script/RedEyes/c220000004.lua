-- Flame Swordsman, the Red-Eyes Black Dragon Master
local s,id,o=GetID()
-- c220000004
function s.initial_effect(c)
	-- 1 Level 7 “Red-Eyes” monster + 1 “Flame Swordsman” monster
	Fusion.AddProcMix(c,true,true,s.m1fil,s.m2fil)
	c:EnableReviveLimit()
	-- This card’s name becomes “Flame Swordsman” while on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(CARD_FLAME_SWORDSMAN)
	c:RegisterEffect(e1)
	--[[
	[HOPT]
	You can target 1 Level 7 or lower Dragon monster in your GY;
	equip it to this card as an Equip Spell that gives this card ATK equal to that monster’s original ATK.
	]]--
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.e2tgt)
	e2:SetOperation(s.e2evt)
	c:RegisterEffect(e2)
	--[[
	[HOPT]
	If this card is destroyed by battle or card effect and sent to the GY: Inflict 1000 damage to your opponent,
	and if you do, you can return 1 other Fusion Monster from your GY to the Extra Deck,
	and if you do that, you can Special Summon 1 Level 7 or lower “Red-Eyes” monster, or 1 Level 4 Warrior monster, from your Deck or GY.
	]]--
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.e3con)
	e3:SetTarget(s.e3tgt)
	e3:SetOperation(s.e3evt)
	c:RegisterEffect(e3)
end
-- Mentions : "Flame Swordsman"
s.listed_names={CARD_FLAME_SWORDSMAN,id}
-- Archetype : Red-Eyes
s.listed_series={SET_RED_EYES,0xfe2}
-- Red-Eyes Fusion
s.material_setcode=SET_RED_EYES
-- Helpers
function s.m1fil(c,fc,sumtype,tp)
	return c:IsSetCard(SET_RED_EYES)
	and c:IsLevel(7)
end
function s.m2fil(c,fc,sumtype,tp)
	-- "Flame Swordsman" monsters
	return (c:IsSetCard(0xfe2)
	or c:IsCode(45231177)
	or c:IsCode(73936388)
	or c:IsCode(27704731)
	or c:IsCode(1047075)
	or c:IsCode(50903514)
	or c:IsCode(324483)
	or c:IsCode(98642179))
end
function s.e2fil(c,tp)
	return c:IsRace(RACE_DRAGON)
	and c:IsLevelBelow(7)
	and c:CheckUniqueOnField(tp)
	and c:IsMonster()
	and not c:IsForbidden()
end
function s.e2tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_GRAVE)
		and chkc:IsControler(tp)
		and s.e2fil(chkc,tp)
	end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.e2fil,tp,LOCATION_GRAVE,0,1,nil,tp)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.e2fil,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.e2lim(e,c)
	return c==e:GetLabelObject()
end
function s.e2evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Equip(tp,tc,c,true) then
		local e2a=Effect.CreateEffect(c)
		e2a:SetType(EFFECT_TYPE_SINGLE)
		e2a:SetCode(EFFECT_EQUIP_LIMIT)
		e2a:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2a:SetValue(s.e2lim)
		e2a:SetLabelObject(c)
		tc:RegisterEffect(e2a)
		-- Gain ATK
		local e2b=Effect.CreateEffect(c)
		e2b:SetType(EFFECT_TYPE_EQUIP)
		e2b:SetCode(EFFECT_UPDATE_ATTACK)
		e2b:SetValue(tc:GetBaseAttack())
		e2b:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2b)
	end
end
function s.e3con(e)
	local c=e:GetHandler()

	return c:IsReason(REASON_DESTROY)
	and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.e3tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end

	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.e3afil(c)
	return c:IsType(TYPE_FUSION)
	and c:IsAbleToExtra()
end
function s.e3bfil(c,e,tp)
	return (c:IsSetCard(SET_RED_EYES)
	and c:IsLevelBelow(7))
	or (c:IsRace(RACE_WARRIOR)
	and c:IsLevel(4))
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.e3evt(e,tp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if Duel.IsExistingMatchingCard(s.e3afil,tp,LOCATION_GRAVE,0,1,c) then
			if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
				local g1=Duel.SelectMatchingCard(tp,s.e3afil,tp,LOCATION_GRAVE,0,1,1,c)
				if g1:GetCount()>0 then
					if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
						if Duel.IsExistingMatchingCard(s.e3bfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then
							if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,2)) then
								Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
								local g2=Duel.SelectMatchingCard(tp,s.e3bfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
								if g2:GetCount()>0 then
									local tc=g2:GetFirst()
									Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
								end
							end
						end
					end
				end
			end
		end
	end
end
