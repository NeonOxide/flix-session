mod PrintServerExample {
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
     * Server implementation that receives and prints messages from a client.
     * The server offers two options to the client:
     * 1. Close the connection
     * 2. Receive a string, print it, and continue the session
     */
    def server(): Session[
        Cap[Unit, Recursion[ChoiceOffer2[Empty, Receive[String, Var[Z]]]]],
        Unit,
        Unit,
        IO + Chan + NonDet
    ] = {
        def serverLoop() =
            session_offer_2(
                option1 = 
                    session_close(),
                option2 = 
                    session_recv() >>>= 
                    ((message: String) ->
                        let _ = println(message); zero()
                    ) >>>= 
                    (_ ->
                        serverLoop()
                    )
            );
        
        enter() !<>! serverLoop
    }

    /**
     * Client implementation that sends messages to the server.
     * The client prompts the user for input:
     * - Any text is sent to the server
     * - Entering "q" terminates the session after reporting lines sent
     */
    def client(): Session[
        Cap[Unit, Recursion[ChoiceSelection2[Empty, Send[String, Var[Z]]]]],
        Unit, 
        Unit, 
        Console + Chan + NonDet
    ] = {
        def clientLoop(lineCount) = (
            // Prompt user for input
            let _ = Console.print("Enter something to print, q to exit: > ");
            let userInput = readln();
            
            if (userInput == "q")
                // Option 1: Send final message with line count and close connection
                sel_2_from_2() >>>|
                session_send("lines sent ${lineCount}") >>>|
                zero() >>>| 
                sel_1_from_2() >>>| 
                session_close()
            else
                // Option 2: Send the message and continue the session
                sel_2_from_2() >>>| 
                session_send(userInput) >>>|
                zero() >>>= 
                (_ -> clientLoop(lineCount + 1))
        );
        
        enter() >>>= (_ -> clientLoop(0))
    }

    /**
     * Main entry point that sets up and runs the client-server example.
     * Creates a rendezvous point, spawns the server in a separate task,
     * and connects the client to the server.
     */
    pub def execute_print_server_example(): Unit \ IO + Chan + NonDet = {
        let handlr = _ -> {
            region sessionRegion {
                let rendezvousPoint = new_rendezvous();
                spawn session_accept(rendezvousPoint, server()) @ sessionRegion;
                session_request(rendezvousPoint, client())
            }
        };
        
        Console.handle(handlr)()
    }
}