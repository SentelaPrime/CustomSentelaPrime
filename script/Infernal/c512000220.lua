--Revelacion de los Ojos Infernales
--SentelaPrime

local function IsInfernalEyesMonster(c)
    return c:IsSetCard(0x898) and c:IsMonster()
end

--Effect Function
function c512000220.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c512000220.target)
    e1:SetOperation(c512000220.activate)
    c:RegisterEffect(e1)
end

function c512000220.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(IsInfernalEyesMonster,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end

function c512000220.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, IsInfernalEyesMonster, tp, LOCATION_DECK, 0, 1, 1, nil)
    if g:GetCount() > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        if Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0)==0 and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 then
            if Duel.SelectYesNo(tp, aux.Stringid(512000220, 0), 2) then
                Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
            end    
        end
    end
end