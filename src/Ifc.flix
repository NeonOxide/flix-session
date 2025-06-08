
mod Ifc {
    use Channel.send
    import java.lang.Object
    enum Tagged[valType: Type, _securityLevel: Eff] with ToString {
        case Tagged(valType)
    }
    enum _ProgramState[_PC: Eff, _Blocking: Eff]


    
    pub enum Level[_securityLevel: Eff]

    pub enum TrustAt[_securityLevel: Eff]

    mod Level{
        pub def at() : Level[e] = Reflect.default()
        pub def to() : Level[e] = Reflect.default()
    }

    mod Tagged {
        use Ifc.Authority
        use Ifc.Level.at
        use Ifc.Level
        use Ifc._Authority
        pub def getNew(val: a, _initialLevel: Level[ef]) : Tagged[a, ef] = Tagged(val)


        pub def $$(val: a, initialLevel: Level[ef]) : Tagged[a, ef] = getNew(val, initialLevel)

        pub def raise(val: Tagged[a, prevLevel], _to: Level[addedLevel]) : Tagged[a, prevLevel + addedLevel] = 
            let Tagged(inner) = val;
            Tagged(inner)
        
        pub def !++(val: Tagged[a, prevLevel], to: Level[addedLevel]) : Tagged[a, prevLevel + addedLevel] = raise(val, to)

        pub def transform(f: a -> b \ ef, val: Tagged[a, level]) : Tagged[b, level] \ ef = 
            let Tagged(inner) = val;
            Tagged(f(inner))

        pub def applyBinOp(f: a -> b -> c \ ef, val1: Tagged[a, level1], val2: Tagged[b, level2]) : Tagged[c, level1 + level2] \ ef= 
            let Tagged(inner1) = val1;
            let Tagged(inner2) = val2;
            Tagged(f(inner1, inner2))

        pub def declassify(val: Tagged[a, onlyAuth + common + onlyTo], _auth: _Authority[onlyAuth + common + restAuth], _to: Level[onlyTo + common + restTo]) : Tagged[a, onlyTo + common + restTo] = 
            let Tagged(inner) = val;
            Tagged(inner)
        
        pub def unwrap(val: Tagged[a, {}]) : a = 
        let Tagged(inner) = val;
        inner


        pub def branchOn(cond: Tagged[Bool, branchLevel], then: Unit -> Tagged[b, levelThen] \ ef1, elseb: Unit -> Tagged[b, levelElse] \ ef2) : Tagged[b, levelThen + levelElse + branchLevel] \ ef1 + ef2= 
            let Tagged(con) = cond;
            if (con) {
                let Tagged(resThen) = then();
                Tagged(resThen)        
            } else {
                let Tagged(resElse) = elseb();
                Tagged(resElse)
            }
            
    }
    enum _Authority[_securityLevel: Eff]
    mod Authority{
        use Ifc.Authority.attenuate
        use Ifc.Level;
        use Ifc._Authority
        eff TopAuth
        pub def handleTopAuth(f: a -> b \ ef): a -> b \ (ef - {TopAuth} + IO) = x -> run {f(x)} with handler TopAuth {}
        pub def getTopAuth() : _Authority[Univ] \ TopAuth = 
            Reflect.default()

        pub def attenuate(_auth: _Authority[prevLevel], _to: Level[to]) : _Authority[prevLevel & to] = Reflect.default()

        pub def !--(auth: _Authority[prevLevel], to: Level[to]) : _Authority[prevLevel & to] = attenuate(auth, to)
    }
    
