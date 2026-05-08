-- Big Bang Dragon Blow
local s,id,o=GetID()
-- c220000062
function s.initial_effect(c)
	-- Must be Special Summoned with "The Claw of Hermos", using a Machine monster.
	c:EnableReviveLimit()

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	--[[
	If this card is Special Summoned:
	Target 1 other face-up monster on the field;
	equip this card to it as an Equip Spell with the following effect.
	]]--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.e1tgt)
	e1:SetOperation(s.e1evt)
	c:RegisterEffect(e1)
end
local RESETS_ON_LEAVE = RESET_EVENT+RESETS_STANDARD
local CARD_THE_CLAW_OF_HERMOS = 46232525
-- Mentions : "The Claw of Hermos"
s.listed_names={CARD_THE_CLAW_OF_HERMOS,id}
-- The Claw of Hermos
s.material_race=RACE_MACHINE
-- Helpers
function s.e1tgt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()

	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
		and chkc:IsFaceup()
		and chkc~=c
	end
	if chk==0 then
		return true
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)

	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
function s.e1evt(e,tp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not tc then return end
	if not c:IsRelateToEffect(e) or c:IsLocation(LOCATION_SZONE) or c:IsFacedown() then return end

	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	
	Duel.Equip(tp,c,tc)
	-- [Equip Limit]
	local e1b1=Effect.CreateEffect(c)
	e1b1:SetType(EFFECT_TYPE_SINGLE)
	e1b1:SetCode(EFFECT_EQUIP_LIMIT)
	e1b1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b1:SetValue(s.eqlim)
	e1b1:SetLabelObject(tc)
	e1b1:SetReset(RESETS_ON_LEAVE)
	c:RegisterEffect(e1b1)
	--[[
	[SOPT]
	Once per turn, when an opponent's monster declares an attack:
	You can Tribute 1 monster, except the equipped monster;
	destroy all monsters your opponent controls,
	then if you Tributed a Dragon monster to activate this effect,
	inflict damage to your opponent equal to the combined original ATK of the destroyed monsters.
	]]--
	local e1b2=Effect.CreateEffect(c)
	e1b2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1b2:SetRange(LOCATION_SZONE)
	e1b2:SetCountLimit(1)
	e1b2:SetCondition(s.e1b2con)
	e1b2:SetCost(s.e1b2cst)
	e1b2:SetTarget(s.e1b2tgt)
	e1b2:SetOperation(s.e1b2evt)
	e1b2:SetReset(RESETS_ON_LEAVE)
	c:RegisterEffect(e1b2)
end
function s.eqlim(e,c)
	return c==e:GetLabelObject()
end
function s.e1b2con(e,tp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.e1b2fil1(c,ec)
	return c:IsMonster()
	and c:IsReleasable()
	and c~=ec:GetEquipTarget()
end
function s.e1b2cst(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()

	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.e1b2fil1,1,false,nil,nil,c)
	end
	
	local sg=Duel.SelectReleaseGroupCost(tp,s.e1b2fil1,1,1,false,nil,nil,c)

	e:SetLabel(sg:GetFirst():GetRace())
	
	Duel.Release(sg,REASON_COST)
end
function s.e1b2tgt(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	end
	
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.e1b2evt(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsRelateToBattle() and at:IsControler(1-tp) then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)

		if e:GetLabel()==RACE_DRAGON then
			Duel.BreakEffect()

			local dmg=0
			for tc in g:Iter() do
				if not tc:IsLocation(LOCATION_MZONE) then
					dmg=dmg+tc:GetBaseAttack()
				end
			end

			Duel.Damage(1-tp,dmg,REASON_EFFECT)
		end
	end
end
