use SesChans.helper_boxer
use IxMonad.>>>|;
use SesChans.session_recv
use SessionGraph.generate_single_dot_graph

def example_proto() : Session[Cap[_env, Receive[Int32, Empty]], Unit, Unit, Chan + NonDet] = 
    session_recv() >>>| session_close()



enum SessionType with Eq, Order, ToString {
    case End
    case Send(String, SessionType)
    case Receive(String, SessionType)
    case Offer(SessionType, SessionType)
    case Choose(SessionType, SessionType)
    case Recursive(Int32)
}


//
//def getType(var: a) : String \ IO = 
//    let obj = helper_boxer(var);
//    println(obj.getClass().getName());
//    "Eo"
//def isDual(): Bool \ IO = 
//    let _p1 = SessionType.Send("Int32", SessionType.End);
//    let _p2 = SessionType.Receive("Int32", SessionType.End);
//
//    let rules = #{
//        Type("Int32").
//        IsDual(SessionType.End, SessionType.End).
//
//        IsDual(SessionType.Offer(b, d), SessionType.Choose(c, e)) :- IsDual(b, c), IsDual(d, e).
//        IsDual(SessionType.Choose(b, d), SessionType.Offer(c, e)) :- IsDual(b, c), IsDual(d, e).  
//    };
//    let a = query rules select (x,y) from IsDual(x, y);
//    println(a);
//
//    true

//def main(): Unit \ IO + Chan + NonDet =
//    PrintServerExample.execute_print_server_example()
    
//enum MyProxy[_] with ToString{
//    case Proxy
//}

def main(): Unit \ IO + Chan + NonDet =
    PrintServerExample.execute_print_server_example()

    