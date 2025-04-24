/**
 * Module containing operations for session-typed channels.
 *
 * This module provides functionality for sending and receiving values through 
 * session-typed channels, handling the necessary type conversions between 
 * Flix's primitive types and Java's boxed types.
 */
mod SesChans {
    use SesChans.helper_boxer

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
    pub def session_send(elem: a): 
        Session[Cap[e, Send[a, r]], Cap[e, r], Unit, Chan] =
        Session.Session(match (s, _r) ->
            Channel.send(
                helper_boxer(elem)
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
    pub def session_recv(): 
        Session[Cap[e, Receive[a, r]], Cap[e, r], a, Chan + NonDet] =
        Session.Session(match (_s, r) ->
            recv_transformer(Channel.recv(r), Proxy.Proxy))
}