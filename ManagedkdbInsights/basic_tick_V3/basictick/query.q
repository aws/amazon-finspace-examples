/Define basic query function to load into rdb/hdb
/queryData[`trade;`IBM`MSFT;.z.P-2D02;.z.P]

.query.data:{[table;syms;start;end]
    .debug.query:(table;syms;start;end);
    -1 "Query Received for .query.data -", .Q.s1[.debug.query];
    wc:$[`~syms;();enlist(in;`sym;(),syms)];
    wc,:enlist (within;`time;(enlist;start;end));

    /check if hdb
    isHDB:`date in key `.;
    $[isHDB;
        [
         wc:enlist[(within;`date;"d"$(start;end))],wc;
         res:?[table;wc;0b;()]
        ];
        [
         res:?[table;wc;0b;()];
         res:`date`sym`time xcols update date:.z.D from res
        ]
     ];
             
    delete date from update source:`RDB`HDB isHDB from res
    }