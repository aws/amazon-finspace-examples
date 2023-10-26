\d .aws 

/ this script assumes AWS credentials for the customer account are 
/ set in the environment at script-load time


/ ----------------
/ Public Prefs API
/ ----------------
 
/ .aws.set_prefs is usually the first function to call
/ new is a dictionary with preferred values specifying one or more of the following:
/   `envName`clusterName`userName`envId`userArn`iamRole`sessionName`databaseName`stagingS3Bucket
/ if environment ID is not specified, it's retrieved from the AWS account 
/ if user name is specified, userArn and iamRole are retrieved for that user
/ if no session name is specified, "default" is used as the session name
/ preferences are used as defaults for API calls when parameters are set to null ("")
/ .aws.set_prefs can be invoked multiple times to add or update preferences

set_prefs:{[new]
   prefs,:new;
   $[""~prefs`envId;prefs[`envId]:get_kx_environment_id prefs`envName;];
   $[""~prefs`sessionName;prefs[`sessionName]:"default";];  
   $[""~new`userName;;prefs^:get_kx_user_arns prefs`userName];  
 }

/ ----------------
/ Public List APIs
/ ----------------

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-environments.html
list_kx_environments:{[]
   finspace_list["list-kx-environments";`environments]
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-users.html
list_kx_users:{[]
   finspace_list["list-kx-users";`users]
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-databases.html
list_kx_databases:{[]
   finspace_list["list-kx-databases";`kxDatabases]
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-changesets.html
list_kx_changesets:{[databaseName]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_list["list-kx-changesets --database-name ",databaseName;`kxChangesets]
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-clusters.html 
list_kx_clusters_full:{[]
   finspace_list["list-kx-clusters";`kxClusterSummaries]
 }

/ returns a subset of the result of list_kx_clusters_full mimicking the behavior within FinSpace
/ see https://docs.aws.amazon.com/finspace/latest/userguide/interacting-with-kdb-loading-code.html
list_kx_clusters:{[]
   clusters: list_kx_clusters_full[];
   $[not `clusterDescription in cols clusters;clusters:update clusterDescription:(count clusters)#enlist"" from clusters;];
   select cluster_name: clusterName, status, cluster_type:clusterType, description:clusterDescription from clusters
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-cluster-nodes.html
list_kx_cluster_nodes:{[clusterName]
   $[clusterName~"";clusterName:prefs`clusterName;];
   nodes:finspace_list["list-kx-cluster-nodes --cluster-name ", clusterName;`nodes];
   select node_id: nodeId, az_id:availabilityZoneId, launch_time: launchTime from nodes
 }

/ ---------------
/ Public Get APIs
/ ---------------

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-environment.html
get_kx_environment:{[environmentId]
   $[environmentId~"";environmentId:prefs`envId;];
   finspace_cli "get-kx-environment --environment-id ",environmentId
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-user.html
get_kx_user:{[userName]
   $[userName~"";userName:prefs`userName;];
   finspace_cli "get-kx-user --user-name ",userName
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-database.html
get_kx_database:{[databaseName]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "get-kx-database --database-name ",databaseName
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-changeset.html
get_kx_changeset:{[databaseName;changesetId]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "get-kx-changeset --database-name ",databaseName," --changeset-id ",changesetId
 }

/ alternative name for the function above to keep compatibility with the library within FinSpace
/ see https://docs.aws.amazon.com/finspace/latest/userguide/interacting-with-kdb-loading-code.html
get_changeset:get_kx_changeset

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-cluster.html
get_kx_cluster:{[clusterName]
   $[clusterName~"";clusterName:prefs`clusterName;];
   finspace_cli "get-kx-cluster --cluster-name ",clusterName
 }

/ get an environment ID from its name
get_kx_environment_id:{[envName]
   $[envName~"";envName:prefs`envName;];
   envs:list_kx_environments[];
   $[envName~""; 
      last exec environmentId from envs;
      last exec environmentId from envs where name like envName
   ]
 }

/ get a user ARN and IAM role from its name
get_kx_user_arns:{[userName]
   userNameParm:$[userName~"";prefs`userName;userName];
   first each exec userArn,iamRole from list_kx_users[] where userName like userNameParm
 }

/ ------------------
/ Public Delete APIs
/ ------------------

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/delete-kx-environment.html
delete_kx_environment:{[environmentId]
   $[environmentId~"";environmentId:prefs`envId;];
   finspace_cli "delete-kx-environment --environment-id ",environmentId
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/delete-kx-user.html
delete_kx_user:{[userName]
   $[userName~"";userName:prefs`userName;];
   finspace_cli "delete-kx-cluster --user-name ",userName
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/delete-kx-database.html
delete_kx_database:{[databaseName]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "delete-kx-database --database-name ",databaseName
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/delete-kx-cluster.html
delete_kx_cluster:{[clusterName]
   $[clusterName~"";clusterName:prefs`clusterName;];
   finspace_cli "delete-kx-cluster --cluster-name ",clusterName
 }

/ ------------------
/ Public Create APIs
/ ------------------

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-environment.html
/ properties is a list or scalar made up from the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/   .aws.create_kx_environment["myEnvName";""]
/   .aws.create_kx_environment["myEnvName";.aws.sdesc"This is my description"]
create_kx_environment:{[environmentName;kmsKeyId;properties]
   finspace_cli "create-kx-environment --name ",environmentName,merge_props properties; 
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-user.html
create_kx_user:{[userName;iamRole]
   $[userName~"";userName:prefs`userName;];
   $[iamRole~"";iamRole:prefs`iamRole;];
   finspace_cli "create_kx_user --user-name ",userName," --iam-role ",iamRole
 }


/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-database.html
/ properties is a list or scalar made up from the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/  .aws.create_kx_database["myDbName";""]
/  .aws.create_kx_database["myDbName";.aws.sdesc"This is my description"]
create_kx_database:{[databaseName;properties]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "create-kx-database --database-name ",databaseName,merge_props properties 
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-changeset.html 
/ changeRequests is a list of dictionaries/table
/ example:
/   (
/     `changeType`s3Path`dbPath!("PUT";"s3://bucket/db/2020.01.02/";"/2020.01.02/");
/     `changeType`s3Path`dbPath!("PUT";"s3://bucket/db/sym";"/");
/     `changeType`dbPath!("DELETE";"/2020.01.01/")
/   )
create_kx_changeset:{[databaseName;changeRequests]
   $[databaseName~"";databaseName:prefs`databaseName;];
   jsonReqs:.j.j changeRequests;
   finspace_cli "create-kx-changeset --database-name ",databaseName," --change-requests ",escape jsonReqs
 }

/ https://docs.aws.amazon.com/finspace/latest/userguide/interacting-with-kdb-loading-code.html
/ a staging S3 bucket needs to be set before calling this function
/ the staging bucket must have the same permissions as a bucket used for changeset creation
/ allowing the finspace.amazonaws.com service to perform actions s3:GetObject, s3:GetObjectTagging, and s3:ListBucket
/ example:
/   .aws.set_prefs[(enlist `stagingS3Bucket)!enlist "s3://myStagingS3Bucket"]
/ changeRequests is a list of dictionaries/table with the list of change requests with 3 columns/keys:
/   input_path – The input path of the local file system directory or file to ingest as a Managed kdb changeset
/   database_path – The target database destination path of the Managed kdb changeset
/   change_type – The type of the Managed kdb changeset. It can be either "PUT" or "DELETE"
/ example:
/   ([] 
/     input_path: ("/opt/kx/app/scratch/2023.01.01/";"/opt/kx/app/scratch/sym"); 
/     database_path: ("/2023.01.01/";"/"); 
/     change_type: ("PUT";"PUT")
 /  )
create_changeset:{[databaseName;changeRequests]
   / upload local files to the staging bucket
   {
      $[
         "PUT"~x`change_type;
         [
            sp:stage x`database_path;
            cli "s3 cp ", x[`input_path]," ",sp,$[last "/" = x`input_path;" --recursive";""];
         ]
         ;
      ]
   } 
   each changeRequests;
   / create the change request structure for the public API 
   pubCR: 
      {
         ((`changeType`dbPath)!x[`change_type`database_path]),
         $[
            "PUT"~x`change_type;
            (enlist `s3Path)!enlist stage x`database_path;
            ()!()
         ]
      } 
      each changeRequests;
   / invoke the public API
   res:create_kx_changeset[databaseName;pubCR];
   (`id`status)!(res`changesetId;res`status)
 }

/ empty the staging s3 bucket
cleanup_s3_staging:{[]
   cli "s3 rm ",stage "/"," --recursive"
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-cluster.html 
/ clusterType in ["HDB";"RDB";"GATEWAY"]
/ nodeType in ["kx.s.large";"kx.s.xlarge";"kx.s.2xlarge";"kx.s.4xlarge";"kx.s.8xlarge";"kx.s.16xlarge";"kx.s.32xlarge"]
/ releaseLabel is the version of FinSpace managed kdb to run (example: "1.0")
/ azMode in ["SINGLE";"MULTI"]
/ properties is a list or scalar made up from the output of zero or more of the following helper functions:
/   .aws.sdbs, .aws.scaches, .aws.sautoscale, .aws.scdesc, .aws.sscript, .aws.svpc, .aws.scl, 
/   .aws.scode, .aws.saz, .aws.sexec, .aws.ssaved
/ example: (.aws.saz"use1-az4";.aws.svpc["vpc-0e811ea765254dc23";"sg-1381015734ae3682c";"subnet-0ef64b551076ad28";""]) 
create_kx_cluster:{[clusterName;clusterType;nodeType;nodeCount;releaseLabel;azMode;properties]
   finspace_cli
      "create-kx-cluster --cluster-name ",clusterName,
      " --cluster-type ",clusterType,
      " --capacity-configuration nodeType=",nodeType,",nodeCount=",(string nodeCount),
      " --release-label ",releaseLabel,
      " --az-mode ",azMode,
      merge_props properties

 }

/ ------------------
/ Public Update APIs
/ ------------------

 
/ https://docs.aws.amazon.com/cli/latest/reference/finspace/update-kx-database.html
/ properties is a list or scalar made up from the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/   .aws.create_kx_database["myDbName";""]
/   .aws.create_kx_database["myDbName";.aws.sdesc"This is my description"]
update_kx_database:{[databaseName;properties]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "update-kx-database --database-name ",databaseName,merge_props properties
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/update-kx-cluster-databases.html 
/ databases is a string built by .aws.sdbs
/ properties is a list or scalar made up from the output of zero or more helper functions
/ for now, the only allowed property is deployment configuration, created with .aws.sdep
/ example: 
/     .aws.update_kx_cluster_databases[
/        "MyCluster";
/        .aws.sdbs[.aws.db["MyDB";"osSoXB58eSXuDXLZFTCHyg";.aws.cache["";"/"]]];
/        .aws.sdep["ROLLING"]
/     ]
update_kx_cluster_databases:{[clusterName;databases;properties]
   $[clusterName~"";clusterName:prefs`clusterName;];
   finspace_cli "update-kx-cluster-databases --cluster-name ",clusterName,databases,merge_props properties
 }

/ -------------------------
/ Public Authorization APIs
/ -------------------------

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/get-kx-connection-string.html
/ note: this function gets the KX user from the AWS prefs to keep compatibility with the library within FinSpace 
/   the user can be set by calling either
/     set_prefs[(enlist`userName)!enlist "myUserName"] or
/     set_prefs[(enlist`userArn)!enlist "myUserArn"]
get_kx_connection_string:{[clusterName]
   get_kx_connection_string_for_user[clusterName;""]
 }

/ a version of the previous function that allows overriding the user name 
get_kx_connection_string_for_user:{[clusterName;userName]
   $[clusterName~"";clusterName:prefs`clusterName;];
   iamRole:$[userName~"";prefs`iamRole;(get_kx_user_arns userName)`iamRole];
   / go back to the script startup credentials
   / in case they have been changed by a failed call
   restore_creds[];  
   / using the startup credentials, get a new set
   / of credentials for the role specified in the global prefs
   assume_role[iamRole];
   dict:finspace_cli "get-kx-connection-string --cluster-name ",clusterName," --user-arn ",prefs`userArn;
   / restore startup credentials
   restore_creds[];  
   dict`signedConnectionString
 }

/ this function is provided to keep compatibility with the library within FinSpace
/ see https://docs.aws.amazon.com/finspace/latest/userguide/interacting-with-kdb-loading-code.html
/ here, it returns the cluster connection string, since node connections are not allowed outside FinSpace
/ the node id argument is checked for validity, but otherwise ignored
get_kx_node_connection_string:{[clusterName;nodeId]
   $[clusterName~"";clusterName:prefs`clusterName;];
   $[nodeId in exec nodeId from list_kx_cluster_nodes clusterName;get_kx_connection_string clusterName;]
 }

/ this function only works if run on a system that can establish a connection to a FinSpace cluster
/ examples: 
/   an EC2 instance running in the account that owns the environment 
/   an on-prem machine on a network that has a route to the cluster's VPNs 
connect_to_cluster:{[clusterName;userName]
   hopen get_kx_connection_string_for_user[clusterName;userName]
 }

/ ---------------
/ Public Wait API
/ ---------------

/ calls the provided function with the given arguments at the specified frequency until
/ it returns a dictionary with the value for status key matching one of the expected statuses
/ or it times out
/ example: .aws.wait_for_status[.aws.get_kx_cluster;enlist "Name";("COMPLETED";"FAILED");00:00:20;30:00] 
wait_for_status:{[function;args;statuses;frequency;timeout]
  res:function . args;
  st:.z.t;
  l:0;
  $[10h=type statuses;statuses:enlist statuses;]
  while [(timeout>ti:.z.t-st) & not (res`status) in statuses; 
     $[frequency<=ti-l;
         (
            l:ti;
            res:function . args; 
            show "Status: ", (res`status), " waited: ", string(ti)
         );
     ]
   ];
   show "** Done **";
   res 
 }

/ ---------------
/ Public Initialization API
/ ---------------

/ This function is provided to keep compatibility with the library within FinSpace
/ see https://docs.aws.amazon.com/finspace/latest/userguide/interacting-with-kdb-loading-code.html
/ here, it logs a statement about what would have happened if it were called on an actual cluster,
/ but has no other effect.
stop_current_kx_cluster_creation:{[message]
  show "Cluster would be put in the CREATE_FAILED state if called from initialization script."
  }

/ ----------------
/ Helper Functions
/ ----------------

/ remember the credentials from the environment
save_creds:{[]
   vars:`AWS_ACCESS_KEY_ID`AWS_SECRET_ACCESS_KEY`AWS_SESSION_TOKEN;
   creds^:vars!getenv vars;
 } 

/ save the credentials at script-load time
save_creds[]

/ restore the credentials stored at script-load time
restore_creds:{[]
   vars:`AWS_ACCESS_KEY_ID`AWS_SECRET_ACCESS_KEY`AWS_SESSION_TOKEN;
   (key creds) setenv' value creds;
 }

/ assume an IAM role using the current credentials
assume_role:{[iamRole]
   $[iamRole~"";iamRole:prefs`iamRole;];
   sessionName:prefs`sessionName;   
   result: json_cli "sts assume-role --role-arn ", iamRole," --role-session-name ", sessionName;
   `AWS_ACCESS_KEY_ID  setenv result[`Credentials;`AccessKeyId];
   `AWS_SECRET_ACCESS_KEY setenv result[`Credentials;`SecretAccessKey];
   `AWS_SESSION_TOKEN setenv result[`Credentials;`SessionToken];
 }

/ call an AWS CLI command without pagination
cli:{[subCommand]
   system "aws ",subCommand," --no-paginate"
 }


/ call and AWS CLI command returning a JSON doc
/ and parse the result into a Q structure
json_cli:{[subCommand]
   r:cli[subCommand];
   $[0=count r;;.j.k raze r]
  }

/ call an AWS FinSpace CLI command 
/ add the preferred environment if not specified
finspace_cli:{[subCommand]
   newSub:subCommand,$[0=count subCommand ss "environment";" --environment-id ", prefs`envId;""];
   json_cli["finspace ",newSub]
 }

/ call an AWS FinSpace list CLI command
/ and parses the response to return a table 
/ with the data under the specified root label
finspace_list:{[subCommand;root]
   dicts: finspace_cli[subCommand][root];
   / dicts is a list of uneven dictionaries (different keys)
   / the following makes the dictionaries even to produce a proper table
   ((distinct () ,/ key each dicts)#) each dicts
 }

/ return a version of a string with special characters escaped 
escape:{[s]
    / save console dimensions
    dims:system "c";
    / change console dimensions to avoid truncation
    system "c 25 2000";
    esc:.Q.s1 s;
    / restore console dimensions
    system "c ",.Q.s1 dims;
    esc
 }

merge_props:{[properties]
   $[0h=type properties;sv["";properties];properties]
 }

stage:{[dbPath]
   prefs[`stagingS3Bucket],dbPath
 }

/ ---------------------------
/ Argument Creation Functions
/ ---------------------------

/ build a cache argument for functions that require it
cache:{[cacheType;dbPaths]
   $[0=count cacheType;cacheType:"CACHE_1000";];
   $[10h=type dbPaths;dbPaths:enlist dbPaths;];
   $[-10h=type dbPaths;dbPaths:enlist enlist dbPaths;];
   `cacheType`dbPaths!(cacheType;dbPaths)
 }

/ build a database argument for functions that require it
/ caches is a dictionary or list of dictionaries each built by .aws.cache
db:{[databaseName;changesetId;caches]
   $[databaseName~"";databaseName:prefs`databaseName;];
   $[99h=type caches;caches:enlist caches;]; 
   db_config: `databaseName`changesetId`cacheConfigurations!(databaseName;changesetId;caches);
   $[changesetId~""; db_config: db_config _ `changesetId;];
   $[caches~""; db_config: db_config _ `cacheConfigurations;];
   db_config
 }

/ build a string with a list of databases for functions that require it
/ the argument is a dictionary or a list of dictionaries each built by .aws.db
sdbs:{[databases]
   $[99h=type databases;databases:enlist databases;];
   " --databases ",escape .j.j databases
 }

/ build a cluster cache argument for functions that require it
/ if cache type is an empty string, the default "CACHE_1000" is used
ccache:{[cacheType;cacheSize]
   $[0=count cacheType;cacheType:"CACHE_1000";];
   `type`size!(cacheType;cacheSize)
 }

/ build a string with a cluster description for functions that require it
scdesc:{[description]
   $[description~"";"";" --cluster-description \"",description,"\""]
 }

/ build a string with a list of cache configurations for functions that require it
/ caches is a dictionary or list of dictionaries each built by .aws.ccache
scaches:{[caches]
   $[99h=type caches;caches:enlist caches;]; 
   " --cache-storage-configurations ",escape .j.j caches
 }

/ build a string with an autoscale configuration for functions that require it
sautoscale:{[minNodeCount;maxNodeCount;autoScalingMetric;metricTarget;scaleInCooldownSeconds;scaleOutCooldownSeconds]
   $[0=count autoScalingMetric;autoScaling:"CPU_UTILIZATION_PERCENTAGE";];
   " --auto-scaling-configuration ",
   "minNodeNodeCount=",string minNodeCount,
   ",maxNodeCount=",string maxNodeCount,
   ",autoScalingMetric=",autoScalingMetric,
   ",metricTarget=",string metricTarget,
   ",scaleInCooldownSeconds=",scaleInCooldownSeconds,
   ",scaleOutCooldownSeconds=",scaleOutCooldownSeconds
 }

/ build a string with a generic description for functions that require it
/ note: clusters require a description created with .aws.scdesc
sdesc:{[description]

   $[description~"";"";" --description \"",description,"\""]
 }

/ build a string with a cluster initialization script path for functions that require it
sscript:{[filename]
   $[filename~"";"";" --initialization-script ",filename]
 }

/ build a string with a VPC spec for functions that require it
svpc:{[vpcId;securityGroupIds;subnetIds;ipAddressType]
   $[0=count ipAddressType;ipAddressType:"IP_V4";];
   $[10h=type securityGroupIds;securityGroupIds:enlist securityGroupIds;];
   $[10h=type subnetIds;subnetIds:enlist subnetIds;];
   " --vpc-configuration ",
   "vpcId=",vpcId,
   ",securityGroupIds=",("," sv securityGroupIds),
   ",subnetIds=",("," sv subnetIds),
   ",ipAddressType=",ipAddressType
 }

/ build a string with a list of command-line arguments for functions that require it
/ example: ("s";"codebase")!("32";"my_code")
scl:{[commandLineArgs]
   $[0~count commandLineArgs;
      "";
      " --command-line-arguments "," " sv (key commandLineArgs) {"key=",x,",value=",y}' value commandLineArgs
   ]
 }

/ build a string with a code location for functions that require it
/ example: .aws.scode["s3://my-bucket";"/code/my-code.zip";"1"]
scode:{[s3Bucket;s3Key;s3ObjectVersion]
   " --code ",
   "s3Bucket=",s3Bucket,
   ",s3Key=",s3Key,
   $[0>count s3ObjectVersion;",s3ObjectVersion=",s3ObjectVersion;""]   
 }

/ build a string with an availability zone ID for functions that require it
/ example: "use1-az1"
saz:{[azId]
   $[azId~"";"";" --availability-zone-id ",azId]
 }

/ build a string with an availability zone ID for functions that require it
/ example "arn:aws:iam::123456789123:role/Admin"
sexec:{[executionRoleArn]
   $[executionRoleArn~"";"";" --execution-role ",executionRoleArn]
 }

/ build a string with a savedown storage configuration for functions that require it
ssaved:{[storageType;gigas]
   $[0=count storageType;storageType:"SDS01";];
   " --savedown-storage-configuration ",
   "type=",storageType,
   ",size=",string gigas
 }

/ build a string with a deployment configuration for functions that require it
/ the argument is the name of a deployment strategy, for now "ROLLING" or "NO_RESTART"
sdep:{[strategy]
   " --deployment-configuration deploymentStrategy=",strategy
 }  

\d .