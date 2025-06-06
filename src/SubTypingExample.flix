mod SubTypingExample {
    use String.unwrap
    use Console.print
    use SesChans.session_recv
    use SesChans.session_send
    use IxMonad.>>>=
    use IxMonad.>>>|
    use Console.readln
    use Channel.recv
    import java.lang.Object

    /**
     * Server implementation that receives numbers from a client and 
     * performs operations on them.
     * The server offers two options to the client:
     * 1. Receive two numbers and send back the sum. 
     * 2. Receive a number and return the number negated
     */
    def server_1(): Session[
        Cap[Unit, ChoiceOffer2[
                    Receive[Int32, Receive[Int32, Send[Int32, Empty]]], 
                    Receive[Int32, Send[Int32, Empty]]]],
        Unit,
        Unit,
        Chan + NonDet
    ] = {
            session_offer_2(
                option1 =
                    session_recv() >>>= 
                    ((a: Int32) ->
                        session_recv() >>>= (
                            (b: Int32) -> 
                            session_send(a + b)
                        ))
                     >>>| session_close(),
                option2 = 
                    session_recv() >>>=
                    ((a: Int32) -> 
                        session_send(-a)
                    ) >>>| session_close()
                    )
    }

    /**
     * Server implementation that receives a from a client and negates it 
     * or does nothing.
     */
    def server_2(): Session[
        Cap[Unit, ChoiceOffer2[
                    Empty, 
                    Receive[Int32, Send[Int32, Empty]]]],
        Unit,
        Unit,
        IO + Chan + NonDet
    ] = {
            session_offer_2(
                option1 =
                    session_close() |> session_subeffect,
                option2 = 
                    session_recv() >>>=
                    ((a: Int32) -> 
                        session_send(-a)
                    ) >>>| session_close()
                    )
    }
    
    /**
     * Client implementation that sends messages to the server.
     * The client prompts the user for a number.
     * 
     * This number is then sent to the server and returns negated.
     * The client only uses one of the parts of the protocol so 
     * it does not need to specify the other one in the selection
     */
    def client(): Session[
        Cap[Unit, Sel2[generic, Send[Int32, Receive[Int32, Empty]]]],
        Unit, 
        Unit, 
        Console + Chan + NonDet
    ] \ Console = {
        let _ = Console.print("Enter a number to negate, q to exit: > ");
        let userInput = readln();
        let num = Result.getWithDefault(1, Int32.parse(10, userInput));
        sel_2_from_2() >>>| 
        session_send( num ) >>>|
        session_recv() >>>= 
        ((n: Int32) -> 
            let _ = Console.println(Int32.toString(n)); 
            session_close())
    }
    /**
     * Main entry point that sets up and runs the client-server example.
     * Creates a rendezvous point, spawns the server in a separate task,
     * and connects the client to the server.
     * It uses two different servers with different first parts of the protocols
     * (NOTE: Right now it does not work but I think it may be a compiler error
     * because removing one of the handlers make the example work, and client is 
     * polymorphic on its argument, it should be able to work with both. 
     * EXTRA NOTE: It fails when they are in different regions for some reason, will talk with
     * Magnus )
     */
    pub def execute_subtyping_example(): Unit \ IO + Chan + NonDet = {
        let handlr1 = _ -> {
            region sessionRegion {
                let rendezvousPoint = new_rendezvous();
                spawn session_accept(rendezvousPoint, server_1()) @ sessionRegion;
                session_request(rendezvousPoint, client());
                let rendezvousPoint2 = new_rendezvous();
                spawn session_accept(rendezvousPoint2, server_2()) @ sessionRegion;
                session_request(rendezvousPoint2, client())
            }
        };
        //let handlr2 = _ -> {
        //    region sessionRegion2 {
        //        let rendezvousPoint2 = new_rendezvous();
        //        spawn session_accept(rendezvousPoint2, server_2()) @ sessionRegion2;
        //        session_request(rendezvousPoint2, client())
        //    }
        //};
        //Console.handle(handlr2)();
        Console.handle(handlr1)()
        
    }
}