    /**
 * SessionIfc Types Library for Flix
 * 
 * This library implements SessionIfc Types for type-safe communication protocols
 * between concurrent processes. It provides a way to encode communication 
 * protocols at the type level and ensures protocol compliance at compile time.
 */



/**
 * Core protocol type constructors representing the basic building blocks
 * of sessionIfc types.
 */
 
// Represents sending a value of type 'payload' followed by protocol 'next'
pub enum SendIfc[_payload, _next]

// Represents receiving a value of type 'payload' followed by protocol 'next'
pub enum ReceiveIfc[_payload, _next]

// Represents offering between 2 different branch protocols
pub enum ChoiceOffer2Ifc[_branch1, _branch2]

// Represents offering between 3 different branch protocols
pub enum ChoiceOffer3[_branch1, _branch2, _branch3]

// Represents offering between 4 different branch protocols
pub enum ChoiceOffer4[_branch1, _branch2, _branch3, _branch4]

// Represents offering between 5 different branch protocols
pub enum ChoiceOffer5[_branch1, _branch2, _branch3, _branch4, _branch5]

// Represents offering between 6 different branch protocols
pub enum ChoiceOffer6[_branch1, _branch2, _branch3, _branch4, _branch5, _branch6]

// Represents selecting between 2 different branch protocols
pub enum ChoiceSelection2Ifc[_branch1, _branch2]

// Represents selecting between 3 different branch protocols
pub enum ChoiceSelection3[_branch1, _branch2, _branch3]

// Represents selecting between 4 different branch protocols
pub enum ChoiceSelection4[_branch1, _branch2, _branch3, _branch4]

// Represents selecting between 5 different branch protocols
pub enum ChoiceSelection5[_branch1, _branch2, _branch3, _branch4, _branch5]

// Represents selecting between 6 different branch protocols
pub enum ChoiceSelection6[_branch1, _branch2, _branch3, _branch4, _branch5, _branch6]


// Represents a recursive protocol definition
pub enum RecursionIfc[_body]

// Type-level Peano numbers for identifying recursive variables
pub enum ZIfc                // ZIfcero
pub enum SucIfc[_predecessor] // SucIfccessor

// Recursive variable at a specific depth where index is a type level Peano number
pub enum VarIfc[_index]

// Terminal protocol
pub enum EmptyIfc

/**
 * Type aliases for better readability when defining protocols
 */
type alias Recv[payload, next] = ReceiveIfc[payload, next]
type alias Sel2[protocol1, protocol2] = ChoiceSelection2Ifc[protocol1, protocol2]
type alias Sel3[protocol1, protocol2, protocol3] = ChoiceSelection3[protocol1, protocol2, protocol3]
type alias Sel4[protocol1, protocol2, protocol3, protocol4] = ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]
type alias Sel5[protocol1, protocol2, protocol3, protocol4, protocol5] = ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]
type alias Sel6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6] = ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]
type alias Off2[protocol1, protocol2] = ChoiceOffer2Ifc[protocol1, protocol2]
type alias Off3[protocol1, protocol2, protocol3] = ChoiceOffer3[protocol1, protocol2, protocol3]
type alias Off4[protocol1, protocol2, protocol3, protocol4] = ChoiceOffer4[protocol1, protocol2, protocol3, protocol4]
type alias Off5[protocol1, protocol2, protocol3, protocol4, protocol5] = ChoiceOffer5[protocol1, protocol2, protocol3, protocol4, protocol5]
type alias Off6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6] = ChoiceOffer6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]
type alias Rec[var] = RecursionIfc[var]
type alias E = EmptyIfc

/**
 * HasDualIfc trait for computing the dual of a protocol.
 * Each protocol has a dual that represents the other side of the communication.
 */
sealed trait HasDualIfc[protocol] {
    type Dual
}

// EmptyIfc protocol's dual is EmptyIfc
instance HasDualIfc[EmptyIfc] {
    type Dual = EmptyIfc
}

// SendIfc's dual is ReceiveIfc with the same payload type and dual continuation
instance HasDualIfc[SendIfc[payload, next]] with HasDualIfc[next] {
    type Dual = ReceiveIfc[payload, HasDualIfc.Dual[next]]
}

// ReceiveIfc's dual is SendIfc with the same payload type and dual continuation
instance HasDualIfc[ReceiveIfc[payload, next]] with HasDualIfc[next] {
    type Dual = SendIfc[payload, HasDualIfc.Dual[next]]
}



