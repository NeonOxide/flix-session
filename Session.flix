/**
 * Session Types Library for Flix
 * 
 * This library implements Session Types for type-safe communication protocols
 * between concurrent processes. It provides a way to encode communication 
 * protocols at the type level and ensures protocol compliance at compile time.
 */

use SesChans.recv_transformer
use SesChans.helper_boxer
use Channel.send
import java.lang.Object

/**
 * Core protocol type constructors representing the basic building blocks
 * of session types.
 */
 
// Represents sending a value of type 'payload' followed by protocol 'next'
enum Send[_payload, _next]

// Represents receiving a value of type 'payload' followed by protocol 'next'
enum Receive[_payload, _next]

// Represents offering between 2 different branch protocols
enum ChoiceOffer2[_branch1, _branch2]

// Represents offering between 3 different branch protocols
enum ChoiceOffer3[_branch1, _branch2, _branch3]

// Represents offering between 4 different branch protocols
enum ChoiceOffer4[_branch1, _branch2, _branch3, _branch4]

// Represents offering between 5 different branch protocols
enum ChoiceOffer5[_branch1, _branch2, _branch3, _branch4, _branch5]

// Represents offering between 6 different branch protocols
enum ChoiceOffer6[_branch1, _branch2, _branch3, _branch4, _branch5, _branch6]

// Represents selecting between 2 different branch protocols
enum ChoiceSelection2[_branch1, _branch2]

// Represents selecting between 3 different branch protocols
enum ChoiceSelection3[_branch1, _branch2, _branch3]

// Represents selecting between 4 different branch protocols
enum ChoiceSelection4[_branch1, _branch2, _branch3, _branch4]

// Represents selecting between 5 different branch protocols
enum ChoiceSelection5[_branch1, _branch2, _branch3, _branch4, _branch5]

// Represents selecting between 6 different branch protocols
enum ChoiceSelection6[_branch1, _branch2, _branch3, _branch4, _branch5, _branch6]


// Represents a recursive protocol definition
enum Recursion[_body]

// Type-level Peano numbers for identifying recursive variables
enum Z                // Zero
enum Suc[_predecessor] // Successor

// Recursive variable at a specific depth where index is a type level Peano number
enum Var[_index]

// Terminal protocol
enum Empty

/**
 * Type aliases for better readability when defining protocols
 */
type alias Recv[payload, next] = Receive[payload, next]
type alias Sel2[protocol1, protocol2] = ChoiceSelection2[protocol1, protocol2]
type alias Sel3[protocol1, protocol2, protocol3] = ChoiceSelection3[protocol1, protocol2, protocol3]
type alias Sel4[protocol1, protocol2, protocol3, protocol4] = ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]
type alias Sel5[protocol1, protocol2, protocol3, protocol4, protocol5] = ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]
type alias Sel6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6] = ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]
type alias Off2[protocol1, protocol2] = ChoiceOffer2[protocol1, protocol2]
type alias Off3[protocol1, protocol2, protocol3] = ChoiceOffer3[protocol1, protocol2, protocol3]
type alias Off4[protocol1, protocol2, protocol3, protocol4] = ChoiceOffer4[protocol1, protocol2, protocol3, protocol4]
type alias Off5[protocol1, protocol2, protocol3, protocol4, protocol5] = ChoiceOffer5[protocol1, protocol2, protocol3, protocol4, protocol5]
type alias Off6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6] = ChoiceOffer6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]
type alias Rec[var] = Recursion[var]
type alias E = Empty

/**
 * HasDual trait for computing the dual of a protocol.
 * Each protocol has a dual that represents the other side of the communication.
 */
sealed trait HasDual[protocol] {
    type Dual
}

// Empty protocol's dual is Empty
instance HasDual[Empty] {
    type Dual = Empty
}

// Send's dual is Receive with the same payload type and dual continuation
instance HasDual[Send[payload, next]] with HasDual[next] {
    type Dual = Receive[payload, HasDual.Dual[next]]
}

// Receive's dual is Send with the same payload type and dual continuation
instance HasDual[Receive[payload, next]] with HasDual[next] {
    type Dual = Send[payload, HasDual.Dual[next]]
}



// Recursion's dual is Recursion with the dual body
instance HasDual[Recursion[body]] with HasDual[body] {
    type Dual = Recursion[HasDual.Dual[body]]
}

// Recursive variable's dual is itself (preserves the recursion structure)
instance HasDual[Var[index]] {
    type Dual = Var[index]
}

