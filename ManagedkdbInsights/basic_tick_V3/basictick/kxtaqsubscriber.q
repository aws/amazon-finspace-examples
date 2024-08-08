/file = kxtaqsubscriber.q
/description = subscriber to calc q process running within finspace
/usage = nohup /usr/bin/rlwrap /taq/demo/q/l64/q kxtaqsubscriber.q -p 5040 -endpoint `:host:port:user:pass -mode [trade_last | trade_vwap | trade_last] > /dev/null 2>&1 &
\c 500 500

cmdline:.Q.opt .z.x
/show cmdline

/open connection to calc process
calc:hopen`$first cmdline`endpoint

/function on calc
mode:`trade_last^`$first cmdline`mode

/ call function on calc
calc(`.u.subSnap;mode;`)

upd:{[t;x]
    stats:select receiveTime:.z.P, source_to_calc_latency:calcTs-time, source_to_consumer_latency:.z.P-time from x;
/-1"latency from FH -> FinSpace -> External Subscriber:  ",.Q.s1 distinct stats`source_to_consumer_latency; 
    .perf.stats,:stats
    }