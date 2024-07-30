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

.rdb.procName:"RDB_basictickdb"
.rdb.savePath:"/opt/kx/app/shared/RDB_TP_SHARED/",.rdb.procName,"/"
.rdb.database:"basictickdb"
.rdb.hdbProc:"HDB_basictickdb"
.rdb.dbView:"basictickdb_DBVIEW"

/ dbpath
dbpath: "/opt/kx/app/db/", dbname

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the code directory

/ Load in lib for querying data and example schema
\l connectmkdb.q
\l query.q

/ END load libraries

/ set upd func
upd:insert;

/ end of day: save, clear, hdb reload
/.u.end:{t:tables`.;t@:where `g=attr each t@\:`sym;.Q.hdpf[`$":",.u.x 1;`:.;x;`sym];@[;`sym;`g#] each t;};

/ init schema and sync up from log file;cd to hdb(so client save can run)
.u.rep:{(.[;();:;].)each x;if[null first y;:()];-11!y;};

/ HARDCODE \cd if other than logdir/db
/ connect to ticker plant for (schema;(logcount;log))
/.u.rep .(hopen `$":",.u.x 0)"(.u.sub[`;`];`.u `i`L)";

.rdb.onTpConnect:{[handle]
    show"Subscribed to TP";
    /sub to all tables
    .u.rep . handle"(.u.sub[`;`];`.u `i`L)"
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


diR:{$[11h=type d:key x;raze x,.z.s each` sv/:x,/:d;d]}
nuke:hdel each desc diR@

pushChangeset:{[d]
     dt:string d;
     dict:flip`input_path`database_path`change_type!(
        (`$.rdb.savePath,dt;`$.rdb.savePath,"sym");
        (`$"/",dt,"/";`$"/");`PUT`PUT);
    .aws.create_changeset[.rdb.database;dict];
    }

.u.end:{
     -1 "Running EOD Function for date = ", string[x];
     t:tables`.;
     -1 "Table Counts pre-EOD = ", .Q.s1[t!count each value each t];
     t@:where `g=attr each t@\:`sym;
     -1 "Downloading latest sym file";
     .aws.get_latest_sym_file[.rdb.database;.rdb.savePath];
     {.Q.dpft[hsym`$.rdb.savePath;x;`sym;y]}[x] each t;
     cid:pushChangeset[x];
     sleep:{t:.z.p; while[.z.p<t+`second$x;]};
     sleep 30;
     dview:wait_for_status[.aws.get_kx_dataview;(.rdb.database;.rdb.dbView);("ACTIVE";"FAILED");00:00:20;30:00];
     updateCluster[.rdb.hdbProc;.rdb.database;.rdb.dbView;"NO_RESTART"];
     sleep 30;
     res:wait_for_status[.aws.get_kx_cluster;enlist .rdb.hdbProc;("RUNNING";"FAILED");00:00:20;30:00];
     if["FAILED"~res`status;
         -1 "Cluster Failed to Restart - returning early";
        :()
      ];
     nuke hsym`$.rdb.savePath,string[x];
     hdel hsym`$.rdb.savePath,"sym";
     {x set 0#`.[x]}each t;
     @[;`sym;`g#] each t;
     .Q.gc[];
 }

updateCluster:{[cluster;database;dataview;strategy]
  res:.aws.update_kx_cluster_databases[cluster;
    .aws.sdbs[
        .aws.db[database;"";
            {()}.aws.cache["CACHE_1000";"/"];
            dataview
            ]
        ];
    .aws.sdep[strategy]];
    res
    }
  
wait_for_status:{[function;args;statuses;frequency;timeout]
  res:function . args;
  st:.z.t;
  l:0;
  $[10h=type statuses;statuses:enlist statuses;]
  while [(timeout>ti:.z.t-st) & not (res`status) in statuses;
     $[frequency<=ti-l;
         (
            l:ti;
            res:function . args;
            show "Status: ", (res`status), " waited: ", string(ti)
         );
     ]
   ];
   show "** Done **";
   res
 }

init:{[tp_name]
    zx: .rdb.getDataNodes[tp_name];
    .rdb.establishTpConnection[zx]
    }

note:" " sv ("RDB: init "; string(.z.z))
show note

init[tp_name]

/ must be in this path for db reads to work
system "cd /opt/kx"

show "RDB: DONE"
