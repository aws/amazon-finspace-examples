//Feed to generate random data for the example schema
cmdline:.z.x

/Load the dependency load library
\l connectmkdb.q

/Data generation func
.feed.genExample:{[]
    rows:first 1?10;

    ([]sym:rows?`3;time:rows#.z.p;number:rows?100)
    }

.feed.establishTpConnection:{[zx]
    /Attempt tp connect to tp. If success set timer to pub and set 1s pub time
    if[.conn.connectToProcs[`tp;zx];
        show"connected to tp";
        .z.ts:{.feed.pubToTp[]};
        system"t 10";
        .feed.tpConnectWait:1;
        :()
        ];

    /If could not connect to tp, increment wait timer by second (backoff) and set to reconnect.
    .feed.tpConnectWait+:1;
    .z.ts:{[x;zx].feed.establishTpConnection[zx]}[;zx];
    show"Could not establish connection to tp waiting ",string[.feed.tpConnectWait]," seconds";
    system"t ",string 1000* .feed.tpConnectWait;
    }


.feed.pubToTp:{
    data:.feed.genExample[];

    neg[exec first handle from .conn.procs where process=`tp](`upd;`example;data);
    }

init:{[zx]
    .z.pc:{[h;zx]
        .conn.handleDrop[h];
        .feed.establishTpConnection[zx];
        }[;zx];
    .feed.establishTpConnection[zx];
    }

init[cmdline]
