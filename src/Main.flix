//use PrintServerExample.clientLoopIf;
use Ifc.Level.to;
use Ifc.Level;
use Ifc.Level.at
use Ifc.Tagged
use Exit.exit
use Ifc.Authority
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
eff Bob
eff Alice 
eff Robert
eff Annie

def main(): Unit \ IO + Chan + NonDet + Sys =
    let auth = Authority.handleTopAuth(Ifc.Authority.getTopAuth)();
    let val = Tagged.getNew(5, (at() : Level[Bob + Alice]));
    let _val2 = Tagged.getNew(10, (at() : Level[Robert + Annie]));
    let valBool = Tagged.getNew(true, (at() : Level[Robert + Annie]));
    let val3 = Tagged.transform(x -> if(x){3}else{5}, valBool);
    let atAuth = Authority.attenuate(auth, (to(): Level[Alice]));
    let _nval = Tagged.declassify(val, atAuth, (to(): Level[Bob]));
    let _valmatch = Tagged.Tagged(5);
//    let _test = clientLoopIf(2);
    let _ = IfcServerExample.execute_ifc_server_example();
    println(val3)
    //PrintServerExample.execute_print_server_example()

    