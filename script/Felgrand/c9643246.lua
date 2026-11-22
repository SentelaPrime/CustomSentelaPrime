--Dragón Arcavaliente del Alma Felgrand
local s,id=GetID()

function s.initial_effect(c)
    --Effect 1: Quick Effect from hand
    --Send 1 Dragon with 2800 ATK/DEF from Deck to GY,
    --then Special Summon this card from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1)
    e1:SetRange(LOCATION_HAND)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --Effect 2: When Special Summoned, banish up to 3
    --Spells/Traps your opponent controls and gain 200 ATK for each
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    --Effect 3: During either player's Standby Phase,
    --if this card was sent to the GY during the previous turn,
    --Special Summon up to 2 Level 7/8 Dragons from your GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(s.sp2con)
    e3:SetTarget(s.sp2tg)
    e3:SetOperation(s.sp2op)
    c:RegisterEffect(e3)

    --Register when this card is sent to the GY
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetOperation(s.regop)
    c:RegisterEffect(e4)
end

function s.tgfilter(c)
    return c:IsRace(RACE_DRAGON)
        and c:GetAttack()==2800
        and c:GetDefense()==2800
        and c:IsAbleToGrave()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingMatchingCard(
                s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_HAND) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)

    if #g==0 then return end

    if Duel.SendtoGrave(g,REASON_EFFECT)>0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsRelateToEffect(e)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
function s.rmfilter(c)
    return c:IsSpellTrap()
        and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(
        s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,math.min(3,#g),nil)
    local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)

    if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct*200)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(
        id,RESETS_STANDARD_PHASE_END,0,2)
end

function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetTurnID()~=Duel.GetTurnCount()
        and c:GetFlagEffect(id)>0
end

function s.sp2filter(c,e,tp)
    return (c:IsLevel(7) or c:IsLevel(8))
        and c:IsRace(RACE_DRAGON)
        and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(tp)
            and chkc:IsLocation(LOCATION_GRAVE)
            and s.sp2filter(chkc,e,tp)
    end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(
                s.sp2filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(
        tp,s.sp2filter,tp,LOCATION_GRAVE,0,1,2,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
end

function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g==0 then return end

    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end

    local sg=Group.CreateGroup()
    for tc in aux.Next(g) do
        if tc:IsRelateToEffect(e)
            and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
            sg:AddCard(tc)
        end
    end

    if #sg>0 then
        Duel.SpecialSummon(
            sg:Select(tp,1,math.min(ft,#sg),nil),
            0,tp,tp,false,false,POS_FACEUP)
    end
end
