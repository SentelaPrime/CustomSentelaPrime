-- Materia Oscura Definitiva de Ojos Infernales
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Invocación Especial desde el Deck Extra cuando "Materia Oscura de Ojos Infernales" deja el campo
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Unaffected by card effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)

    -- No puede ser usada como material de invocación
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- No puede ser tributada
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_UNRELEASABLE_EFFECT + EFFECT_UNRELEASABLE_NONSUM + EFFECT_UNRELEASABLE_SUM)
    e4:SetValue(1)
    c:RegisterEffect(e4)

    -- Cuando esta carta es invocada, coloca 1 contador en las demás cartas en el campo
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_COUNTER)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetTarget(s.countertg)
    e5:SetOperation(s.counterop)
    c:RegisterEffect(e5)

    -- Esta carta gana ATK y DEF por cada carta con contador
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_UPDATE_ATTACK)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetValue(s.atkval)
    c:RegisterEffect(e6)
    local e7 = e6:Clone()
    e7:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e7)

    -- Cuando esta carta batalla, niega los efectos de otras cartas durante la Damage Step
    local e8 = Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e8:SetCategory(CATEGORY_ATKCHANGE)
    e8:SetOperation(s.battleop)
    c:RegisterEffect(e8)

    -- Prevent leaving field and gain ATK/DEF
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
    e9:SetCode(EFFECT_SEND_REPLACE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetTarget(s.reptg)
    e9:SetOperation(s.repop)
    c:RegisterEffect(e9)
end

local COUNTER_CORRUPTION=0x1038
s.counter_place_list={0x1038}
function s.check(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp or Duel.GetFlagEffect(tp,id)~=0 then return end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

function s.cfilter(c,e,tp,xyz)
	return c:IsCode(512000214) and c:IsPreviousControler(tp)
		and c:IsCanBeXyzMaterial(xyz,tp) and (not e or c:IsRelateToEffect(e))
end

-- Unaffected by card effects
function s.efilter(e,re)
    return e:GetHandler()~=re:GetOwner()
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,nil,tp,e:GetHandler())
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.cfilter,nil,nil,tp,e:GetHandler())
	if chk==0 then
		local c=e:GetHandler()
		local pg=aux.GetMustBeMaterialGroup(tp,g,tp,nil,nil,REASON_XYZ)
		return #pg<=0 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
	end
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) then return end
	local g=eg:Filter(s.cfilter,nil,e,tp,c)
	local pg=aux.GetMustBeMaterialGroup(tp,g,tp,nil,nil,REASON_XYZ)
	if #g>0 and #pg<=0 and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 then
		c:SetMaterial(g)
		Duel.Overlay(c,g)
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		c:CompleteProcedure()
	end
end

-- Negate effects and gain stats during battle
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if not bc then return end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
        tc:RegisterEffect(e1)
    end
    local atk=bc:GetAttack()+Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_DARK):GetSum(Card.GetAttack)
    local def=bc:GetDefense()+Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_DARK):GetSum(Card.GetDefense)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(atk)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetValue(def)
    c:RegisterEffect(e3)
end

-- Place counters and negate effects
function s.countertg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end

function s.counterop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    for tc in aux.Next(g) do
        tc:AddCounter(0x1,1)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        e2:SetValue(ATTRIBUTE_DARK)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

function s.condition(e)
	return e:GetHandler():GetCounter(0x1038)>0
end

-- Gain ATK/DEF for counters
function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(Card.IsHasCounter,c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD,nil,0x1)*1000
end

-- Prevent leaving field and gain ATK/DEF
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    return true
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
    end
end
