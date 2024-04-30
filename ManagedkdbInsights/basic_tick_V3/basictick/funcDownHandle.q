/dnc
/example func that will be sent down handle from gw to rdb/hdb
.fdh.queryExample:{[]
    -3#select from `example
    }

/Only can be run on gw as dep on gw func
.fdh.sendFuncDownHandle:{[]
    targets:.gw.getTargets[];

    (uj/) targets@\:(.fdh.queryExample;::)
    }
