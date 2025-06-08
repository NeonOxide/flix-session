mod IfcServerExample {
    use Ifc.session_branch_ifc
    use Ifc.Tagged.$$;
    use Ifc.Tagged.transform;
    use Ifc.ReceiveIfc;
    use Ifc.SendIfc;
    use Ifc.ChoiceSelection2Ifc;
    use Ifc.CapIfc;
    use Ifc.ZIfc;
    use Ifc.VarIfc;
    use Ifc.EmptyIfc;
    use Ifc.ChoiceOffer2Ifc;
    use Ifc.RecursionIfc;
    use Ifc.sel_2_from_2_ifc;
    use Ifc.sel_1_from_2_ifc;
    use Ifc.SessionIfc;
    use Ifc.zero_ifc;
    use Ifc.session_offer_2_ifc;
    use Ifc.SesChansIfc.session_recv_ifc
    use Ifc.SesChansIfc.session_send_ifc
    use Ifc.enter_ifc
    use Ifc.session_close_ifc
    use IxMonadIfc.>>>|;
    use Ifc.Level
    use Ifc.Level.at
    use Ifc.session_request_ifc;
    use Ifc.session_accept_ifc;
    use Ifc.new_rendezvous_ifc;
    use String.unwrap
    use Console.print
    use IxMonadIfc.>>>=
    use Console.readln
    use Channel.recv
    import java.lang.Object

    /**
     * Server implementation that receives and prints messages from a client.
     * The server offers two options to the client:
     * 1. Close the connection
     * 2. Receive a string, print it, and continue the session
     */



    def _server_ifc_test(): SessionIfc[
        CapIfc[{}, Unit ,ReceiveIfc[String, EmptyIfc]],
        Unit,
        Unit,
        IO + Chan + NonDet,
        Bob
    ] = {
        session_recv_ifc() >>>| session_close_ifc()
    }

    def _server_ifc(): SessionIfc[
        CapIfc[{},Unit, RecursionIfc[ChoiceOffer2Ifc[EmptyIfc, ReceiveIfc[String, VarIfc[ZIfc]]]]],
        Unit,
        Unit,
        IO + Chan + NonDet,
        Bob
    ] = {
        def serverLoop() =
            session_offer_2_ifc(
                option1 = 
                    session_close_ifc(),
                option2 = 
                    session_recv_ifc() >>>= 
                    ((message) ->
                        let _ = println(message); zero_ifc()
                    ) >>>= 
                    (_ ->
                        serverLoop()
                    )
            );
        
        enter_ifc() >>>= (_ -> serverLoop())
    }
    /**
     * Client implementation that sends messages to the server.
     * The client prompts the user for input:
     * - Any text is sent to the server
     * - Entering "q" terminates the session after reporting lines sent
     */

    def _client_ifc_test(): SessionIfc[
        CapIfc[{}, Unit, SendIfc[String, EmptyIfc]],
        Unit, 
        Unit, 
        Chan,
        Bob
    ] = {
        session_send_ifc(Ifc.Tagged.getNew("Hola", (at(): Level[Bob]))) >>>| session_close_ifc()
    } 

    def _test(): SessionIfc[
        CapIfc[{}, Unit, EmptyIfc],
        Unit, 
        Unit, 
        {},
        Bob
    ] = session_close_ifc()


    //pub def clientLoopIf(_: Int32): SessionIfc[
    //    CapIfc[{}, Unit, ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, EmptyIfc]]],
    //    Unit, 
    //    Unit, 
    //    Chan,
    //    Bob + Alice + Robert
    //] =    
    //        //let userInput = readln();
    //        let nuserInput = Ifc.Tagged.getNew("B", (at(): Level[Bob]));
    //        let nuserInput2 = Ifc.Tagged.getNew("A", (at(): Level[Alice]));
    //        let nuserInput3 = Ifc.Tagged.getNew("C", (at(): Level[Robert]));
    //        let comp = transform(x -> x =="q", nuserInput);
    //        let comp2 = transform(x -> x =="q", nuserInput2);
    //        session_branch_ifc(comp, 
    //            {then=
    //            sel_1_from_2_ifc() >>>| 
    //            session_close_ifc()
    //            
    //            }, {
    //                else_=
    //                session_branch_ifc(comp2,
    //                {then= 
    //                sel_2_from_2_ifc() >>>| 
    //                session_send_ifc(nuserInput3) >>>|
    //                session_close_ifc()}, {else_=
    //                sel_2_from_2_ifc() >>>| 
    //                session_send_ifc(nuserInput) >>>|
    //                session_close_ifc()})
    //            })
    
    def _client_loop_no_infer(lineCount: Int32) : 
    SessionIfc[
        CapIfc[Bob, (ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]], Unit), ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]]],
        Unit, 
        Unit, 
        Chan + Console,
        Bob
    ] \ Console = {
            let _ = Console.print("Enter something to print, q to exit: > ");
            let userInput = readln();
            let nuserInput = Ifc.Tagged.getNew(userInput, (at(): Level[Bob]));
            let comp = transform(x -> x =="q", nuserInput);
            session_branch_ifc(comp, 
                {then=
                sel_2_from_2_ifc() >>>| 
                session_send_ifc(Ifc.Tagged.getNew("lines sent ${lineCount}", (at(): Level[Bob]))) >>>|
                zero_ifc() >>>| 
                sel_1_from_2_ifc() >>>| 
                session_close_ifc()
                }, {
                    else_=
                    sel_2_from_2_ifc() >>>| 
                    session_send_ifc(nuserInput) >>>|
                    zero_ifc()  >>>= 
                    (_ -> _client_loop_no_infer(lineCount + 1))
                })
}

    //def _client_ifc_does_not_work_with_inference() : SessionIfc[
    //    CapIfc[{}, Unit, RecursionIfc[ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]]]],
    //    Unit, 
    //    Unit, 
    //    Chan + Console,
    //    Bob
    //] = {
    //    def clientLoop(lineCount) = (
    //        let _ = Console.print("Enter something to print, q to exit: > ");
    //        let userInput = readln();
    //        let nuserInput = Ifc.Tagged.getNew(userInput, (at(): Level[Bob]));
    //        let comp = transform(x -> x =="q", nuserInput);
    //        session_branch_ifc(comp, 
    //            {then=
    //            sel_2_from_2_ifc() >>>| 
    //            session_send_ifc(Ifc.Tagged.getNew("lines sent ${lineCount}", (at(): Level[Bob]))) >>>|
    //            zero_ifc() >>>| 
    //            sel_1_from_2_ifc() >>>| 
    //            session_close_ifc()
    //            }, {
    //                else_=
    //                sel_2_from_2_ifc() >>>| 
    //                session_send_ifc(Ifc.Tagged.getNew("lines sent ${lineCount}", (at(): Level[Bob]))) >>>|
    //                zero_ifc() >>>| 
    //                sel_1_from_2_ifc() >>>| 
    //                session_close_ifc()
    //            })
    //    );
