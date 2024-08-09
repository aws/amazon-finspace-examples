/ Basic RTS process (leveraging rdbmkdb.q)
show "RTS: START"
show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ cd to code directory
\cd /opt/kx/app/code
\l connectmkdb.q
tp_name:first params`tp

lastTime:.z.t;

/daily high-low-close-volume
trade_hlcv:([sym:`$()]high:`float$();low:`float$();close:();volume:());
trade_vwap:([sym:`$()]vwap:`float$();volume:`long$())
trade_last:([sym:`$()]time:`timestamp$();price:`float$();size:`long$())

.rdb.onTpConnect:{[handle]
    show"Subscribed to TP";
    /sub to all tables
    .u.rep . handle"(.u.sub[`;`];`.u `i`L)"
    }

.rdb.establishTpConnection:{[zx]
    / Attempt tp connect to tp. If success sub to tables and turn off timer
    if[.conn.connectToProcs[`tp;zx];
        show"connected to TP";
        .rdb.onTpConnect[exec first handle from .conn.procs where process=`tp];
        .awscust.z.ts:{};
        .rdb.tpConnectWait:1;
        :()
        ];

    / If could not connect to tp, increment wait timer by second (backoff) and set to reconnect.
    .rdb.tpConnectWait+:1;
    .awscust.z.ts:{[x;zx].rdb.establishTpConnection[zx]}[;zx];
    show"Could not establish connection to TP waiting ",string[.rdb.tpConnectWait]," seconds";
    system"t ",string 1000* .rdb.tpConnectWait;
    }

.rdb.getDataNodes:{[tp_name]
    tp_nodes: .aws.list_kx_cluster_nodes[tp_name];

    tp_conn_strs: {.aws.get_kx_node_connection_string[tp_name;x]} each tp_nodes`node_id;

    raze (enlist "-tp"; tp_conn_strs)
    }


/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;};

tag:{update calcTs:.z.P, state:x from y};

/last
upd_last:{[t;x]
    .[`trade_last;();,;latest:select by sym from x];
    .u.pub[`trade_last;tag[`stream] latest];
    }  

/vwap
upd_vwap:{[t;x] 
    trade_vwap+:latest:select vwap:size wavg price,volume:sum size by sym from x;
    .u.pub[`trade_vwap;tag[`stream] latest];
    } 

/hlcv
upd_hlcv:{[t;x]
    join:(0!trade_hlcv),select sym,high:price,low:price,close:price,volume:size from x;
    trade_hlcv::latest:select max high,min low,last close,sum volume by sym from join;
    .u.pub[`trade_hlcv;tag[`stream] latest];
    }

upd:{[t;x]
    if[t~`trade;
        upd_last[t;x];
        upd_vwap[t;x];
        upd_hlcv[t;x];
        ];
    }

.awscust.z.ts:{}

getSnap_vwap:{[x] select from trade_vwap where sym in x} 
getSnap_last:{[x] select from trade_last where sym in x} 
getSnap_hlcv:{[x] select from trade_hlcv where sym in x} 

// snap function handlers
.stream.snap:`trade_vwap`trade_hlcv`trade_last!(getSnap_vwap;getSnap_hlcv;getSnap_last)

// add .u.snap to support snapshots
.u.snap:{[x]
    tag[`snap] .stream.snap[x 0]x 1
    }

.u.subSnap:{[x;y]
    .u.sub .(x;y);
    .u.snap (x;y)
    }

\t 5000

/ load datafilter analytics
/\l sample/dfilt.q_
/\l sample/querybuilder.q

init:{[tp_name]
    zx: .rdb.getDataNodes[tp_name];
    .rdb.establishTpConnection[zx]
    } 

// initialise kdb+tick 
// all tables in the top level namespace (`.) become publish-able
// tables that can be published can be seen in .u.w
\l tick/u.q
.u.init[];

note:" " sv ("RTS: init "; string(.z.z))
show note

init[tp_name] 

/ must be in this path for db reads to work
\cd /opt/kx/app

show "RTS: DONE"