// ChoiceOffer2's dual is ChoiceSelection2 with dual branches
instance HasDual[ChoiceOffer2[protocol1, protocol2]] 
    with HasDual[protocol1], HasDual[protocol2] 
    {
        type Dual = ChoiceSelection2[HasDual.Dual[protocol1], HasDual.Dual[protocol2]]
    }



// ChoiceOffer3's dual is ChoiceSelection3 with dual branches
instance HasDual[ChoiceOffer3[protocol1, protocol2, protocol3]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3] 
    {
        type Dual = ChoiceSelection3[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3]]
    }



// ChoiceOffer4's dual is ChoiceSelection4 with dual branches
instance HasDual[ChoiceOffer4[protocol1, protocol2, protocol3, protocol4]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4] 
    {
        type Dual = ChoiceSelection4[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4]]
    }



// ChoiceOffer5's dual is ChoiceSelection5 with dual branches
instance HasDual[ChoiceOffer5[protocol1, protocol2, protocol3, protocol4, protocol5]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4], HasDual[protocol5] 
    {
        type Dual = ChoiceSelection5[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4], HasDual.Dual[protocol5]]
    }



// ChoiceOffer6's dual is ChoiceSelection6 with dual branches
instance HasDual[ChoiceOffer6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4], HasDual[protocol5], HasDual[protocol6] 
    {
        type Dual = ChoiceSelection6[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4], HasDual.Dual[protocol5], HasDual.Dual[protocol6]]
    }



// ChoiceSelection2's dual is ChoiceOffer2 with dual branches
instance HasDual[ChoiceSelection2[protocol1, protocol2]] 
    with HasDual[protocol1], HasDual[protocol2] 
    {
        type Dual = ChoiceOffer2[HasDual.Dual[protocol1], HasDual.Dual[protocol2]]
    }



// ChoiceSelection3's dual is ChoiceOffer3 with dual branches
instance HasDual[ChoiceSelection3[protocol1, protocol2, protocol3]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3] 
    {
        type Dual = ChoiceOffer3[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3]]
    }



// ChoiceSelection4's dual is ChoiceOffer4 with dual branches
instance HasDual[ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4] 
    {
        type Dual = ChoiceOffer4[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4]]
    }



// ChoiceSelection5's dual is ChoiceOffer5 with dual branches
instance HasDual[ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4], HasDual[protocol5] 
    {
        type Dual = ChoiceOffer5[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4], HasDual.Dual[protocol5]]
    }



// ChoiceSelection6's dual is ChoiceOffer6 with dual branches
instance HasDual[ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]] 
    with HasDual[protocol1], HasDual[protocol2], HasDual[protocol3], HasDual[protocol4], HasDual[protocol5], HasDual[protocol6] 
    {
        type Dual = ChoiceOffer6[HasDual.Dual[protocol1], HasDual.Dual[protocol2], HasDual.Dual[protocol3], HasDual.Dual[protocol4], HasDual.Dual[protocol5], HasDual.Dual[protocol6]]
    }


/**
 * Channel types for session communication
 */
// Raw untyped session channel using Object for type erasure and reducing the 
// number of required channels (by using one "untyped" channel we can reuse it 
// for all communication instead of needing one channel per type)
type alias SessionChannel = (Sender[Object], Receiver[Object])

// Typed channel for specific element types
type alias TypedChannel[elemType] = (Sender[elemType], Receiver[elemType])

/**
 * Capability type for tracking protocol state in the type system
 * - env: Environment/context
 * - proto: Current protocol state
 */
enum Cap[_env, _proto]

/**
 * Session monad for composing protocol interactions
 * - startState: Initial protocol state
 * - endState: Final protocol state
 * - resultType: Result type of the computation
 * - effects: Effect set of the computation
 */
enum Session[_startState: Type, _endState: Type, resultType: Type, effects: Eff](SessionChannel -> resultType \ effects)

/**
 * Indexed monad instance for Session, enabling sequential composition of protocol steps
 */
instance IxMonad[Session] {
    // Return a value in the Session monad without changing protocol state
    pub def ixreturn(value: a) : Session[state, state, a, effect] =  
        Session.Session(_ -> checked_ecast(value))

    // Sequential composition of Session actions
    pub def ixbind(
        session: Session[initialState, intermediateState, a, effect1], 
        next: a -> Session[intermediateState, finalState, b, effect2] \ effect3
    ): Session[initialState, finalState, b, effect1 + effect2 + effect3] = 
        Session.Session(channel ->
            let Session.Session(handlr1) = session;
            let Session.Session(handlr2) = 
                channel |> handlr1 |> next;
            channel |> handlr2
        )
}

