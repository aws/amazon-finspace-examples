SCALING_GROUP_NAME="SCALING_GROUP_torq"
VOLUME_NAME="SHARED_torq"
DB_NAME="finspace-database"
DBVIEW_NAME=f"{DB_NAME}_DBVIEW"

clusters = [
    {
        "name": "discovery1",
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
        "name": "rdb1",
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
        "name": "hdb1",
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
    {
        "type": "WAIT",
        "name": "discovery1"
    },
    {
        "type": "WAIT",
        "name": "rdb1"
    },
    {
        "name": "gateway1",
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
        "name": "feed1",
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
    {
        "name": "monitor1",
         "type": "GP",
         "init": "TorQ-Amazon-FinSpace-Starter-Pack/finspace_torq.q",
         "args": [
            { 'key': 'proctype', 'value': 'monitor'}, 
            { 'key': 'procname', 'value': 'monitor1' }, 
            { 'key': 'jsonlogs', 'value': 'true'}, 
            { 'key': 'noredirect', 'value': 'true'}, 
            { 'key': 's', 'value': '1' }, 
        ]
    },
]    

