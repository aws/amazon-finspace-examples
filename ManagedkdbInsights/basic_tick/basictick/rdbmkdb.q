//Basic rdb process

show "RDB: START"
show system "pwd"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
dbname:first params`dbname
codebase:first params`codebase
tphostfile:first params`tphostfile
tp:first params`tp

/ assign paths
app_path: "/opt/kx/app"

dbpath: app_path, "/db/", dbname
codepath: app_path, "/code/", codebase

/ If database exists, mount it
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; system "l ", dbpath;];
    [show "no database at: ", dbpath;]]

/ if code directory exists, cd to it
$[count key hsym `$codepath;[ show "cd to code directory: ", codepath; system "cd ", codepath;];
    [show "no code at: ", codepath;]];

/----
/ What should also come from the command line
/tp: read0`$tphostfile
/cmdline: raze (enlist "-tp"; `$tp)
cmdline: ("-tp"; tp)
show cmdline
/----

/ BEGIN load libraries relative to the codepath

/Load in lib for querying data and example schema
\l connectmkdb.q
\l query.q
\l example.schema.q

/ END load libraries

/set upd func
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
    /Attempt tp connect to tp. If success sub to tables and turn off timer
    if[.conn.connectToProcs[`tp;zx];
        show"connected to tp";
        .rdb.onTpConnect[exec first handle from .conn.procs where process=`tp];
        .z.ts:{};
        .rdb.tpConnectWait:1;
        :()
        ];

    /If could not connect to tp, increment wait timer by second (backoff) and set to reconnect.
    .rdb.tpConnectWait+:1;
    .z.ts:{.rdb.establishTpConnection[zx]};
    show"Could not establish connection to tp waiting ",string[.rdb.tpConnectWait]," seconds";
    system"t ",string 1000* .rdb.tpConnectWait;
    }


init:{[zx]
    /if handle closes mark it in conn tab and set to reconnect
    .z.pc:{[h]
        .conn.handleDrop[h];
        .rdb.establishTpConnection[zx];
        };


    .rdb.establishTpConnection[zx]
    }

note:" " sv ("RDB: init "; string(.z.z))
show note

init[cmdline]

/ must be in this path for db reads to work
system "cd /opt/kx"

/ count partitioned tables
count each value each tables[]

show "RDB: DONE"
show system "pwd"
