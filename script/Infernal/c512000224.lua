--Regalo Infernal
--SentelaPrime

--Effect Function
function c512000224.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(c512000224.target)
    e1:SetOperation(c512000224.activate)
    c:RegisterEffect(e1)
end

function c512000224.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, PLAYER_ALL, 5)
end

function c512000224.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp, 5, REASON_EFFECT)
    Duel.Draw(1-tp, 5, REASON_EFFECT)
end