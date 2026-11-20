--Duelo Epico/Anime
--Hecho por Primas
local s,id=GetID()
function s.initial_effect(c)
    aux.EnableExtraRules(c,s,s.ruleop)
end

function s.ruleop(c)


    --Antes de tu robo normal, puedes colocar 1 carta de tu deck en la parte superior de tu deck.
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
    e1:SetCode(EVENT_PREDRAW)
    e1:SetOperation(s.predraw_op)
    Duel.RegisterEffect(e1,0)
    local e2=e1:Clone() 
    Duel.RegisterEffect(e2,1)

    --Si fueras a robar puedes colocar 1 carta de tu deck en la parte superior de tu deck.
    local e7=e1:Clone()
    e7:SetCode(EVENT_CHAINING)
    e7:SetCondition(s.robar)
    Duel.RegisterEffect(e7,0)
    local e8=e7:Clone()
    Duel.RegisterEffect(e8,1)

    --Al inicio del turno, antes de robar, coloca una carta desde fuera del deck al tope del mazo
   local e3=Effect.CreateEffect(c)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
    e3:SetCode(EVENT_PREDRAW)
    e3:SetOperation(s.destinyepico)
    Duel.RegisterEffect(e3,0)
    local e4=e3:Clone() 
    Duel.RegisterEffect(e4,1)

    --AÑade una carta a tu extra deck desde fuera del duelo
    local e5=Effect.CreateEffect(c)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_FREE_CHAIN) 
    e5:SetOperation(s.lepregunteamis)
    Duel.RegisterEffect(e5,0)
    local e6=e5:Clone() 
    Duel.RegisterEffect(e6,1)

end



function s.predraw_op(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local dg=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
		if #dg<=1 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local bg=dg:Select(tp,1,1,nil)
		Duel.MoveToDeckTop(bg)
    end
end

function s.robar(e,tp,eg,ep,ev,re,r,rp)
    if re:IsHasCategory(CATEGORY_DRAW) then return true end

end

function s.destinyepico(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return end
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_CODE)
        s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
            local token_id = Duel.AnnounceCard(tp, s.announce_filter)
            local token = Duel.CreateToken(tp,token_id)
            Duel.SendtoDeck(token,tp,SEQ_DECKTOP,REASON_RULE)
    end
end

function s.lepregunteamis(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_CODE)
            local token_id = Duel.AnnounceCard(tp, TYPE_EXTRA)
            local token = Duel.CreateToken(tp,token_id)
            Duel.SendtoDeck(token,tp,SEQ_DECKTOP,REASON_RULE)
    end
end