/**
 * Protocol primitives for implementing session interactions
 */


 

/**
 * Close a session channel, terminating the protocol
 */
pub def session_close() : 
    Session[Cap[_env, Empty], Unit, Unit, _effect] = 
    Session.Session(_channel -> checked_ecast(()))

/**
 * Select the 1st branch in a choice out of 2 elements
 */
pub def sel_1_from_2(): 
    Session[Cap[_env, ChoiceSelection2[protocol1, protocol2]], Cap[_env, protocol1], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(1i8 |> toObject, sender)
        )
    )


/**
 * Select the 2nd branch in a choice out of 2 elements
 */
pub def sel_2_from_2(): 
    Session[Cap[_env, ChoiceSelection2[protocol1, protocol2]], Cap[_env, protocol2], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(2i8 |> toObject, sender)
        )
    )


/**
 * Select the 1st branch in a choice out of 3 elements
 */
pub def sel_1_from_3(): 
    Session[Cap[_env, ChoiceSelection3[protocol1, protocol2, protocol3]], Cap[_env, protocol1], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(1i8 |> toObject, sender)
        )
    )


/**
 * Select the 2nd branch in a choice out of 3 elements
 */
pub def sel_2_from_3(): 
    Session[Cap[_env, ChoiceSelection3[protocol1, protocol2, protocol3]], Cap[_env, protocol2], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(2i8 |> toObject, sender)
        )
    )


/**
 * Select the 3rd branch in a choice out of 3 elements
 */
pub def sel_3_from_3(): 
    Session[Cap[_env, ChoiceSelection3[protocol1, protocol2, protocol3]], Cap[_env, protocol3], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(3i8 |> toObject, sender)
        )
    )


/**
 * Select the 1st branch in a choice out of 4 elements
 */
pub def sel_1_from_4(): 
    Session[Cap[_env, ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]], Cap[_env, protocol1], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(1i8 |> toObject, sender)
        )
    )


/**
 * Select the 2nd branch in a choice out of 4 elements
 */
pub def sel_2_from_4(): 
    Session[Cap[_env, ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]], Cap[_env, protocol2], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(2i8 |> toObject, sender)
        )
    )


/**
 * Select the 3rd branch in a choice out of 4 elements
 */
pub def sel_3_from_4(): 
    Session[Cap[_env, ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]], Cap[_env, protocol3], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(3i8 |> toObject, sender)
        )
    )


/**
 * Select the 4th branch in a choice out of 4 elements
 */
pub def sel_4_from_4(): 
    Session[Cap[_env, ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]], Cap[_env, protocol4], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(4i8 |> toObject, sender)
        )
    )


/**
 * Select the 1st branch in a choice out of 5 elements
 */
pub def sel_1_from_5(): 
    Session[Cap[_env, ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]], Cap[_env, protocol1], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(1i8 |> toObject, sender)
        )
    )


/**
 * Select the 2nd branch in a choice out of 5 elements
 */
pub def sel_2_from_5(): 
    Session[Cap[_env, ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]], Cap[_env, protocol2], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(2i8 |> toObject, sender)
        )
    )


/**
 * Select the 3rd branch in a choice out of 5 elements
 */
pub def sel_3_from_5(): 
    Session[Cap[_env, ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]], Cap[_env, protocol3], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(3i8 |> toObject, sender)
        )
    )


/**
 * Select the 4th branch in a choice out of 5 elements
 */
pub def sel_4_from_5(): 
    Session[Cap[_env, ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]], Cap[_env, protocol4], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(4i8 |> toObject, sender)
        )
    )


/**
 * Select the 5th branch in a choice out of 5 elements
 */
pub def sel_5_from_5(): 
    Session[Cap[_env, ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]], Cap[_env, protocol5], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(5i8 |> toObject, sender)
        )
    )


/**
 * Select the 1st branch in a choice out of 6 elements
 */
pub def sel_1_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol1], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(1i8 |> toObject, sender)
        )
    )


/**
 * Select the 2nd branch in a choice out of 6 elements
 */
pub def sel_2_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol2], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(2i8 |> toObject, sender)
        )
    )


/**
 * Select the 3rd branch in a choice out of 6 elements
 */
