#
# Define components of Setup
#

RDB_CLUSTER_NAME="RDB_basictickdb"
HDB_CLUSTER_NAME="HDB_basictickdb"
GW_CLUSTER_NAME ="GATEWAY_basictickdb"
TP_CLUSTER_NAME ="TP_basictickdb"
CALC_CLUSTER_NAME ="CALC_basictickdb"

all_clusters = {
    "tp": TP_CLUSTER_NAME,
    "rdb": RDB_CLUSTER_NAME,
    "hdb": HDB_CLUSTER_NAME,
    "gw" : GW_CLUSTER_NAME,
    "calc" : CALC_CLUSTER_NAME

}

SCALING_GROUP_NAME="SCALING_GROUP_basictickdb"

VOLUME_NAME="RDB_TP_SHARED"

# Managed KX Databases
DB_NAME="basictickdb"

DBVIEW_NAME=f"{DB_NAME}_DBVIEW"

# Feedhandler port to listen to
FH_PORT=5030

# Calc Engine Subscriber port to listen to
SUBSCRIBER_PORT=5040