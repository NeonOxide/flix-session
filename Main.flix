use IxMonad.>>>=;
use IxMonad.>>>|;
use Console.readln
use Channel.recv
import java.lang.Object

def <<(f1: c -> a, f2: b -> c) : b -> a =
    f2 >> f1


def loop_works_example() : 
    Session[Cap[(ChoiceOffer[Var[Z], Empty], Unit), ChoiceOffer[Var[Z], Empty]],
            Unit, Unit] =
session_offer(
            zero() >>>| 
            loop_works_example(), 
    session_close())


def loop() : Session[
    Cap[(ChoiceOffer[Empty, Receive[String, Var[Z]]], Unit), 
        ChoiceOffer[Empty, Receive[String, Var[Z]]]],     
    Unit, 
    Unit] \ IO=
session_offer( session_close(), 
                session_recv() >>>=
                ((s: String) -> 
                    let _ = println(s); zero()) 
                >>>| loop() ) 



def server(): Session[
    Cap[Unit, Recursion
                [ChoiceOffer[Empty, Receive[String, Var[Z]] 
                    ]]], 
    Unit, 
    Unit] \ IO = 
    
    (enter() >>>| loop())

def client_loop(n: Int32) : Session[
    Cap[(ChoiceSelection[Empty, Send[String, Var[Z]]], t1), ChoiceSelection[t0, Send[String, Var[Z]]]],
    Unit, 
    Unit] \ Console   =
    let s = readln(); 
    if (s == "q")
        sel2() >>>| 
        session_send("lines sent ${n}") >>>|
        zero() >>>| sel1() >>>| session_close()
    else 
        sel2() >>>| session_send(s) >>>|
        zero() >>>| client_loop(n +1)
        

def client() : Session[
    Cap[t0, Recursion[ChoiceSelection[Empty, Send[String, Var[Z]]]]]
    , Unit, Unit] \ Console = 
    enter() >>>| client_loop(0)

def main(): Unit \ IO + Chan + NonDet=
    let f = _ ->
    region rc {
    let rv = new_rendezvous(); 
    spawn session_accept(rv, server()) @ rc;
    session_request(rv, client());
    println("AAA")
    }; 
    Console.handle(f)()
    

    