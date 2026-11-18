--Dragón de Materia Oscura de Ojos Infernales
local s, id = GetID()

function s.initial_effect(c)
    -- Xyz Summon condition
    Xyz.AddProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats)

	--Unafected if this card have Infernal-Eyes Dark Matter as material
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.immunecon)
	e1:SetValue(s.immuneval)
	c:RegisterEffect(e1)
    -- Gain ATK equal to the materials attached
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Halve damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(s.rdcon)
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- Attach card
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(aux.bdocon)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
	--You opponent cant activate card or effect if this cards battle if this card have Infernal-Eyes Dragon as material
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(0,1)
	e5:SetCondition(s.accon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
end

s.infernal_list={512000219, 512000214}
--Infernal-Eyes Dragon=512000219
--Infernal-Eyes Dark Matter=512000214

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,512000214)
end
function s.immunecon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,512000214)
end

function s.immuneval(e, te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.atkval(e, c)
    local tp = e:GetHandlerPlayer()
    local g = c:GetOverlayGroup()
    local atk = 0
    local tc = g:GetFirst()
    while tc do
        atk = atk + tc:GetAttack()
        tc = g:GetNext()
    end
    return atk
end
function s.rdcon(e)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,512000214)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	if e:GetCode()==EVENT_TO_GRAVE then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
	end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=tg:FilterSelect(tp,1,1,nil)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end



function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsType(TYPE_XYZ) and bc:IsMonster() and bc:IsFaceup()
		and bc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
	Duel.SetTargetCard(bc)
	if bc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,bc,1,tp,0)
	end
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	local bc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) and bc:IsRelateToEffect(e)
		and bc:IsMonster() and bc:IsFaceup() then
		Duel.Overlay(c,bc,true)
	end
end



function s.accon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,512000219) and Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end


