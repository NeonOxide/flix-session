/**
 * Session Type to DOT graph converter using traits
 * 
 * This library generates DOT language representations of session types
 * using traits to handle each protocol constructor.
 */
mod SessionGraph {
use SessionGraph.Graphable

    def gen_node_name(cluster: String, counter: Int32) : String = 
        if (cluster == "") {"n_${counter}"} else {"n_${cluster}_${counter}"}  

    /**
    * GraphPrintable trait for generating a DOT representation of a protocol.
    */
    trait Graphable[protocol] {
        pub def generate_dot_graph_representation(_: Proxy[protocol], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev : String, rec_edges : Set[(String, String)]) : (String, Set[(String, String)])
    }

    

instance Graphable[Int32] {
    pub def generate_dot_graph_representation(_: Proxy[Int32], _: String, _: Int32, _: List[String], _: String, _: Set[(String, String)]): (String, Set[(String, String)]) = ("Int32", Set#{})
}

instance Graphable[String] {
    pub def generate_dot_graph_representation(_: Proxy[String], _: String, _: Int32, _: List[String], _: String, _: Set[(String, String)]): (String, Set[(String, String)]) = ("String", Set#{})
}
    
    instance Graphable[Empty] {
        pub def generate_dot_graph_representation(_: Proxy[Empty], cluster: String, cluster_counter: Int32, _: List[String], prev: String, _: Set[(String, String)]) : (String, Set[(String, String)]) = 
        let node_name = gen_node_name(cluster, cluster_counter);
        let node_decl = " ${node_name}[label=\"End\", shape=Msquare]";
        (" ${prev} ${node_name};${node_decl};\n", Set#{})
    }
    
    instance Graphable[Receive[payload, next]] with Graphable[payload], Graphable[next] {
        pub def generate_dot_graph_representation(_: Proxy[Receive[payload, next]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
        let node_name = gen_node_name(cluster, cluster_counter);
        let node_decl = " ${node_name}[label=\"Receive ${fst(Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[payload]), cluster, cluster_counter, recursion_nodes, prev, rec_edges))}\"]";
        let (next_str, new_rec_edges) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[next]), cluster, cluster_counter + 1, recursion_nodes, node_name + " ->", rec_edges);
        (" ${prev} ${node_name};\n ${node_decl};\n ${next_str}", new_rec_edges)
    }
    
    instance Graphable[Send[payload, next]] with Graphable[payload], Graphable[next] {
        pub def generate_dot_graph_representation(_: Proxy[Send[payload, next]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
        let node_name = gen_node_name(cluster, cluster_counter);
        let node_decl = " ${node_name}[label=\"Send ${fst(Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[payload]), cluster, cluster_counter, recursion_nodes, prev, rec_edges))}\"]";
        let (next_str, new_rec_edges) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[next]), cluster, cluster_counter + 1, recursion_nodes, node_name + " ->", rec_edges);
        (" ${prev} ${node_name};\n ${node_decl};\n ${next_str} ", new_rec_edges)
    }

    instance Graphable[Recursion[body]] with Graphable[body] {
        pub def generate_dot_graph_representation(_: Proxy[Recursion[body]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
        // Generate the name of the node contained within which is the one pointed by the recursion
        let node_name_rec = gen_node_name(cluster, cluster_counter);
        Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[body]), cluster, cluster_counter, node_name_rec::recursion_nodes, prev, rec_edges)
    }
    instance Graphable[Z] {
        pub def generate_dot_graph_representation(_: Proxy[Z], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
            let node_name = gen_node_name(cluster, cluster_counter);
                let node_decl = " ${node_name}[label=\"Loop\"]";
                (" ${prev} ${node_name};\n ${node_decl};" , Set.insert((node_name, Option.getWithDefault("ERROR", List.head(recursion_nodes))), rec_edges))
    }

    instance Graphable[Suc[pred]] with Graphable[pred] {
        pub def generate_dot_graph_representation(_: Proxy[Suc[pred]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
            Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[pred]), cluster, cluster_counter, List.drop(1, recursion_nodes), prev, rec_edges)
    }

    instance Graphable[Var[index]] with Graphable[index]{
        pub def generate_dot_graph_representation(_: Proxy[Var[index]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
            Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[index]), cluster, cluster_counter, recursion_nodes, prev, rec_edges)

        
        
        
    }

    instance Graphable[ChoiceOffer2[branch1, branch2]] with Graphable[branch1], Graphable[branch2] {
        pub def generate_dot_graph_representation(_: Proxy[ChoiceOffer2[branch1, branch2]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
        let node_name = gen_node_name(cluster, cluster_counter);
        let node_decl = " ${node_name}[label=\"Choice Offer\", shape=trapezium]";
        let new_cluster1 = "${cluster}1";
        let new_cluster2 = "${cluster}2";
        let (next_str1, rec_edges1) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[branch1]), new_cluster1, 0, recursion_nodes, "", rec_edges);
        let (next_str2, rec_edges2) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[branch2]), new_cluster2, 0, recursion_nodes, "", rec_edges);
        (" ${prev} ${node_name};\n ${node_decl};\n  " +
         + " ${node_name} -> ${gen_node_name(new_cluster1, 0)};\n subgraph cluster_${new_cluster1} { label = \"branch ${new_cluster1}\";\n ${next_str1}}"
         + " ${node_name} -> ${gen_node_name(new_cluster2, 0)};\n subgraph cluster_${new_cluster2} { label = \"branch ${new_cluster2}\";\n ${next_str2}}" 
        , Set.union(rec_edges1, rec_edges2) )
    }

    instance Graphable[ChoiceSelection2[branch1, branch2]] with Graphable[branch1], Graphable[branch2] {
        pub def generate_dot_graph_representation(_: Proxy[ChoiceSelection2[branch1, branch2]], cluster: String, cluster_counter: Int32, recursion_nodes: List[String], prev:String, rec_edges: Set[(String, String)]) : (String, Set[(String, String)]) = 
        let node_name = gen_node_name(cluster, cluster_counter);
        let node_decl = " ${node_name}[label=\"Choice Selection\", shape=invtrapezium]";
        let new_cluster1 = "${cluster}1";
        let new_cluster2 = "${cluster}2";
        let (next_str1, rec_edges1) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[branch1]), new_cluster1, 0, recursion_nodes, "", rec_edges);
        let (next_str2, rec_edges2) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[branch2]), new_cluster2, 0, recursion_nodes, "", rec_edges);
        (" ${prev} ${node_name};\n ${node_decl};\n  " +
         + " ${node_name} -> ${gen_node_name(new_cluster1, 0)};\n subgraph cluster_${new_cluster1} { label = \"branch ${new_cluster1}\";\n ${next_str1}}"
         + " ${node_name} -> ${gen_node_name(new_cluster2, 0)};\n subgraph cluster_${new_cluster2} { label = \"branch ${new_cluster2}\";\n ${next_str2}}" 
         , Set.union(rec_edges1, rec_edges2))
    }


    pub def generate_single_dot_graph(_: Session[Cap[_env, start], Unit, resultType, effects], graph_name: String) : String  with Graphable[start] = 
        let (text, rec_edges) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[start]), "", 0, Nil, "start ->", Set#{});
        let acc_f = (text_acc: String) -> (e: (String, String)) -> "${text_acc}${fst(e)} -> ${snd(e)}[constraint=false];\n";
        let edges_text : String = Set.foldLeft(acc_f, "", rec_edges);
        "digraph ${graph_name} {\n ${text} \n ${edges_text} start [shape=Mdiamond];\n}"

    //pub def generate_single_dot_graph(_: Session[Cap[_env, start], Unit, resultType, effects], graph_name: String) : String  with Graphable[start], HasDual[start], Graphable[example] 
    //                                                                                                                    where  HasDual.Dual[start] ~ example = 
    //    let (text, rec_edges) = Graphable.generate_dot_graph_representation((Proxy.Proxy: Proxy[start]), "", 0, Nil, "start ->", Set#{});
    //    let acc_f = (text_acc: String) -> (e: (String, String)) -> "${text_acc}${fst(e)} -> ${snd(e)}[constraint=false];\n";
    //    let edges_text : String = Set.foldLeft(acc_f, "", rec_edges);
    //    "digraph ${graph_name} {\n ${text} \n ${edges_text} start [shape=Mdiamond];\n}"
}