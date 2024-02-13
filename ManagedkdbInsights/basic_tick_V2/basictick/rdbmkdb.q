/ Basic rdb process
show "RDB: START"
/.z.zd:(17;2;7)

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
dbname:first params`dbname
tphostfile:first params`tphostfile
tp_name:first params`tp

/ dbpath
dbpath: "/opt/kx/app/db/", dbname

/ If database exists, mount it
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; .Q.l `$dbpath;];
    [show "no database at: ", dbpath;]]

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the code directory

/ Load in lib for querying data and example schema
\l connectmkdb.q
\l query.q
\l example.schema.q

/ END load libraries

/ set upd func
upd:upsert;

.rdb.subToTable:{[tpHandle;table;syms]
    tpHandle(`.tp.sub;table;syms);
    show"Subscribed to ",string[table];
    }

.rdb.onTpConnect:{[handle]
    /sub to all tables in root
    .rdb.subToTable[handle;;`] each tables[]
    }

.rdb.establishTpConnection:{[zx]
    / Attempt tp connect to tp. If success sub to tables and turn off timer
    if[.conn.connectToProcs[`tp;zx];
        show"connected to tp";
        .rdb.onTpConnect[exec first handle from .conn.procs where process=`tp];
        .awscust.z.ts:{};
        .rdb.tpConnectWait:1;
        :()
        ];

    / If could not connect to tp, increment wait timer by second (backoff) and set to reconnect.
    .rdb.tpConnectWait+:1;
    .awscust.z.ts:{[x;zx].rdb.establishTpConnection[zx]}[;zx];
    show"Could not establish connection to tp waiting ",string[.rdb.tpConnectWait]," seconds";
    system"t ",string 1000* .rdb.tpConnectWait;
    }

.rdb.getDataNodes:{[tp_name]
    tp_nodes: .aws.list_kx_cluster_nodes[tp_name];

    tp_conn_strs: {.aws.get_kx_node_connection_string[tp_name;x]} each tp_nodes`node_id;

    raze (enlist "-tp"; tp_conn_strs)
    }

init:{[tp_name]
    zx: .rdb.getDataNodes[tp_name];

    / if handle closes mark it in conn tab and set to reconnect
    .awscust.z.pc:{[h;zx]
        .conn.handleDrop[h];
        .rdb.establishTpConnection[zx];
        }[;zx];

    .rdb.establishTpConnection[zx]
    }

note:" " sv ("RDB: init "; string(.z.z))
show note

init[tp_name]

/ must be in this path for db reads to work
system "cd /opt/kx"

show "RDB: DONE"
