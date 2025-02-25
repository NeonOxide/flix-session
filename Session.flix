use Channel.send;
import java.lang.Object
enum Send[_a, _b]

enum Receive[_a, _b]

enum ChoiceOffer[_a, _b]

enum ChoiceSelection[_a, _b]

enum Recursion[_a]


// Peano Type constructors
enum Z

enum Suc[_a]


enum Var[_a]

enum Empty

type alias Recv[a, b] = Receive[a, b]

type alias Off[a, b] = ChoiceSelection[a, b]
type alias Sel[a, b] = ChoiceOffer[a, b]

type alias Rec[a] = Recursion[a]

type alias E = Empty

type alias Request = Int32
type alias Response = Bool

type alias Protocol1 = Send[Request, 
    Rec[Recv[Response, Off[Var[Z], E]]] ]






sealed trait HasDual[t] {
    type Dual
}

instance HasDual[Empty] {
    type Dual = Empty
}

instance HasDual[Send[a, b]] with HasDual[b] {
    type Dual = Receive[a, HasDual.Dual[b]]
}

instance HasDual[Receive[a, b]] with HasDual[b] {
    type Dual = Send[a, HasDual.Dual[b]]
}


instance HasDual[ChoiceOffer[a, b]] 
    with HasDual[a], HasDual[b] 
    {
        type Dual = ChoiceSelection[HasDual.Dual[a], HasDual.Dual[b]]
    }

instance HasDual[ChoiceSelection[a, b]] 
    with HasDual[a], HasDual[b] 
    {
        type Dual = ChoiceOffer[HasDual.Dual[a], HasDual.Dual[b]]
    }

instance HasDual[Recursion[a]] with HasDual[a] {
    type Dual = Recursion[HasDual.Dual[a]]
}

instance HasDual[Var[a]] {
    type Dual = Var[a]
}



type alias SessionChannel = (Sender[Object], Receiver[Object])

type alias TypedChannel[elem] = (Sender[elem], Receiver[elem])

enum Cap[_e, _r]

enum Session[_s, _ss, elem](SessionChannel -> elem \ Chan + NonDet )

instance IxMonad[Session] {
    pub def ixreturn(e: a) : Session[i, i, a] =  
        Session.Session(_ -> checked_ecast(e))

    // Need to fix, maybe add a new effect set parameter to the sessions
    pub def ixbind(e: Session[i, j, a], f: a -> Session[j, k, b] \e1 ): Session[i, k, b] = 
        Session.Session( nc ->
            let Session.Session(fchan1) = e;
            let Session.Session(fchan2) = 
                nc |> fchan1 |> f;
            nc |> fchan2
        )
}



type alias Proto[e, a, r] = Session[Cap[e, Send[a, r]], Cap[e, r], Unit]

pub def session_send(elem: a) : 
    Session[Cap[e, Send[a, r]], Cap[e, r], Unit] = 
    Session.Session(match (s, _r) -> 
        checked_ecast(Channel.send(unchecked_cast(elem as Object), s))
        )

pub def session_recv() : 
    Session[Cap[e, Receive[a, r]], Cap[e, r], a] = 
    Session.Session(match (_s, r) -> 
        unchecked_cast(Channel.recv(r) as a)
        )

pub def session_close() : 
    Session[Cap[e, Empty], Unit, Unit] = 
    Session.Session(_a -> checked_ecast(()))

pub def sel1(): 
    Session[Cap[e, ChoiceSelection[l, r]], Cap[e, l], Unit] = 
    Session.Session(match (s, _r) -> 
        checked_ecast(
            Channel.send(true |> toObject, s)
                    )
        )

pub def sel2(): 
    Session[Cap[e, ChoiceSelection[l, r]], Cap[e, r], Unit] = 
    Session.Session(match (s, _r) -> 
        checked_ecast(
            Channel.send(false |> toObject, s)
                    )
        )

pub def session_offer (opt1: Session[Cap[e, l], u, a], 
               opt2: Session[Cap[e, r], u, a]
) : Session[Cap[e, ChoiceOffer[l, r]], u, a] = 
    Session.Session(c ->
        let (_s, r) = c; 
        let choice = Channel.recv(r) |> fromObject;
        if (choice) 
            let Session.Session(fchan1) = opt1;
            fchan1 (c) 
        else 
            let Session.Session(fchan2) = opt2;
            fchan2 (c)
    )


pub def enter() : Session[Cap[e, Rec[r]], Cap[(r, e), r], Unit] = 
    Session.Session(_ -> checked_ecast(()))


pub def zero() : Session[Cap[(r, e), Var[Z]], Cap[(r, e), r], Unit] = 
    Session.Session(_ -> checked_ecast(()))


pub def suc() : Session[Cap[(r, e), Var[Suc[n]]], Cap[e, Var[n]], Unit] = 
    Session.Session(_ -> checked_ecast(()))


enum Rendezvous[_protocol](TypedChannel[SessionChannel])

pub def new_rendezvous() : Rendezvous[r] \ Chan =
    Rendezvous.Rendezvous(Channel.unbuffered())

pub def session_accept(ren: Rendezvous[r], ses: Session[Cap[Unit, r], Unit, a]) : a  \ Chan + NonDet = 
    let Rendezvous.Rendezvous((s, _r)) = ren;
    let Session.Session(fchan) = ses; 
    let comm_chan = Channel.unbuffered(); 
    Channel.send(comm_chan, s); 
    fchan (comm_chan)


pub def session_request(ren: Rendezvous[r], 
                        ses: Session[Cap[ Unit, HasDual.Dual[r]], Unit, a]): 
                        a \ Chan + NonDet 
                    with HasDual[r] = 
    let Rendezvous.Rendezvous((_s, r)) = ren;
    let Session.Session(fchan) = ses; 
    Channel.recv(r) |> fchan


// TODO: Take into account typematch to box and unbox 
// primitive values if there is no way of making it better

pub def toObject(e: a) : Object =
    unchecked_cast(e as Object)

pub def fromObject(o: Object) : a = 
    unchecked_cast(o as a)