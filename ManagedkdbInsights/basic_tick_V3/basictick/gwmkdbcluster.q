show "GW: START"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
rdb_name:first params`rdb_name
hdb_name:first params`hdb_name

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the codepath

\l connectmkdb.q

/ This lib should not be compiled as it has func to send down the handle
\l funcDownHandle.q

/ END load libraries

/ func to query gw with to dispact to random rdb and hdb
queryData:{[table;syms]

    targets:.gw.getTargets[];

    results:targets@\:(`.query.data;table;syms);
    (uj/) results
    }

/get handles for a hdb and rdb
.gw.getTargets:{[]

   rdbs:0Ni^exec handle from .conn.procs where connected,process=`rdb;
   hdbs:0Ni^exec handle from .conn.procs where connected,process=`hdb;

   targets:raze 1?/:(rdbs;hdbs);
   targets:targets where not null targets;
   if[not count targets;
        '"No available data nodes";
        ];
    targets
    };

/ Every 10 seconds connect to data nodes unless all are connected.
.gw.connectToDataNodes:{[zx]
    .conn.connectToProcs[`rdb`hdb;zx];
    };

.gw.getDataNodes:{[hdb_name; rdb_name]
    hdb_nodes: .aws.list_kx_cluster_nodes[hdb_name];
    rdb_nodes: .aws.list_kx_cluster_nodes[rdb_name];

    rdb_conn_strs: {.aws.get_kx_node_connection_string[rdb_name;x]} each rdb_nodes`node_id;
    hdb_conn_strs: {.aws.get_kx_node_connection_string[hdb_name;x]} each hdb_nodes`node_id;

    raze (enlist "-hdb"; hdb_conn_strs; enlist "-rdb"; rdb_conn_strs)
    };
    

init:{[hdb_name; rdb_name]
    zx: .gw.getDataNodes[hdb_name; rdb_name];

    .gw.connectToDataNodes[zx];

    .awscust.z.ts{[]
        /If not all nodes connected - attempt to reconnect
        if[not all .conn.procs`connected;
            show"Attempting to connect to disconnected data nodes...";
            .conn.connectDisconnected[];
            if[all .conn.procs`connected;
                show"All connected!";
                ];
            ];
        };

    .awscust.z.pc:.conn.handleDrop;

    /Attempt recon every 10s
    system"t 10000";
    }

reinit:{[hdb_name; rdb_name]
    delete from `.conn.procs;
    init[hdb_name; rdb_name];
    }

init[hdb_name; rdb_name]

show "GW: DONE"
