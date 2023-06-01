/Define basic query function to load into rdb/hdb
.query.data:{[table;syms]
    wc:$[`~syms;();enlist(in;`sym;syms)];
    delete date from ?[table;wc;0b;()]
    }


