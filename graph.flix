/**
 * Session Type to DOT graph converter using traits
 * 
 * This library generates DOT language representations of session types
 * using traits to handle each protocol constructor.
 */
mod SessionGraph {
use SessionGraph.Graphable
use SessionGraph.generate_dot_graph

    /**
    * GraphPrintable trait for generating a DOT representation of a protocol.
    */
    sealed trait Graphable[protocol] {
        pub def generate_dot_graph_representation(_: Proxy[protocol]) : String
    }

    instance Graphable[Empty] {
        pub def generate_dot_graph_representation(_: Proxy[Empty]) : String = "End"
    }
    instance Graphable[Receive[payload, next]] with Graphable[payload], Graphable[next] {
        pub def generate_dot_graph_representation(_: Proxy[Receive[payload, next]]) : String = 
        " (Receive " + Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[payload])) + ") -> " +  
        Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[next])) + ";"
    }
    instance Graphable[Send[payload, next]] with Graphable[payload], Graphable[next] {
        pub def generate_dot_graph_representation(_: Proxy[Send[payload, next]]) : String = 
        " (Send " + Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[payload])) + ") -> " +  
        Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[next])) + ";"
    }

    instance Graphable[Recursion[proto]] with Graphable[proto] {
        pub def generate_dot_graph_representation(_: Proxy[Recursion[proto]]) : String = 
        " (Recursion) -> " +  
        Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[proto]))
    }


    pub def generate_dot_graph(_: protocol, graph_name: String) : String  with Graphable[protocol] = 
        "graph ${graph_name} {\n" + Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[protocol])) + "\n}"
}