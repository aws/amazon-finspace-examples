SCALING_GROUP_NAME="SCALING_GROUP_dbmaint"
VOLUME_NAME="DBMAINT_VOLUME"

# Managed KX Database and View
DB_NAME="dbmaintdb"

MAINT_CLUSTER_NAME ="dbmaint_cluster_maint"
QUERY_CLUSTER_NAME ="dbmaint_cluster_query"

MAINT_DBVIEW_NAME=f"{DB_NAME}_DBVIEW_MAINT"
QUERY_DBVIEW_NAME=f"{DB_NAME}_DBVIEW_QUERY"

all_clusters = [ MAINT_CLUSTER_NAME, QUERY_CLUSTER_NAME ]
all_views    = [ MAINT_DBVIEW_NAME, QUERY_DBVIEW_NAME ]