//
    //    enter_ifc() >>>= (_ -> clientLoop(0))
    //}

    def _client_ifc(): SessionIfc[
        CapIfc[{}, Unit, RecursionIfc[ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]]]],
        Unit, 
        Unit, 
        Chan + Console,
        Bob
    ] = {
        enter_ifc() >>>= (_ -> _client_loop_no_infer(0))
    }



    def _client_ifc_works_if(): SessionIfc[
        CapIfc[{}, Unit, RecursionIfc[ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]]]],
        Unit, 
        Unit, 
        Chan + Console,
        Bob
    ] = {
        //def clientLoopWorks(lineCount) = (
        //    // Prompt user for input
        //    let _ = Console.print("Enter something to print, q to exit: > ");
        //    let userInput = readln();
        //    if (userInput == "q")
        //        // Option 1: Send final message with line count and close connection
        //        sel_2_from_2_ifc() >>>|
        //        session_send_ifc(Ifc.Tagged.getNew("lines sent ${lineCount}", (at(): Level[Bob]))) >>>|
        //        zero_ifc() >>>| 
        //        sel_1_from_2_ifc() >>>| 
        //        session_close_ifc() 
        //    else
        //        // Option 2: Send the message and continue the session
        //        sel_2_from_2_ifc() >>>| 
        //        session_send_ifc(Ifc.Tagged.getNew(userInput, (at() : Level[Bob]))) >>>|
        //        zero_ifc() >>>= 
        //        (_ -> clientLoopWorks(lineCount + 1))
        //);
        
        enter_ifc() >>>= (_ -> _client_loop_no_infer(0))
    }


    def _client_ifc_works(): SessionIfc[
        CapIfc[{}, Unit, RecursionIfc[ChoiceSelection2Ifc[EmptyIfc, SendIfc[String, VarIfc[ZIfc]]]]],
        Unit, 
        Unit, 
        Chan + Console,
        Bob
    ] = {
        def clientLoopWorks(lineCount) = (
            // Prompt user for input
            let _ = Console.print("Enter something to print, q to exit: > ");
            let userInput = readln();
            
            if ("a" == "q")
                // Option 1: Send final message with line count and close connection
                sel_2_from_2_ifc() >>>|
                session_send_ifc(Ifc.Tagged.getNew("lines sent ${lineCount}", (at(): Level[Bob]))) >>>|
                zero_ifc() >>>| 
                sel_1_from_2_ifc() >>>| 
                session_close_ifc() 
            else
                // Option 2: Send the message and continue the session
                sel_2_from_2_ifc() >>>| 
                session_send_ifc(Ifc.Tagged.getNew(userInput, (at() : Level[Bob]))) >>>|
                zero_ifc() >>>= 
                (_ -> clientLoopWorks(lineCount + 1))
        );
        
        enter_ifc() >>>= (_ -> clientLoopWorks(0))
    }

    /**
     * Main entry point that sets up and runs the client-server example.
     * Creates a rendezvous point, spawns the server in a separate task,
     * and connects the client to the server.
     */
    pub def execute_ifc_server_example(): Unit \ IO + Chan + NonDet = {
        run{
            region sessionRegion {
                let rendezvousPoint = new_rendezvous_ifc();
                spawn session_accept_ifc(rendezvousPoint, _server_ifc(), (at(): Level[Bob])) @ sessionRegion;
                session_request_ifc(rendezvousPoint, _client_ifc(), (at(): Level[Bob]))
            }
        } with Console.runWithIO
    }
}