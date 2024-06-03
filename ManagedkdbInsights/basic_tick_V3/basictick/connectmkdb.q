/Processes can get connection info via cmd line bootup, e.g. -tp 5001
/Therefore parse cmd line info. If doesn't exist we need state from somewhere else.

.conn.procs:([]process:`$();address:`symbol$();handle:`int$();connected:`boolean$());

.conn.parseCmd:{[defaults;zx]
    /grab command line and parse
    dict:.Q.def[defaults].Q.opt zx;
    /If there are multiple of same services need to reformat conn dict
    (raze value (count each dict)#'key dict)!raze value dict
    }

/Give list of processes to connect to, returns table of procs and ports
.conn.getConnDetails:{[procs;zx]
    
    /Attempt to get conn details from cmd line
    defaults:((),procs)!(enlist each count[procs]#`);
    connDetails:.conn.parseCmd[defaults;zx];

    /If any are null then we need to look elsewhere for conn details
    if[sum raze null connDetails;
        
        /See if we have a local service manager connections for the processes we want (outdated)
        if[count key `.lsm.bootstrap.connections;
            connDetails:.conn.setConnectionsFromLsm[procs];
            ];
        
        /See if we have env variables for conn details set
        if[not first null peers:(),value getenv[`peers] except ",";
            connDetails:(`$first each "_" vs/:string[peers])!(),/:value each (),getenv each peers;
            :ungroup([]process:key connDetails;address:value connDetails;handle:0Ni;connected:0b)
            ];

        /If still no conn details log and exit
        if[sum raze null connDetails;
            show"No connection details for dependencies - terminating";
            exit 0;
            ];
        ];
    
    /Return table with procs and ports
    ([]process:key connDetails;address:value connDetails;handle:0Ni;connected:0b)
    }



/Give list of procs. Set handles into .conn.connections
.conn.connectToProcs:{[procs;zx]
    /if no connection info, grab and set
    if[not count .conn.procs;
        .conn.procs:.conn.getConnDetails[procs;zx];
        ];

    .conn.connectDisconnected[];

    /return boolean for success of all connections
    all .conn.procs`connected

    }

/Attempts to reconnect any procs that are not connected
.conn.connectDisconnected:{[]
    /Connect to any procs not connected to
    update handle:.conn.connect each address from `.conn.procs where not connected;
    update connected:1b from `.conn.procs where not null handle;
    }

/basic connect with err trap
.conn.connect:{[address]
    @[hopen;address;0Ni]
    }

/func to update procs table for any droppped handles
.conn.handleDrop:{[dropped]
    update handle:0Ni, connected:0b from `.conn.procs where handle=dropped;
    }

/If we have booted system using the local service manager we can get connection info from there
.conn.setConnectionsFromLsm:{[procs]
    details:0!select port by service from .lsm.bootstrap.connections where service in procs;

    /If there isn't any matched connection info, return null procs dict
    if[not count details;
        :procs!(count[procs]#0Nj);
        ];

    connDict:details[`service]!details[`port];
    
    connDict
    }
