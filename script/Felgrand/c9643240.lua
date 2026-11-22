
--Felgrand Warrior
local s,id=GetID()

function s.initial_effect(c)
    --Effect 1: Reveal this card in hand;
    --add 1 Felgrand Warrior from Deck to hand,
    --then return 1 card from hand to Deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --Effect 2: If Special Summoned from the GY,
    --banish 1 card your opponent controls or in their GY
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.rmcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    --Effect 3: Once per turn, when your opponent activates
    --a Spell/Trap or its effect, negate that effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    --Effect 4: If this card destroys a monster by battle,
    --Special Summon that monster to your field
    --and gain ATK equal to its ATK
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

s.listed_card={
    3954901,60681103,6075801,33460840,65187687,1639384
}
s.listed_series={0x12FD}

--Felgrand filter
function s.isfelgrand(c)
    return c:IsSetCard(0x12FD)
        or c:IsCode(3954901,60681103,6075801,33460840,65187687,1639384)
end

--Effect 1: Search
function s.thfilter(c)
    return s.isfelgrand(c)
        and c:IsRace(RACE_WARRIOR)
        and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    Duel.ConfirmCards(1-tp,Group.FromCards(c))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(
        0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(
        tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)

    if #g==0 then return end

    if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)

        --Return 1 card from your hand to the Deck
        if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local sg=Duel.SelectMatchingCard(
                tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
            if #sg>0 then
                Duel.SendtoDeck(
                    sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
            end
        end
    end
end

--Effect 2: Banish opponent's card
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end

function s.rmfilter(c)
    return c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
    end
    Duel.SetOperationInfo(
        0,CATEGORY_REMOVE,nil,1,1-tp,
        LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(
        s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)

    if #g==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,1,nil)
    Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end

--Effect 3: Negate opponent's Spell/Trap effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp
        and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsChainNegatable(ev)
    end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
end

--Effect 4: Special Summon the monster destroyed by battle
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttackTarget()
    return Duel.GetAttacker()==c
        and tc~=nil
        and tc:IsReason(REASON_BATTLE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tc=Duel.GetAttackTarget()
    if chk==0 then
        return tc~=nil
            and tc:IsLocation(LOCATION_GRAVE)
            and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(
        0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttackTarget()

    if not tc or not tc:IsLocation(LOCATION_GRAVE) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end

    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
        local atk=tc:GetAttack()

        if atk>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end