// RecursionIfc's dual is RecursionIfc with the dual body
instance HasDualIfc[RecursionIfc[body]] with HasDualIfc[body] {
    type Dual = RecursionIfc[HasDualIfc.Dual[body]]
}

// Recursive variable's dual is itself (preserves the recursion structure)
instance HasDualIfc[VarIfc[index]] {
    type Dual = VarIfc[index]
}

// ChoiceOffer2Ifc's dual is ChoiceSelection2Ifc with dual branches
instance HasDualIfc[ChoiceOffer2Ifc[protocol1, protocol2]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2] 
    {
        type Dual = ChoiceSelection2Ifc[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2]]
    }



// ChoiceOffer3's dual is ChoiceSelection3 with dual branches
instance HasDualIfc[ChoiceOffer3[protocol1, protocol2, protocol3]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3] 
    {
        type Dual = ChoiceSelection3[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3]]
    }



// ChoiceOffer4's dual is ChoiceSelection4 with dual branches
instance HasDualIfc[ChoiceOffer4[protocol1, protocol2, protocol3, protocol4]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4] 
    {
        type Dual = ChoiceSelection4[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4]]
    }



// ChoiceOffer5's dual is ChoiceSelection5 with dual branches
instance HasDualIfc[ChoiceOffer5[protocol1, protocol2, protocol3, protocol4, protocol5]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4], HasDualIfc[protocol5] 
    {
        type Dual = ChoiceSelection5[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4], HasDualIfc.Dual[protocol5]]
    }



// ChoiceOffer6's dual is ChoiceSelection6 with dual branches
instance HasDualIfc[ChoiceOffer6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4], HasDualIfc[protocol5], HasDualIfc[protocol6] 
    {
        type Dual = ChoiceSelection6[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4], HasDualIfc.Dual[protocol5], HasDualIfc.Dual[protocol6]]
    }



// ChoiceSelection2Ifc's dual is ChoiceOffer2Ifc with dual branches
instance HasDualIfc[ChoiceSelection2Ifc[protocol1, protocol2]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2] 
    {
        type Dual = ChoiceOffer2Ifc[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2]]
    }



// ChoiceSelection3's dual is ChoiceOffer3 with dual branches
instance HasDualIfc[ChoiceSelection3[protocol1, protocol2, protocol3]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3] 
    {
        type Dual = ChoiceOffer3[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3]]
    }



// ChoiceSelection4's dual is ChoiceOffer4 with dual branches
instance HasDualIfc[ChoiceSelection4[protocol1, protocol2, protocol3, protocol4]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4] 
    {
        type Dual = ChoiceOffer4[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4]]
    }



// ChoiceSelection5's dual is ChoiceOffer5 with dual branches
instance HasDualIfc[ChoiceSelection5[protocol1, protocol2, protocol3, protocol4, protocol5]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4], HasDualIfc[protocol5] 
    {
        type Dual = ChoiceOffer5[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4], HasDualIfc.Dual[protocol5]]
    }



// ChoiceSelection6's dual is ChoiceOffer6 with dual branches
instance HasDualIfc[ChoiceSelection6[protocol1, protocol2, protocol3, protocol4, protocol5, protocol6]] 
    with HasDualIfc[protocol1], HasDualIfc[protocol2], HasDualIfc[protocol3], HasDualIfc[protocol4], HasDualIfc[protocol5], HasDualIfc[protocol6] 
    {
        type Dual = ChoiceOffer6[HasDualIfc.Dual[protocol1], HasDualIfc.Dual[protocol2], HasDualIfc.Dual[protocol3], HasDualIfc.Dual[protocol4], HasDualIfc.Dual[protocol5], HasDualIfc.Dual[protocol6]]
    }


/**
 * Channel types for sessionIfc communication
 */
// Raw untyped sessionIfc channel using Object for type erasure and reducing the 
// number of required channels (by using one "untyped" channel we can reuse it 
// for all communication instead of needing one channel per type)
type alias SessionIfcChannel = (Sender[Object], Receiver[Object])

