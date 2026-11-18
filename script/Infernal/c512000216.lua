--Infernal-Eyes Blaze Dragon
--Author:SentelaPrime

local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, 512000219,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON)) -- "Infernal-Eyes Dragon" + 1 Dragon-Type monster

    -- When this card is Fusion Summoned, you can send 1 Dragon-Type monster from your Deck to the GY.
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.tgtg)
    e1:SetCondition(s.spconx)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- This card gains 200 ATK for every Dragon in your GY.
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- If this card is sent to the GY, you can Special Summon 1 Dragon-Type monster from your GY, ignoring its Summoning Conditions.
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

s.material_setcode=0x898

function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_DECK, 0, 1, nil, TYPE_MONSTER) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.spconx(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, Card.IsRace, tp, LOCATION_DECK, 0, 1, 1, nil, RACE_DRAGON)
    if g:GetCount() > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(Card.IsRace, c:GetControler(), LOCATION_GRAVE, 0, nil, RACE_DRAGON) * 200
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return bit.band(r, REASON_EFFECT + REASON_BATTLE) ~= 0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spfilter(c, e, tp)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if g:GetCount() > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end