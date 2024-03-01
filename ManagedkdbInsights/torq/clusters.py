
clusters = [
    {
        "name": "discovery",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'discovery'}, 
            { 'key': 'procname', 'value': 'discovery1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '2' }, 
        ]
    },
    {
        "name": "rdb",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'rdb'}, 
            { 'key': 'procname', 'value': 'rdb1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '2' }, 
        ]
    },
    {
        "name": "hdb",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'hdb'}, 
            { 'key': 'procname', 'value': 'hdb1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '4' }, 
        ]
    },
#    {
#        "name": "wdb",
#        "type": "GP",
#         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
#         "args": [
#            { 'key': 'proctype', 'value': 'wdb'}, 
#            { 'key': 'procname', 'value': 'wdb1' }, 
#            { 'key': 'jsonlogs', 'value': 'true'}, 
#            { 'key': 'noredirect', 'value': 'true'}, 
#        ]
#    },
    {
        "type": "WAIT",
        "name": "discovery"
    },
    {
        "type": "WAIT",
        "name": "rdb"
    },
    {
        "name": "gateway",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'gateway'}, 
            { 'key': 'procname', 'value': 'gateway1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '2' }, 
        ]
    },
    {
        "name": "feed",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'tradeFeed'}, 
            { 'key': 'procname', 'value': 'tradeFeed1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '2' }, 
        ]
    },
]    