// Typed channel for specific element types
type alias TypedChannel[elemType] = (Sender[elemType], Receiver[elemType])

/**
 * Capability type for tracking protocol state in the type system
 * - env: Environment/context
 * - proto: Current protocol state
 */
pub enum CapIfc[_pc: Eff, _env: Type, _proto: Type ]

/**
 * SessionIfc monad for composing protocol interactions
 * - startState: Initial protocol state
 * - endState: Final protocol state
 * - resultType: Result type of the computation
 * - effects: Effect set of the computation
 */
pub enum SessionIfc[_startState: Type, _endState: Type, resultType: Type, effects: Eff, _trustAt: Eff](SessionIfcChannel -> resultType \ effects)


/**
 * Protocol primitives for implementing sessionIfc interactions
 */

instance IxMonadIfc[SessionIfc] {
    // Return a value in the Session monad without changing protocol state
    pub def ixreturn(value: a) : SessionIfc[state, state, a, {}, trust] =  
        SessionIfc.SessionIfc(_ -> value)

    // Sequential composition of Session actions
    pub def ixbind(
        session: SessionIfc[initialState, intermediateState, a, effect1, trust], 
        next: a -> SessionIfc[intermediateState, finalState, b, effect2, trust] \ effect3
    ): SessionIfc[initialState, finalState, b, effect1 + effect2 + effect3, trust] = 
        SessionIfc.SessionIfc(channel ->
            let SessionIfc.SessionIfc(handlr1) = session;
            let SessionIfc.SessionIfc(handlr2) = 
                channel |> handlr1 |> next;
            channel |> handlr2
        )
}
 

/**
 * Close a sessionIfc channel, terminating the protocol
 */
pub def session_close_ifc() : 
    SessionIfc[CapIfc[pc, _env, EmptyIfc], Unit, Unit, ef, trust] = 
    SessionIfc.SessionIfc(_channel -> ())

/**
 * Select the 1st branch in a choice out of 2 elements
 */
pub def sel_1_from_2_ifc(): 
    SessionIfc[CapIfc[pc, _env, ChoiceSelection2Ifc[protocol1, protocol2]], CapIfc[pc, _env, protocol1], Unit, Chan + ef, trust] = 
    SessionIfc.SessionIfc(match (sender, _receiver) -> 
        Channel.send(1i8 |> toObject, sender)
    )


/**
 * Select the 2nd branch in a choice out of 2 elements
 */
pub def sel_2_from_2_ifc(): 
    SessionIfc[CapIfc[pc, _env, ChoiceSelection2Ifc[protocol1, protocol2]], CapIfc[pc, _env, protocol2], Unit, Chan + ef, trust] = 
    SessionIfc.SessionIfc(match (sender, _receiver) -> 
        Channel.send(2i8 |> toObject, sender)
    )

/**
 * Handle an offered choice by providing handlers for all 2 possible branches
 */
pub def session_offer_2_ifc (
   option1: {option1 = SessionIfc[CapIfc[pc, _env, protocol1], endState, resultType, effects1, trust]},
   option2: {option2 = SessionIfc[CapIfc[pc, _env, protocol2], endState, resultType, effects2, trust]}  
) : SessionIfc[CapIfc[pc, _env, ChoiceOffer2Ifc[protocol1, protocol2]], endState, resultType, effects1 + effects2 + Chan + NonDet + ef, trust] = 
    SessionIfc.SessionIfc(channel ->
        let (_sender, receiver) = channel; 
        let choice = Channel.recv(receiver) |> fromObject;
        match choice {
            
            case 1i8 =>
                let SessionIfc.SessionIfc(handlr1) = option1#option1;
                handlr1(channel) 


            case 2i8 =>
                let SessionIfc.SessionIfc(handlr2) = option2#option2;
                handlr2(channel) 

            case _ => unreachable!()
        }
    )