pub def sel_3_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol3], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(3i8 |> toObject, sender)
        )
    )


/**
 * Select the 4th branch in a choice out of 6 elements
 */
pub def sel_4_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol4], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(4i8 |> toObject, sender)
        )
    )


/**
 * Select the 5th branch in a choice out of 6 elements
 */
pub def sel_5_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol5], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(5i8 |> toObject, sender)
        )
    )


/**
 * Select the 6th branch in a choice out of 6 elements
 */
pub def sel_6_from_6(): 
    Session[Cap[_env, ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], Cap[_env, protocol6], Unit, _effect + Chan] = 
    Session.Session(match (sender, _receiver) -> 
        checked_ecast(
            Channel.send(6i8 |> toObject, sender)
        )
    )

/**
 * Handle an offered choice by providing handlers for all 2 possible branches
 */
pub def session_offer_2 (
   option1: {option1 = Session[Cap[_env, protocol1], endState, resultType, effects1]},
   option2: {option2 = Session[Cap[_env, protocol2], endState, resultType, effects2]}  
) : Session[Cap[_env, ChoiceOffer2[protocol1, protocol2]], endState, resultType, effects1 + effects2 + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let Session.Session(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let Session.Session(handlr2) = option2#option2;
                handlr2(channel) 

            case _ => unreachable!()
        }
    )


/**
 * Handle an offered choice by providing handlers for all 3 possible branches
 */
pub def session_offer_3 (
   option1: {option1 = Session[Cap[_env, protocol1], endState, resultType, effects1]},
   option2: {option2 = Session[Cap[_env, protocol2], endState, resultType, effects2]},
   option3: {option3 = Session[Cap[_env, protocol3], endState, resultType, effects3]}  
) : Session[Cap[_env, ChoiceOffer3[protocol1, protocol2, protocol3]], endState, resultType, effects1 + effects2 + effects3 + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let Session.Session(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let Session.Session(handlr2) = option2#option2;
                handlr2(channel) 


            case 3i8 =>
                let Session.Session(handlr3) = option3#option3;
                handlr3(channel) 

            case _ => unreachable!()
        }
    )


/**
 * Handle an offered choice by providing handlers for all 4 possible branches
 */
pub def session_offer_4 (
   option1: {option1 = Session[Cap[_env, protocol1], endState, resultType, effects1]},
   option2: {option2 = Session[Cap[_env, protocol2], endState, resultType, effects2]},
   option3: {option3 = Session[Cap[_env, protocol3], endState, resultType, effects3]},
   option4: {option4 = Session[Cap[_env, protocol4], endState, resultType, effects4]}  
) : Session[Cap[_env, ChoiceOffer4[protocol1, protocol2, protocol3, protocol4]], endState, resultType, effects1 + effects2 + effects3 + effects4 + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let Session.Session(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let Session.Session(handlr2) = option2#option2;
                handlr2(channel) 


            case 3i8 =>
                let Session.Session(handlr3) = option3#option3;
                handlr3(channel) 


            case 4i8 =>
                let Session.Session(handlr4) = option4#option4;
                handlr4(channel) 

            case _ => unreachable!()
        }
    )


/**
 * Handle an offered choice by providing handlers for all 5 possible branches
 */
pub def session_offer_5 (
   option1: {option1 = Session[Cap[_env, protocol1], endState, resultType, effects1]},
   option2: {option2 = Session[Cap[_env, protocol2], endState, resultType, effects2]},
   option3: {option3 = Session[Cap[_env, protocol3], endState, resultType, effects3]},
   option4: {option4 = Session[Cap[_env, protocol4], endState, resultType, effects4]},
   option5: {option5 = Session[Cap[_env, protocol5], endState, resultType, effects5]}  
) : Session[Cap[_env, ChoiceOffer5[protocol1, protocol2, protocol3, protocol4, protocol5]], endState, resultType, effects1 + effects2 + effects3 + effects4 + effects5 + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let Session.Session(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let Session.Session(handlr2) = option2#option2;
                handlr2(channel) 


            case 3i8 =>
                let Session.Session(handlr3) = option3#option3;
                handlr3(channel) 


            case 4i8 =>
                let Session.Session(handlr4) = option4#option4;
                handlr4(channel) 


            case 5i8 =>
                let Session.Session(handlr5) = option5#option5;
                handlr5(channel) 

            case _ => unreachable!()
        }
    )


/**
 * Handle an offered choice by providing handlers for all 6 possible branches
 */
