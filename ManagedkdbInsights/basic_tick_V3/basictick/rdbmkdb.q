/ Basic rdb process
show "RDB: START"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
tp_name:first params`tp

.rdb.procName:first params`procName
.rdb.volumeName:first params`volumeName
.rdb.hdbProc:first params`hdbProc
.rdb.dbView:first params`dbView

.rdb.savePath:"/opt/kx/app/shared/",.rdb.volumeName,"/",.rdb.procName,"/"
.rdb.database:.aws.akdb 

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the code directory

/ Load in lib for querying data and example schema
\l connectmkdb.q
\l query.q

/ END load libraries

/ file deletion functions
diR:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]}
nuke:hdel each desc diR@


/ set upd func
upd:insert;

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;};

.rdb.onTpConnect:{[handle]
    show"Subscribed to TP";
    /sub to all tables
    .u.rep . handle"(.u.sub[`;`];`.u `i`L)"
    }

.rdb.establishTpConnection:{[zx]
    / Attempt tp connect to tp. If success sub to tables and turn off timer
    if[.conn.connectToProcs[`tp;zx];
        show"Connected to TP";
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


.rdb.sleep:{t:.z.p; while[.z.p<t+`second$x;]}


.rdb.updateCluster:{[cluster;database;dataview;strategy]
  res:.aws.update_kx_cluster_databases[cluster;
    .aws.sdbs[
        .aws.db[database;"";
            {()}.aws.cache["CACHE_250";"/"];
            dataview
            ]
        ];
    .aws.sdep[strategy]];
    res
    }


.rdb.wait_for_status:{[function;args;statuses;frequency;timeout]
  res:function . args;
  st:.z.t;
  l:0;
  $[10h=type statuses;statuses:enlist statuses;]
  while [(timeout>ti:.z.t-st) & not (res`status) in statuses;
     $[frequency<=ti-l;
         (
            l:ti;
            res:function . args;
            show "Waiting: ", sv[" "; args], " status: ", (res`status), " waited: ", string(ti)
         );
     ]
   ];
   show "** Done: ", sv[" "; args]," **";
   res
 }


/ Publishes a changeset given a directory
.rdb.pushChangeset:{[d]
     dt:string d;
     dict:flip`input_path`database_path`change_type!(
        (`$.rdb.savePath,dt;`$.rdb.savePath,"sym");
        (`$"/",dt,"/";`$"/");`PUT`PUT);
    cid:.aws.create_changeset[.rdb.database;dict];
    cid
    }


.rdb.eod:{
    -1 "EOD Processing date: ", string[x];
    t:tables`.;
    t@:where `g=attr each t@\:`sym;
    -1 "Table Counts pre-EOD: ", .Q.s1[t!count each value each t];
    -1 "Downloading latest sym file";
    .aws.get_latest_sym_file[.rdb.database;.rdb.savePath];
    -1 "Saving tables";
    {.Q.dpft[hsym`$.rdb.savePath;x;`sym;y]}[x] each t;
    -1 "Pushing Changeset";
    cid:.rdb.pushChangeset[x];
    -1 "Waiting for changset: ", cid`id;
    res:.rdb.wait_for_status[.aws.get_changeset;(.rdb.database;cid`id);("COMPLETED";"FAILED");00:00:20;30:00];

    dview:.aws.get_kx_dataview[.rdb.database;.rdb.dbView];
    -1 "Autoupdating Dataview? ", string [dview`auto_update], " database: ", .rdb.database, " view: ", .rdb.dbView;
    if[0=dview`auto_update; .aws.update_kx_dataview[.rdb.database;.rdb.dbView;cid`id;dview`segment_configurations]];
    res:.rdb.wait_for_status[.aws.get_kx_dataview;(.rdb.database;.rdb.dbView);("ACTIVE";"FAILED");00:00:20;30:00];
    
    -1 "Updating Cluster: ", .rdb.hdbProc;
    .rdb.updateCluster[.rdb.hdbProc;.rdb.database;.rdb.dbView;"NO_RESTART"];
    res:.rdb.wait_for_status[.aws.get_kx_cluster;enlist .rdb.hdbProc;("RUNNING";"FAILED");00:00:20;30:00];
    
    if["FAILED"~res`status;
        -1 "Cluster Failed to Restart, returning early";
        :()
    ];

    -1 "EOD Clean up ";
    / clear tables
    {x set 0#`.[x]}each t;
    @[;`sym;`g#] each t;
    / delete files 
    nuke hsym`$.rdb.savePath,string[x];
    hdel hsym`$.rdb.savePath,"sym";
    / garbage collect
    .Q.gc[];
    }


/ Account for a static or auto-updating for EOD processing
.u.end:{
    .rdb.eod[x]
    }
init:{[tp_name]
    zx: .rdb.getDataNodes[tp_name];
    .rdb.establishTpConnection[zx]
    }


show "RDB Init: ", string[.z.z]

init[tp_name]

/ must finished at this path for db reads to work
\cd /opt/kx/app

show "RDB: DONE"
