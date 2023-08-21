\d .aws 

/ this script assumes AWS credentials for the customer account are 
/ set in the environment at script-load time


/ ----------------
/ Public Prefs API
/ ----------------
 
/ .aws.set_prefs is usually the first function to call
/ new is a dictionary with preferred values specifying one or more of the following:
/   `envName`clusterName`userName`envId`userArn`iamRole`sessionName`databaseName
/ if environment ID is not specified, it's retrieved from the AWS account 
/ if user name is specified, userArn and iamRole are retrieved for that user
/ if no session name is specified, "default" is used as the session name
/ preferences are used as defaults for API calls when parameters are set to null ("")
/ .aws.set_prefs can be invoked multiple times to add or update preferences

set_prefs:{[new]
   prefs,:new;
   $[""~new`envId;prefs[`envId]:get_kx_environment_id prefs`envName;];
   $[""~new`sessionName;prefs[`sessionName]:"default";];  
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
   select cluster_name: clusterName, status, cluster_type:clusterType, description:clusterDescription from clusters
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/list-kx-cluster-nodes.html
list_kx_cluster_nodes:{[clusterName]
   $[clusterName~"";clusterName:prefs`clusterName;];
   finspace_list["list-kx-cluster-nodes --cluster-name ", clusterName;`nodes]
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
/ properties is a string built by concatenating the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/   .aws.create_kx_environment["myEnvName";""]
/   .aws.create_kx_environment["myEnvName";.aws.sdesc["This is my description"]]
create_kx_environment:{[environmentName;kmsKeyId;properties]
   finspace_cli "create-kx-environment --name ",environmentName,properties; 
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-user.html
create_kx_user:{[userName;iamRole]
   $[userName~"";userName:prefs`userName;];
   $[iamRole~"";iamRole:prefs`iamRole;];
   finspace_cli "create_kx_user --user-name ",userName," --iam-role ",iamRole
 }


/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-database.html
/ properties is a string built by concatenating the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/  .aws.create_kx_database["myDbName";""]
/  .aws.create_kx_database["myDbName";.aws.sdesc["This is my description"]]
create_kx_database:{[databaseName;properties]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "create-kx-database --database-name ",databaseName,properties 
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-changeset.html 
/ changeRequests is a list of dictionaries
/ example:
/ (
/   `changeType`s3Path`dbPath!("PUT";"s3://bucket/db/2020.01.02/";"/2020.01.02/");
/   `changeType`s3Path`dbPath!("PUT";"s3://bucket/db/sym";"/");
/   `changeType`s3Path!("DELETE";"/2020.01.01/")
/  )
create_kx_changeset:{[databaseName;changeRequests]
   $[databaseName~"";databaseName:prefs`databaseName;];
   jsonReqs:.j.j changeRequests;
   finspace_cli "create-kx-changeset --database-name ",databaseName," --change-requests ",escape jsonReqs
 }

/ https://docs.aws.amazon.com/cli/latest/reference/finspace/create-kx-cluster.html 
/ clusterType in ["HDB";"RDB";"GATEWAY"]
/ nodeType in ["kx.s.large";"kx.s.xlarge";"kx.s.2xlarge";"kx.s.4xlarge";"kx.s.8xlarge";"kx.s.16xlarge";"kx.s.32xlarge"]
/ releaseLabel is the version of FinSpace managed kdb to run (example: "1.0")
/ azMode in ["SINGLE";"MULTI"]
/ properties is a string built by concatenating the output of one or more of the following helper functions:
/   .aws.sdbs, .aws.scaches, .aws.sautoscale, .aws.scdesc, .aws.sscript, .aws.svpc, .aws.scl, 
/   .aws.scode, .aws.saz, .aws.sexec, .aws.ssaved
/ example: .aws.saz["use1-az4"],.aws.svpc["vpc-0e811ea765254dc23";"sg-1381015734ae3682c";"subnet-0ef64b551076ad28";""] 
create_kx_cluster:{[clusterName;clusterType;nodeType;nodeCount;releaseLabel;azMode;properties]
   finspace_cli
      "create-kx-cluster --cluster-name ",clusterName,
      " --cluster-type ",clusterType,
      " --capacity-configuration nodeType=",nodeType,",nodeCount=",(string nodeCount),
      " --release-label ",releaseLabel,
      " --az-mode ",azMode,
      properties

 }

/ ------------------
/ Public Update APIs
/ ------------------

 
/ https://docs.aws.amazon.com/cli/latest/reference/finspace/update-kx-database.html
/ properties is a string built by concatenating the output of zero or more helper functions
/ for now, the only allowed property is description, created with .aws.sdesc
/ examples:
/   .aws.create_kx_database["myDbName";""]
/   .aws.create_kx_database["myDbName";.aws.sdesc["This is my description"]]
update_kx_database:{[databaseName;properties]
   $[databaseName~"";databaseName:prefs`databaseName;];
   finspace_cli "update-kx-database --database-name ",databaseName,properties
 }


/ https://docs.aws.amazon.com/cli/latest/reference/finspace/update-kx-cluster-databases.html 
/ databases is a string built by .aws.sdbs
update_kx_cluster_databases:{[clusterName;databases]
   $[clusterName~"";clusterName:prefs`clusterName;];
   finspace_cli "update-kx-cluster-databases --cluster-name ",clusterName,databases
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

/ calls the function every 20 milliseconds until
/ it returns a dictionary with the expected status in the status key
/ or it times out
/ example: .aws.wait_for_status[{.aws.get_kx_cluster["Name"]},"Ready",30:00] 
wait_for_status:{[function;status;frequency;timeout]
  res:function[];
  st:.z.t;
  l:0;
  while [(timeout>ti:.z.t-st) & not status like res`status; 
     $[frequency<=ti-l;
         (
            l:ti;
            res:function[]; 
            show "Status: ", (res`status), " waited: ", string(ti)
         );
     ]
   ];
   show "** Done **";
   res 
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
   `databaseName`changesetId`cacheConfigurations!(databaseName;changesetId;caches)
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

/ build a string with a generic description for functions that require it
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

/ build a string with a cluster description for functions that require it
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

\d .