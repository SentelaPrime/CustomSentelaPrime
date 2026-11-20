--Final Boss
--Hecho por Primas
local s,id=GetID()
function s.initial_effect(c)
    aux.EnableExtraRules(c,s,s.ruleop)
end

function s.ruleop(c)

    --Al inicio del duelo, coloca en tu campo un monstruo desde fuera del duelo
   local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS) 
    e1:SetCode(EVENT_PREDRAW)
    e1:SetOperation(s.finalboss)
    Duel.RegisterEffect(e1,0)

end

function s.finalboss(e,tp,eg,ep,ev,re,r,rp)
    -- Solo una vez
    if Duel.GetFlagEffect(0,id)~=0 then return end
    Duel.RegisterFlagEffect(0,id,0,0,0)

    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp, HINTMSG_CODE)
        s.announce_filter={TYPE_MONSTER,OPCODE_ISTYPE}
            local token_id = Duel.AnnounceCard(tp, s.announce_filter)
            local token = Duel.CreateToken(tp,token_id)
            Duel.SpecialSummonStep(token,0,tp,tp,true,true,POS_FACEUP)
        Duel.SpecialSummonComplete()
    end

end

