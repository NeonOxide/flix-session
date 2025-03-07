use String.unwrap
use Console.print
use SesChans.session_recv;
use SesChans.session_send;
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
    Cap[(ChoiceOffer[Empty, Receive[String, Receive[Int32, Var[Z]]]], Unit), 
        ChoiceOffer[Empty, Receive[String, Receive[Int32, Var[Z]]]]],     
    Unit, 
    Unit] \ IO =
    checked_ecast(
    session_offer( session_close(), 
                session_recv() >>>=
                ((s: String) -> 
                    let _ = println(s); session_recv())  
                >>>=
                ((n: Int32) -> 
                    let sum = n + 5; 
                    let _ = println(sum); zero()) >>>=
                (_ ->
                    loop())
                 ) )



def server(): Session[
    Cap[Unit, Recursion
                [ChoiceOffer[Empty, Receive[String, Receive[Int32, Var[Z]]] 
                    ]]], 
    Unit, 
    Unit] = 
    (enter() >>>= (_ -> checked_ecast(loop())))

def client_loop(n: Int32) : Session[
    Cap[(ChoiceSelection[Empty, Send[String, Send[Int32, Var[Z]]]], Unit), ChoiceSelection[Empty, Send[String, Send[Int32, Var[Z]]]]],
    Unit, 
    Unit] \ Console   =
    Console.print("Enter something to print, q to exit: >");
    let s = readln(); 
    Console.print("Enter a num to add 5 to, q to exit: >");
    let num = readln() |> Int32.parse(10) |> Result.getWithDefault(69); 
    if (s == "q")
        sel2() >>>| 
        session_send("lines sent ${n}") >>>|
        session_send(num) >>>|
        zero() >>>| sel1() >>>| session_close()
    else 
        sel2() >>>| session_send(s) >>>| session_send(num) >>>|
        zero() >>>= (_ -> Console.handle(client_loop)(n +1))
        

def client() : Session[
    Cap[Unit, Recursion[ChoiceSelection[Empty, Send[String, Send[Int32, Var[Z]]]]]]
    , Unit, Unit] = 
    enter() >>>= (_ -> Console.handle(client_loop)(0))

def main(): Unit \ IO + Chan + NonDet=
    let f = _ ->
    region rc {
    let rv = new_rendezvous(); 
    spawn session_accept(rv, server()) @ rc;
    session_request(rv, client())
    }; 
    Console.handle(f)()
    

    