pub def session_offer_6 (
   option1: {option1 = Session[Cap[_env, protocol1], endState, resultType, effects1]},
   option2: {option2 = Session[Cap[_env, protocol2], endState, resultType, effects2]},
   option3: {option3 = Session[Cap[_env, protocol3], endState, resultType, effects3]},
   option4: {option4 = Session[Cap[_env, protocol4], endState, resultType, effects4]},
   option5: {option5 = Session[Cap[_env, protocol5], endState, resultType, effects5]},
   option6: {option6 = Session[Cap[_env, protocol6], endState, resultType, effects6]}  
) : Session[Cap[_env, ChoiceOffer6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]], endState, resultType, effects1 + effects2 + effects3 + effects4 + effects5 + effects6 + Chan + NonDet] = 
    Session.Session(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let Session.Session(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let Session.Session(handlr2) = option2#option2;
                handlr2(channel) 


            case 3i8 =>
                let Session.Session(handlr3) = option3#option3;
                handlr3(channel) 


            case 4i8 =>
                let Session.Session(handlr4) = option4#option4;
                handlr4(channel) 


            case 5i8 =>
                let Session.Session(handlr5) = option5#option5;
                handlr5(channel) 


            case 6i8 =>
                let Session.Session(handlr6) = option6#option6;
                handlr6(channel) 

            case _ => unreachable!()
        }
    )





/**
 * Enter a recursive protocol definition
 */
pub def enter() : Session[Cap[env, Rec[recurProto]], Cap[(recurProto, env), recurProto], Unit, _effect] = 
    Session.Session(_ -> checked_ecast(()))

/**
 * Access the outermost recursive variable (at index Z)
 */
pub def zero() : Session[Cap[(recurProto, env), Var[Z]], Cap[(recurProto, env), recurProto], Unit, _effect] = 
    Session.Session(_ -> checked_ecast(()))

/**
 * Access a recursive variable at a greater depth
 */
pub def suc() : Session[Cap[(recurProto, env), Var[Suc[index]]], Cap[env, Var[index]], Unit, _effect] = 
    Session.Session(_ -> checked_ecast(()))

/**
 * Rendezvous point for establishing a session between two parties
 */
enum Rendezvous[_protocol](TypedChannel[SessionChannel])

/**
 * Create a new rendezvous point for a given protocol
 */
pub def new_rendezvous() : Rendezvous[protocol] \ Chan =
    Rendezvous.Rendezvous(Channel.unbuffered())

/**
 * Accept a connection at a rendezvous point, playing the protocol role
 */
pub def session_accept(
    rendezvous: Rendezvous[protocol], 
    session: Session[Cap[Unit, protocol], Unit, resultType, effect]
) : resultType \ effect + Chan = 
    let Rendezvous.Rendezvous((sender, _receiver)) = rendezvous;
    let Session.Session(handlr) = session; 
    let communicationChannel = Channel.unbuffered(); 
    Channel.send(communicationChannel, sender); 
    handlr(communicationChannel)

/**
 * Request a connection at a rendezvous point, playing the dual protocol role
 */
pub def session_request(
    rendezvous: Rendezvous[protocol], 
    session: Session[Cap[Unit, HasDual.Dual[protocol]], Unit, resultType, effect]
): resultType \ effect + Chan + NonDet 
  with HasDual[protocol] = 
    let Rendezvous.Rendezvous((_sender, receiver)) = rendezvous;
    let Session.Session(handlr) = session; 
    Channel.recv(receiver) |> handlr

/**
 * Utility functions for type erasure and recovery
 */

/**
 * Convert a value to Object (for type erasure in communication)
 * Note: Should only be used within session primitive implementations
 */
pub def toObject(value: a) : Object =
    helper_boxer(value)

/**
 * Convert an Object back to its original type
 * Note: Should only be used within session primitive implementations
 */
pub def fromObject(obj: Object) : a = 
    recv_transformer(obj, Proxy.Proxy)


/**
 * Operator used to lazily enter a recursive session in order to avoid
 * infinitely recursing 
 */
def !<>!(f1: Session[Cap[e, Rec[r]], Cap[(r,e), r], a1, ef1 ], 
    loop: Unit -> Session[Cap[(r,e), r], k, a2, ef2]) : 
    Session[Cap[e, Recursion[r]], k, a2, ef1 + ef2]
     =
    IxMonad.ixbind(f1, (_ -> loop()))  