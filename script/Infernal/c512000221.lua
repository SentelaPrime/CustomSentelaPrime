--Renacimiento Infernal
--SentelaPrime
local function IsInfernalEyesMonster(c)
    return c:IsSetCard(0x898) and c:IsMonster()
end

--Effect Function
function c512000221.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c512000221.target)
    e1:SetOperation(c512000221.activate)
    c:RegisterEffect(e1)

    --Protection effect: If an "Infernal-Eyes" monster(s) you control would be destroyed or banished from your field by a card effect, you can banish this card from your GY instead
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(c512000221.targ)
    e2:SetValue(c512000221.val)
    e2:SetOperation(c512000221.protectop)
    c:RegisterEffect(e2)
end

function c512000221.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(IsInfernalEyesMonster,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function c512000221.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, IsInfernalEyesMonster, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if g:GetCount() > 0 then
        Duel.SpecialSummon(g, SUMMON_TYPE_SPECIAL, tp, tp, true, true, POS_FACEUP)
    end
end


function c512000221.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x898) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end

function c512000221.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c512000221.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end

function c512000221.val(e,c)
	return c512000221.repfilter(c,e:GetHandlerPlayer())
end

function c512000221.protectop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT)
end