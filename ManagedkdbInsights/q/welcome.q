\c 100 2000

\l aws.q
\l env.q

/ Source data directory
SOURCE_DATA_DIR:"hdb"

/ S3 bucket for external data and code
S3_DEST:"s3://",S3_BUCKET,"/data/",SOURCE_DATA_DIR,"/"
CODEBASE:"qcode"
CODE_PATH:"code/",CODEBASE,".zip"

CLUSTER_NODE_TYPE:"kx.s.xlarge"
NODE_COUNT:1
CACHE_SIZE:1200

/ Managed KX Database and Cluster names to create
DB_NAME:"welcomedb"
DELETE_CLUSTER:0b
DELETE_DATABASE:0b

create_delete:1b
now: .z.Z

$[create_delete=1b; [DB_NAME:"create_delete_db_",ssr[string(`date$now);".";""],"_",raze "0"^-2$string`hh`uu$now; DELETE_CLUSTER:1b; DELETE_DATABASE:1b ]; ];

CLUSTER_NAME:"cluster_",DB_NAME

.aws.set_prefs[`envId`userName`sessionName!(ENV_ID;KDB_USERNAME;"AWSCLI-Session") ];

/ FinSpace with Managed kdb Insights lifecycle  example
/ -----------------------------------------------------------------
/ This q script mirrors the work performed in the welcome boto notebook
/ https://github.com/aws/amazon-finspace-examples/blob/main/ManagedkdbInsights/boto/welcome.ipynb
/ --
/ 1. Untar hdb.tar.gz for the hdb data
/ 2. Upload hdb to staging S3 bucket
/ 3. Create database
/ 4. Add HDB data to database
/ 5. Create a Cluster
/ 6. Get the connectionString
/ 7. Query Cluster
/ -----------------------------------------------------------------

/ 0. Check environment
/ -----------------------------------------------------------------
show .aws.get_kx_environment[ENV_ID]

/ 1. Untar hdb.tar.gz for the hdb data
/ -----------------------------------------------------------------
system ("tar -zxf hdb.tar.gz");
/show system("ls -la hdb")

/ 2. Upload hdb to staging S3 bucket
/ -----------------------------------------------------------------
system "aws s3 sync hdb ", S3_DEST;
/show system "aws s3 ls ", S3_DEST

/ 3. Create database
/ -----------------------------------------------------------------
.[.aws.create_kx_database;(DB_NAME;.aws.sdesc["demonstration database"]); {show "Database: ", DB_NAME, " already exists";}];

show "Created database: ", DB_NAME
show .aws.get_kx_database[DB_NAME];

/ 4. Add HDB data to database
/ -----------------------------------------------------------------
c_r:enlist `changeType`dbPath`s3Path!("PUT";"/";S3_DEST,())

res:.aws.create_kx_changeset[DB_NAME; c_r]

show "Adding Changeset: ", res`changesetId;

res:.aws.wait_for_status[.aws.get_kx_changeset;(DB_NAME; res`changesetId);("COMPLETED","FAILED");00:00:05;00:30:00] 

show res

changesetId:res`changesetId

/ 5. Create a Cluster
/ -----------------------------------------------------------------
/ zip code
system "cd ", CODEBASE;
system "zip -r -X ../", CODEBASE, ".zip . -x '*.ipynb_checkpoints*'";
system "cd ..";

/ copy code to S3, show S3 contents
system "aws s3 cp  ", CODEBASE, ".zip s3://", S3_BUCKET, "/code/", CODEBASE, ".zip";
/show system "aws s3 ls s3://", S3_BUCKET, "/code/";

CLUSTER_DESC: "Cluster from q API"

show "Creating Cluster: ", CLUSTER_NAME

res:.aws.create_kx_cluster[
    CLUSTER_NAME; 
    "HDB"; 
    CLUSTER_NODE_TYPE; 
    NODE_COUNT; "1.0"; 
    AZ_MODE; 
    (
        .aws.saz[AZ_ID];
        .aws.svpc[VPC_ID;SECURITY_GROUP;SUBNET_ID;""];
        .aws.sdbs[ .aws.db[DB_NAME;changesetId; .aws.cache["CACHE_1000";"/"]] ];
        .aws.scaches[.aws.ccache["CACHE_1000";1200]];
        .aws.scode[S3_BUCKET;CODE_PATH;""];
        .aws.sscript["init.q"];
        .aws.scl[ ("s";"dbname")!("2";DB_NAME) ];
        .aws.scdesc[CLUSTER_DESC] 
    ) 
 ]
show res

res:.aws.wait_for_status[.aws.get_kx_cluster;enlist CLUSTER_NAME;("RUNNING";"CREATE_FAILED");00:00:20;00:30:00]

show "Created Cluster: ", CLUSTER_NAME
show res

/ 6. Get the connectionString
/ -----------------------------------------------------------------
hdb:.aws.connect_to_cluster[CLUSTER_NAME;KDB_USERNAME]

/ 7. Query Cluster
/ -----------------------------------------------------------------
show "Querying cluster: ", CLUSTER_NAME

show hdb"tables[]"

show hdb"meta `example"

show hdb"select counts:count i, avg_num: avg number, avg_sq_num: avg sq number by date from example"

show hdb"count example"

/ clean up
/ -----------------------------------------------------------------

/ if deleting cluster ....
show "Deleting Cluster: ", CLUSTER_NAME

$[DELETE_CLUSTER=1b; [.aws.delete_kx_cluster[CLUSTER_NAME]] ]

.[.aws.wait_for_status; (.aws.get_kx_cluster;enlist CLUSTER_NAME;("DELETED";"DELETE_FAILED");00:00:20;01:00:00); {show "Cluster: ", CLUSTER_NAME, " does not exist, deleted";}];

show .aws.list_kx_clusters[ENV_ID];

/ if deleting database (and cluster was deleted) ...
show "Deleting Database: ", DB_NAME

$[DELETE_DATABASE=1b; [.aws.delete_kx_database[DB_NAME]] ]

show "Databases after delete"
show .aws.list_kx_databases[ENV_ID]

show "******** Done **********"

exit 0