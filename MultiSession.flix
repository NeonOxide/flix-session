
mod MultiSession{
    use IxMonad.ixreturn
// Import necessary libraries
use SesChans.recv_transformer
use SesChans.helper_boxer
use Channel.send
import java.lang.Object 
/**
 * Channel types for session communication
 */
// Raw untyped session channel using Object for type erasure and reducing the 
// number of required channels (by using one "untyped" channel we can reuse it 
// for all communication instead of needing one channel per type) The _t is the tag
enum MultiSessionChannel[_t](Sender[Object], Receiver[Object])

// Capabilities with tag t, environment e, and session type r
enum _Cap[_tag, _env, _session_type]

enum MultiSession[_startState: Type, _endState: Type, resultType: Type, effects: Eff]
(Unit -> resultType \ effects)

pub def multisession_send(chan: MultiSessionChannel[t], elem: a) : 
    MultiSession[(_Cap[ t, e, Send[a, r]], x), (_Cap[t, e, r], x), Unit, Chan] = 
    MultiSession.MultiSession(_ -> 
        let MultiSessionChannel.MultiSessionChannel(send, _recv) = chan;
        Channel.send(
            helper_boxer(elem)
            , send)
        )

pub def multisession_recv(chan: MultiSessionChannel[t]) : 
    MultiSession[(_Cap[ t, e, Receive[a, r]], x), (_Cap[t, e, r], x), a, Chan + NonDet] = 
    MultiSession.MultiSession(_ -> 
        let MultiSessionChannel.MultiSessionChannel(_send, recv) = chan;
        recv_transformer(Channel.recv(recv), Proxy.Proxy))

/**
 * Close a session channel, terminating the protocol
 */
pub def multisession_close(_chan: MultiSessionChannel[t]) : 
    MultiSession[(_Cap[t, _env, Empty], x), x, Unit, _effect] = 
    MultiSession.MultiSession(_ -> checked_ecast(()))

pub def multi_sel_1(chan: MultiSessionChannel[t]): 
    MultiSession[(_Cap[t, _env, ChoiceSelection2[protocol1, protocol2]], x), (_Cap[t, _env, protocol1], x), Unit, _effect + Chan] = 
    MultiSession.MultiSession(_ -> 
        let MultiSessionChannel.MultiSessionChannel(send, _recv) = chan;
        checked_ecast(
            Channel.send(1i8 |> toObject, send)
        )
    )

pub def multi_sel_2(chan: MultiSessionChannel[t]): 
    MultiSession[(_Cap[t, _env, ChoiceSelection2[protocol1, protocol2]], x), (_Cap[t, _env, protocol2], x), Unit, _effect + Chan] = 
    MultiSession.MultiSession(_ -> 
        let MultiSessionChannel.MultiSessionChannel(send, _recv) = chan;
        checked_ecast(
            Channel.send(2i8 |> toObject, send)
        )
    )

/**
 * Handle an offered choice by providing handlers for all 2 possible branches
 */
pub def multisession_offer (
   chan: MultiSessionChannel[t], 
   option1: {option1 = MultiSession[(_Cap[t, _env, protocol1], x), endState, resultType, effects1]},
   option2: {option2 = MultiSession[(_Cap[t, _env, protocol2], x), endState, resultType, effects2]}  
) : MultiSession[(_Cap[t, _env, ChoiceOffer2[protocol1, protocol2]], x), endState, resultType, effects1 + effects2 + Chan + NonDet] = 
    MultiSession.MultiSession(_ ->
        let MultiSessionChannel.MultiSessionChannel(_send, recv) = chan;
        let choice = Channel.recv(recv) |> fromObject;
        match choice {
            
            case 1i8 =>
                let MultiSession.MultiSession(handlr1) = option1#option1;
                handlr1() 


            case 2i8 =>
                let MultiSession.MultiSession(handlr2) = option2#option2;
                handlr2() 

            case _ => unreachable!()
        }
    )

/**
 * Enter a recursive protocol definition
 */
pub def multisession_enter(_chan: MultiSessionChannel[t]) : MultiSession[(_Cap[t, env, Rec[recurProto]], x), (_Cap[t, (recurProto, env), recurProto], x), Unit, _effect] = 
    MultiSession.MultiSession(_ -> checked_ecast(()))

/**
 * Access the outermost recursive variable (at index Z)
 */
pub def multisession_zero(_chan: MultiSessionChannel[t]) : MultiSession[(_Cap[t, (recurProto, env), Var[Z]], x), (_Cap[t, (recurProto, env), recurProto], x), Unit, _effect] = 
    MultiSession.MultiSession(_ -> checked_ecast(()))

/**
 * Access a recursive variable at a greater depth
 */
pub def multisession_suc(_chan: MultiSessionChannel[t]) : MultiSession[(_Cap[t, (recurProto, env), Var[Suc[index]]], x), (_Cap[t, env, Var[index]], x), Unit, _effect] = 
    MultiSession.MultiSession(_ -> checked_ecast(()))

pub def dig(ses: MultiSession[x, x_prime, Unit, _effect]): MultiSession[(r, x), (r, x_prime), Unit, _effect] = ???

pub def swap(): MultiSession[(r, (s, x)), (s, (r, x)), Unit, _effect] = 
    MultiSession.MultiSession(_ -> checked_ecast(()))

pub def fork_session(ses: MultiSession[x, Unit, Unit, _effect]) : MultiSession[x, Unit, Unit, _effect] = ???

// pub def accept(rendez: Rendezvous[r], )


/**
 * Indexed monad instance for Session, enabling sequential composition of protocol steps
 */
instance IxMonad[MultiSession] {
    // Return a value in the Session monad without changing protocol state
    pub def ixreturn(value: a) : MultiSession[state, state, a, effect] =  
        MultiSession.MultiSession(_ -> checked_ecast(value))

    // Sequential composition of Session actions
    pub def ixbind(
        session: MultiSession[initialState, intermediateState, a, effect1], 
        next: a -> MultiSession[intermediateState, finalState, b, effect2] \ effect3
    ): MultiSession[initialState, finalState, b, effect1 + effect2 + effect3] = 
        MultiSession.MultiSession(channel ->
            let MultiSession.MultiSession(handlr1) = session;
            let MultiSession.MultiSession(handlr2) = 
                channel |> handlr1 |> next;
            channel |> handlr2
        )
}



}
