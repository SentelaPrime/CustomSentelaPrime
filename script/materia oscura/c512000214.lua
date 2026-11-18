--Infernal-Eyes Dark Matter
local s, id = GetID()

function s.initial_effect(c)
    --Unaffected by other card effects except Attribute Light cards
    local e1 = Effect.CreateEffect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.efilter)
    c:RegisterEffect(e1)

    --Gain ATK and DEF when battling
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_CONFIRM)
    e2:SetCondition(s.atkdef_condition)
    e2:SetCost(s.atkdef_cost)
    e2:SetOperation(s.atkdef_operation)
    c:RegisterEffect(e2)
end

function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and not te:GetHandler():IsAttribute(ATTRIBUTE_LIGHT)
end

function s.atkdef_condition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetAttacker()
    local bc = c:GetBattleTarget()
    if not bc then return false end
    if tc == c then tc = bc end
    e:SetLabelObject(tc)
    return tc and tc:IsControler(1 - c:GetControler()) and tc:IsRelateToBattle()
end

function s.atkdef_cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, Card.IsAbleToGrave, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_COST)
    end
end

function s.atkdef_operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    local atk = tc:GetAttack()
    local def = tc:GetDefense()
    if atk < 0 then atk = 100 end
    if def < 0 then def = 100 end
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(def)
    c:RegisterEffect(e2)
end