pub def session_branch_ifc (
   cond: Tagged[Bool, newPc],
   then: {then = SessionIfc[CapIfc[pc + newPc, _env, protocol], endState, resultType, effects1, trust]},
   else_: {else_ = SessionIfc[CapIfc[pc + newPc, _env, protocol], endState, resultType, effects2, trust]}  
) : SessionIfc[CapIfc[pc, _env, protocol], endState, resultType, effects1 + effects2 + Chan + ef, trust] = 
    SessionIfc.SessionIfc(channel ->
        let Tagged.Tagged(inner) = cond; 
        if (inner) {
            let SessionIfc.SessionIfc(handlr1) = then#then;
                handlr1(channel) 
        } else {
            let SessionIfc.SessionIfc(handlr2) = else_#else_;
                handlr2(channel)
        }
    )





/**
 * Enter a recursive protocol definition
 */
pub def enter_ifc() : SessionIfc[CapIfc[pc1, env, Rec[recurProto]], CapIfc[pc1 + pc2, (recurProto, env), recurProto], Unit, ef, trust] = 
    SessionIfc.SessionIfc(_ -> ())

/**
 * Access the outermost recursive variable (at index ZIfc)
 */
pub def zero_ifc() : SessionIfc[CapIfc[pc, (recurProto, env), VarIfc[ZIfc]], CapIfc[pc, (recurProto, env), recurProto], Unit, ef, trust] = 
    SessionIfc.SessionIfc(_ -> ())

/**
 * Access a recursive variable at a greater depth
 */
pub def suc_ifc() : SessionIfc[CapIfc[pc, (recurProto, env), VarIfc[SucIfc[index]]], CapIfc[pc, env, VarIfc[index]], Unit, ef, trust] = 
    SessionIfc.SessionIfc(_ -> ())



/**
 * Rendezvous point for establishing a sessionIfc between two parties
 */
enum RendezvousIfc[_protocol](TypedChannel[SessionIfcChannel])

/**
 * Create a new rendezvous point for a given protocol
 */
pub def new_rendezvous_ifc() : RendezvousIfc[protocol] \ Chan =
    RendezvousIfc.RendezvousIfc(Channel.unbuffered())

/**
 * Accept a connection at a rendezvous point, playing the protocol role
 */
pub def session_accept_ifc(
    rendezvous: RendezvousIfc[protocol], 
    sessionIfc: SessionIfc[CapIfc[pc, Unit, protocol], Unit, resultType, effect, trust],
    _trustDual: Level[trust]
) : resultType \ effect + Chan = 
    let RendezvousIfc.RendezvousIfc((sender, _receiver)) = rendezvous;
    let SessionIfc.SessionIfc(handlr) = sessionIfc; 
    let communicationChannel = Channel.unbuffered(); 
    let _ = dbg("A");
    Channel.send(communicationChannel, sender); 
    handlr(communicationChannel)

/**
 * Request a connection at a rendezvous point, playing the dual protocol role
 */
pub def session_request_ifc(
    rendezvous: RendezvousIfc[protocol], 
    sessionIfc: SessionIfc[CapIfc[pc, Unit, HasDualIfc.Dual[protocol]], Unit, resultType, effect, trust],
    _trustDual: Level[trust]
): resultType \ effect + Chan + NonDet 
  with HasDualIfc[protocol] = 
    let RendezvousIfc.RendezvousIfc((_sender, receiver)) = rendezvous;
    let SessionIfc.SessionIfc(handlr) = sessionIfc; 
    Channel.recv(receiver) |> handlr



    /**
 * Module containing operations for session-typed channels.
 *
 * This module provides functionality for sending and receiving values through 
 * session-typed channels, handling the necessary type conversions between 
 * Flix's primitive types and Java's boxed types.
 */
mod SesChansIfc {
    use Ifc.Level.to;
    use Ifc.Tagged.!++;
    use Ifc.Level;
    use Ifc.CapIfc;
    use Ifc.ReceiveIfc;
    use Ifc.SendIfc;
    use Ifc.SessionIfc;
    use Ifc.Tagged;

