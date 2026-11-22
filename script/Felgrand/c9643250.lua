
--Profeta de la Creacion Felgrand
local s,id=GetID()

function s.initial_effect(c)
    --Special Summon itself from hand by revealing a Felgrand Dragon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --If Special Summoned by its own effect: add 1 Felgrand Warrior
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    --Banish this card from GY: add a Dragon Lords/Felgrand Spell
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+2)
    e3:SetCost(s.gycost)
    e3:SetTarget(s.gytg)
    e3:SetOperation(s.gyop)
    c:RegisterEffect(e3)
end

s.listed_card={3954901,60681103,6075801,33460840,65187687,1639384,
    6853254,69868555,9643249}
s.listed_series={0x12FD}

--------------------------------------------------
-- FELGRAND IDENTIFICATION
--------------------------------------------------

function s.isfelgrand(c)
    return c:IsSetCard(0x12FD)
        or c:IsCode(3954901,60681103,6075801,33460840,65187687,1639384)
end

--------------------------------------------------
-- EFFECT 1: SPECIAL SUMMON ITSELF FROM HAND
--------------------------------------------------

function s.revealfilter(c)
    return s.isfelgrand(c)
        and c:IsRace(RACE_DRAGON)
        and (c:IsLevel(7) or c:IsLevel(8))
        and c:IsAbleToGrave()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(
                s.revealfilter,tp,LOCATION_HAND,0,1,e:GetHandler())
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(
        tp,s.revealfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())

    e:SetLabelObject(g:GetFirst())
    Duel.ConfirmCards(1-tp,g)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end

    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=e:GetLabelObject()

    if not tc or not tc:IsLocation(LOCATION_HAND) then return end
    if not c:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
        if tc:IsLocation(LOCATION_HAND) then
            Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
        end
    end
end

--------------------------------------------------
-- EFFECT 2: ADD FELGRAND WARRIOR
--------------------------------------------------

function s.warfilter(c)
    return s.isfelgrand(c)
        and c:IsRace(RACE_WARRIOR)
        and c:IsAbleToHand()
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL
        and e:GetHandler():GetReasonEffect()~=nil
        and e:GetHandler():GetReasonEffect():GetHandler()==e:GetHandler()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.warfilter,tp,LOCATION_DECK,0,1,nil)
    end

    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.warfilter,tp,LOCATION_DECK,0,1,1,nil)

    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--------------------------------------------------
-- EFFECT 3: BANISH ITSELF FROM GY
-- ADD A DRAGON LORDS / FELGRAND SPELL
--------------------------------------------------

function s.spellfilter(c)
    return c:IsType(TYPE_SPELL)
        and (c:IsSetCard(0x12FD)
            or c:IsCode(6853254,69868555,9643249))
        and c:IsAbleToHand()
end

function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()

    if chk==0 then
        return c:IsAbleToRemoveAsCost()
    end

    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.spellfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end

    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,
        LOCATION_DECK+LOCATION_GRAVE)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.spellfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)

    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
