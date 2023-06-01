/load schema
\l example.schema.q

.tp.subscriptions:([handle:();table:()];syms:());

/set upd func
upd:upsert

/sub function
.tp.sub:{[tab;syms]
    /get .z.w
    .tp.subscriptions[(.z.w;tab)]:syms;
    }

.tp.pubTimer:{[]
    /check root tables
    .tp.selectAndPub each 0!.tp.subscriptions;

    /wipe tab
    {delete from x} each tables[];
    }

.tp.pub:{[handle;tableName;data]
    handle(`upd;tableName;data)
    }

.tp.selectAndPub:{[sub]
    wc:$[`~sub`syms;();enlist(in;sym;sub`syms)];
    
    toPub:?[sub`table;wc;0b;()];

    .tp.pub[sub`handle;sub`table;toPub];
    }

.tp.handleClose:{[h]
    delete from `.tp.subscriptions where handle=h;
    }

init:{[]
    .z.ts:.tp.pubTimer;

    .z.pc:.tp.handleClose;

    system"t 1000";
    }

init[]
