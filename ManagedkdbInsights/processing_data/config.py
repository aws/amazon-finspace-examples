DB_NAME="DEMO_DB"
DBVIEW_NAME=f"{DB_NAME}_VIEW"
SCALING_GROUP_NAME="DEMO_SCALING_GROUP"
VOLUME_NAME="DEMO_SHARED_VOLUME"
CODEBASE="demo"

CLUSTER_NAME="demo_csv_cluster"
HDB_CLUSTER_NAME="demo_hdb_cluster"

# S3 Destinations
S3_CODE_PATH="code"
S3_DATA_PATH="data"
SOURCE_DATA_DIR="demo"

clusters=[ CLUSTER_NAME, HDB_CLUSTER_NAME ]
