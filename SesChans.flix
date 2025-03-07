mod SesChans{
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

    // Should be able to use checked on the top ones but it does not let me
    pub def helper_boxer(elem: a) : Object  = typematch elem {
                case _ : Unit =>  unchecked_cast(Box.box(0) as Object)
                case x : Bool =>  unchecked_cast(Box.box(x) as Object)
                case x : Char =>  unchecked_cast(Box.box(x) as Object)
                case x : Float32 =>  unchecked_cast(Box.box(x) as Object)
                case x : Float64 =>  unchecked_cast(Box.box(x) as Object)
                case x : Int8 =>  unchecked_cast(Box.box(x) as Object)
                case x : Int16 =>  unchecked_cast(Box.box(x) as Object)
                case x : Int32 =>  unchecked_cast(Box.box(x) as Object)
                case x : Int64 =>  unchecked_cast(Box.box(x) as Object)
                case x : _ => unchecked_cast(x as Object)
            }

    pub def session_send(elem: a) : 
    Session[Cap[e, Send[a, r]], Cap[e, r], Unit] = 
    Session.Session(match (s, _r) -> 
        checked_ecast(Channel.send(
            helper_boxer(elem)
            , s))
        )
// Cannot typematch because I have no arg, maybe try some typelevel stuff

pub def recv_transformer(elem: Object, marker: Unit -> a) : a = 
     typematch marker {
                case _ : Unit -> Unit =>  unchecked_cast(() as a)
                case _ : Unit ->Bool =>  
                    let casted : Boolean = unchecked_cast(elem as Boolean);
                    let unboxed : Bool = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Char =>  
                    let casted : Character = unchecked_cast(elem as Character);
                    let unboxed : Char = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Float32 =>  
                    let casted : Float = unchecked_cast(elem as Float);
                    let unboxed : Float32 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Float64 => 
                    let casted : Double = unchecked_cast(elem as Double);
                    let unboxed : Float64 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Int8 => 
                    let casted : Byte = unchecked_cast(elem as Byte);
                    let unboxed : Int8 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Int16 =>  
                    let casted : Short = unchecked_cast(elem as Short);
                    let unboxed : Int16 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Int32 =>  
                    let casted : Integer = unchecked_cast(elem as Integer);
                    let unboxed : Int32 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit ->Int64 =>  
                    let casted : Long = unchecked_cast(elem as Long);
                    let unboxed : Int64 = Box.unbox(casted);
                    unchecked_cast( unboxed as a)
                case _ : Unit -> _ => unchecked_cast(elem as a)
                case _ : _ => unreachable!()
            }


pub def session_recv() : 
    Session[Cap[e, Receive[a, r]], Cap[e, r], a] = 
    Session.Session(match (_s, r) -> 
    checked_ecast(
        recv_transformer(Channel.recv(r), unchecked_cast(_ -> () as (Unit -> a)))))
}