    import java.lang.Long
    import java.lang.Short
    import java.lang.Byte
    import java.lang.Double
    import java.lang.Float
    import java.lang.Character
    import java.lang.Boolean
    import java.lang.Integer
    import java.lang.Object

    /**
     * Boxes a Flix value into a Java Object for transmission through channels.
     *
     * - `elem`: The Flix value to be boxed
     * - Returns a Java Object representation of the value
     */
    pub def helper_boxer(elem: a): Object = typematch elem {
        case _: Unit => unchecked_cast(Box.box(0) as Object)
        case x: Bool => unchecked_cast(Box.box(x) as Object)
        case x: Char => unchecked_cast(Box.box(x) as Object)
        case x: Float32 => unchecked_cast(Box.box(x) as Object)
        case x: Float64 => unchecked_cast(Box.box(x) as Object)
        case x: Int8 => unchecked_cast(Box.box(x) as Object)
        case x: Int16 => unchecked_cast(Box.box(x) as Object)
        case x: Int32 => unchecked_cast(Box.box(x) as Object)
        case x: Int64 => unchecked_cast(Box.box(x) as Object)
        case x: _ => unchecked_cast(x as Object)
    }
    
    /**
     * Creates a session that sends a value through a channel.
     *
     * - `elem`: The value to be sent
     * - Returns a session that, when executed, sends the value through the channel
     */
    pub def session_send_ifc(elem: Tagged[a, taggedTrust]): 
        SessionIfc[CapIfc[pc, e, SendIfc[a, r]], CapIfc[pc,e, r], Unit, Chan + ef, taggedTrust + extraTrust + pc ] =
        SessionIfc.SessionIfc(match (s, _r) ->
            Channel.send(
                helper_boxer(elem !++ (to(): Level[pc]))
            , s)
        )

    /**
     * Transforms a received Java Object back into a typed Flix value.
     *
     * - `elem`: The Java Object received from the channel
     * - `marker`: Type proxy used to determine the target Flix type
     * - Returns the unboxed value with the appropriate Flix type
     */
    pub def recv_transformer(elem: Object, marker: Proxy[a]): a =
        typematch marker {
            case _: Proxy[Unit] => unchecked_cast(() as a)
            case _: Proxy[Bool] =>
                let casted: Boolean = unchecked_cast(elem as Boolean);
                let unboxed: Bool = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Char] =>
                let casted: Character = unchecked_cast(elem as Character);
                let unboxed: Char = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Float32] =>
                let casted: Float = unchecked_cast(elem as Float);
                let unboxed: Float32 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Float64] =>
                let casted: Double = unchecked_cast(elem as Double);
                let unboxed: Float64 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Int8] =>
                let casted: Byte = unchecked_cast(elem as Byte);
                let unboxed: Int8 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Int16] =>
                let casted: Short = unchecked_cast(elem as Short);
                let unboxed: Int16 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Int32] =>
                let casted: Integer = unchecked_cast(elem as Integer);
                let unboxed: Int32 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[Int64] =>
                let casted: Long = unchecked_cast(elem as Long);
                let unboxed: Int64 = Box.unbox(casted);
                unchecked_cast(unboxed as a)
            case _: Proxy[_] => unchecked_cast(elem as a)
            case _: _ => unreachable!()
        }

    /**
     * Creates a session that receives a value from a channel.
     *
     * - Returns a session that, when executed, receives a value from the channel
     */
    pub def session_recv_ifc(): 
        SessionIfc[CapIfc[pc, e, ReceiveIfc[a, r]], CapIfc[pc, e, r], Tagged[a, trustReceiveIfcd + extraTrust], Chan + NonDet + ef, trustReceiveIfcd + extraTrust] =
        SessionIfc.SessionIfc(match (_s, r) ->
            recv_transformer(Channel.recv(r), Proxy.Proxy))
}

}
