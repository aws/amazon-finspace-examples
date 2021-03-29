import datetime
import time
import boto3
import os
import pandas as pd
import urllib

from urllib.parse import urlparse
from botocore.config import Config

# Base FinSpace class
class FinSpace:
        
    def __init__(
        self,
        config = Config(retries = {'max_attempts': 0, 'mode': 'standard'}),
        boto_session: dict = None,
        dev_overrides: dict = None
    ):
        """
        To configure this class object, simply instantiate with no-arg if hitting prod endpoint, or else override it: 
        e.g.
           `hab = FinSpaceAnalyticsManager(region_name = 'us-east-1', 
           dev_overrides = {'hfs_endpoint': 'https://39g32x40jk.execute-api.us-east-1.amazonaws.com/alpha'})`
        """
        self.hfs_endpoint = None
        self.region_name  = None
        
        if dev_overrides != None:
            if 'hfs_endpoint' in dev_overrides:
                 self.hfs_endpoint = dev_overrides['hfs_endpoint']

            if 'region_name' in dev_overrides:
                self.region_name = dev_overrides['region_name']
        else:
            self.region_name = self.get_region_name() 
        
        self.config = config
        
        self._boto3_session = boto3.session.Session(region_name = self.region_name) if boto_session is None else  boto_session
        
        print(f"endpoint: {self.hfs_endpoint}")
        print(f"region_name: {self.region_name}")
                
        self.client = self._boto3_session.client('finspace-data', endpoint_url = self.hfs_endpoint, config = self.config )

    def get_region_name(self):
        req = urllib.request.Request("http://169.254.169.254/latest/meta-data/placement/region")
        with urllib.request.urlopen(req) as response:
            return response.read().decode("utf-8")

    #--------------------------------------
    # Utility Functions
    #--------------------------------------
    def get_list(self, all_list: dir, name: str):
        """
        Search for name found in the all_list dir and return that list of things. 
        Removes repetitive code found in functions that call boto apis then search for the expected returned items
        
        :param all_list: list of things to search
        :type: dir:
        
        :param name: name to search for in all_lists
        :type: str
        
        :return: list of items found in name
        """
        r = []
        
        # is the given name found, is found, add to list
        if name in all_list:
            for s in all_list[name]:
                r.append(s)
        
        # return the list
        return r
        
    #--------------------------------------
    # Classification Functions
    #--------------------------------------
        
    def list_classifications(self):
        """
        Return list of all classifications

        :return: all classifications
        """
        all_list = self.client.list_classifications(sort='NAME')
 
        return ( self.get_list(all_list, 'classifications') )

    def classification_names(self):
        """ 
        Get the classifications names

        :return list of classifications names only
        """
        classification_names = []
        all_classifications = self.list_classifications()
        for c in all_classifications :
            classification_names.append(c['name'])
        return classification_names
    
    def classification(self, name: str):
        """ 
        Exact name search for a classification of the given name

        :param name: name of the classification to find
        :type: str

        :return 
        """
        
        all_classifications = self.list_classifications()
        existing_classification = next((c for c in all_classifications if c['name'] == name), None)
        if existing_classification:
            return existing_classification
    
    def describe_classification(self, classification_id: str):
        """
        Calls the describe classification API function and only returns the taxonomy portion of the response.
        
        :param classification_id: the GUID of the classification to get description of
        :type: str
        """
        resp = None
        taxonomy_details_resp = self.client.describe_taxonomy(taxonomyId=classification_id)
        
        if 'taxonomy' in taxonomy_details_resp:
            resp = taxonomy_details_resp['taxonomy']
        
        return( resp )
   
    def create_classification( self, classification_definition):
        resp = self.client.create_taxonomy(taxonomyDefinition = classification_definition)
        
        taxonomy_id = resp["taxonomyId"]
        
        return(taxonomy_id)

    def delete_classification( self, classification_id): 
        resp = self.client.delete_taxonomy(taxonomyId = classification_id)
        
        if (resp['ResponseMetadata']['HTTPStatusCode'] != 200):
            return resp
        
        return True
    #--------------------------------------
    # Attribute Set Functions
    #--------------------------------------
        
    def list_attribute_sets(self):
        """
        Get list of all dataset_types in the system
        
        :return: list of dataset types
        """
        resp = self.client.list_dataset_types()
        results = resp['datasetTypeSummaries']

        while "nextToken" in resp:
            resp = self.client.list_dataset_types(nextToken=resp['nextToken'])
            results.extend(resp['datasetTypeSummaries'])

        return( results )

    def attribute_set_names(self):
        """ 
        Get the list of all dataset type names

        :return list of all dataset type names
        """

        dataset_type_names = []
        all_dataset_types = self.list_dataset_types()
        for c in all_dataset_types :
            dataset_type_names.append(c['name'])
        return dataset_type_names
    
    def attribute_set(self, name: str):
        """ 
        Exact name search for a dataset type of the given name

        :param name: name of the dataset type to find
        :type: str

        :return 
        """
        
        all_dataset_types = self.list_dataset_types()
        existing_dataset_type = next((c for c in all_dataset_types if c['name'] == name), None)
        if existing_dataset_type:
            return existing_dataset_type
    
    def describe_attribute_set(self, attribute_set_id: str):
        """
        Calls the describe dataset type API function and only returns the dataset type portion of the response.
        
        :param dataset_type_id: the GUID of the dataset type to get description of
        :type: str
        """
        resp = None
        dataset_type_details_resp = self.client.describe_dataset_type(datasetTypeId=attribute_set_id)
        
        if 'datasetType' in dataset_type_details_resp:
            resp = dataset_type_details_resp['datasetType']
            
        return(resp)

    def create_attribute_set( self, attribute_set_def):
        resp = self.client.create_dataset_type(datasetTypeDefinition = attribute_set_def)
        
        att_id = resp["datasetTypeId"]
        
        return(att_id)

    def delete_attribute_set( self, attribute_set_id: str): 
        resp = self.client.delete_attribute_set(attributeSetId = attribute_set_id)
        
        if (resp['ResponseMetadata']['HTTPStatusCode'] != 200):
            return resp
        
        return True
    
    #--------------------------------------
    # Permission Group Functions
    #--------------------------------------

    def list_permission_groups(self, maxResults: int):
        all_perms = self.client.list_permission_groups(MaxResults = maxResults)
        return( self.get_list( all_perms, 'permissionGroups') )
    
    def permission_group( self, name):
        all_groups = self.list_permission_groups(maxResults=100)

        existing_group = next((c for c in all_groups if c['name'] == name), None)
        
        if existing_group:
            return existing_group

    def describe_permission_group( self, permission_group_id: str ):
        resp = None
        
        perm_resp = self.client.describe_permission_group( permissionGroupId = permission_group_id )
        
        if 'permissionGroup' in perm_resp:
            resp = perm_resp['permissionGroup']
            
        return(resp)
    
    #--------------------------------------
    # Dataset Functions
    #--------------------------------------
        
    def describe_dataset_details(self, dataset_id: str):
        """
        Calls the describe dataset details API function and only returns the dataset details portion of the response.
        
        :param dataset_id: the GUID of the dataset to get description of
        :type: str
        """
        resp = None
        dataset_details_resp = self.client.describe_dataset_details(datasetId=dataset_id)
        
        if 'dataset' in dataset_details_resp:
            resp = dataset_details_resp["dataset"]
        
        return( resp )
    
    def create_dataset(self, name: str, description: str, permission_group_id: str, dataset_permissions: [], kind: str, owner_info, schema):
        """
        Create a dataset
        
        Warning, dataset names are not unique, be sure to check for the same name dataset before creating a new one
        
        :param name: Name of the dataset
        :type: str

        :param description: Description of the dataset
        :type: str

        :param permission_group_id: permission group for the dataset
        :type: str

        :param dataset_permissions: permissions for the group on the dataset

        :param kind: Kind of dataset, choices: TABULAR
        :type: str

        :param owner_info: owner information for the dataset

        :param schema: Schema of the dataset

        :return: the dataset_id of the created dataset
        """
        
        if dataset_permissions: 
            requestDatasetPermissions = [{"permission": permissionName} for permissionName in dataset_permissions]
        else:
            requestDatasetPermissions = []
            
        response = self.client.create_dataset(name=name,
                                     permissionGroupId=permission_group_id,
                                     datasetPermissions=requestDatasetPermissions,
                                     kind=kind,
                                     description=description.replace('\n',' '),
                                     ownerInfo=owner_info,
                                     schema=schema)
        
        return response["datasetId"]
    
    def ingest_from_s3(self, 
        s3_location: str, 
        dataset_id: str, 
        change_type: str, 
        wait_for_completion=True,
        format_type = "CSV", 
        format_params = {'separator':',', 'withHeader':'true'} ):
        """
        Creates a changeset and ingests the data given in the S3 location into the changeset
        
        :param s3_location: the source location of the data for the changeset, will be copied into the changeset
        :stype: str
        
        :param dataset_id: the identifier of the containing dataset for the changeset to be created for this data
        :type: str
        
        :param change_type: What is the kind of changetype?  "APPEND", "REPLACE" are the choices
        :type: str
        
        :param wait_for_completion: Boolean, should the function wait for the operation to complete?
        :type: str
        
        :return: the id of the changeset created
        """
        create_changeset_response = self.client.create_changeset(
            datasetId=dataset_id, 
            changeType=change_type,
            sourceType='S3',
            sourceParams={'s3SourcePath': s3_location},
            formatType=format_type.upper(),
            formatParams=format_params
        )

        changeset_id = create_changeset_response['changeset']['id']
        
        if wait_for_completion:
            self.wait_for_ingestion(dataset_id, changeset_id)
        return changeset_id

    def describe_changeset(self, dataset_id: str, changeset_id: str):
        """
        Function to get a description of the the givn changeset for the given dataset
        
        :param dataset_id: identifier of the dataset
        :type: str
        
        :param changeset_id: the idenfitier of the changeset
        :type: str
        
        :return: all information about the changeset, if found
        """
        describe_changeset_resp = self.client.describe_changeset(datasetId=dataset_id, id=changeset_id)
        
        return describe_changeset_resp['changeset']

    def create_as_of_view(self, dataset_id: str, as_of_date: datetime, destination_type: str, 
                              partition_columns=[], sort_columns=[], destination_properties={}, wait_for_completion=True):
        """
        Creates an 'as of' static view up to and including the requested 'as of' date provided.
        
        :param dataset_id: identifier of the dataset
        :type: str

        :param as_of_date: as of date, will include changesets up to this date/time in the view
        :type datetime
        
        :para destination_type:
        :type str
        
        :param partition_columns: columns to partition the data by for the created view
        :type list
        
        :param sort_columns: column to sort the view by
        :type list
        
        :para destination_properties: 
        :type str
        
        :param wait_for_completion: should the function wait for the system to create the view?
        :type bool
        
        :return str: GUID of the created view if successful
        
        """
        create_materialized_view_resp = self.client.create_materialized_snapshot(
            datasetId=dataset_id, 
            asOfTimestamp=as_of_date, 
            destinationType=destination_type, 
            partitionColumns=partition_columns,
            sortColumns=sort_columns,
            autoUpdate=False,
            destinationProperties=destination_properties
        )
        view_id = create_materialized_view_resp['id']
        if wait_for_completion:
            self.wait_for_view(dataset_id=dataset_id, view_id=view_id)
        return view_id
    
    def create_auto_update_view(self, dataset_id: str, destination_type: str, 
                              partition_columns=[], sort_columns=[], destination_properties={}, wait_for_completion=True):
        """
        Creates an auto-updating view of the given dataset
        
        :param dataset_id: identifier of the dataset
        :type: str

        :para destination_type:
        :type str
        
        :param partition_columns: columns to partition the data by for the created view
        :type list
        
        :param sort_columns: column to sort the view by
        :type list
        
        :para destination_properties: 
        :type str
        
        :param wait_for_completion: should the function wait for the system to create the view?
        :type bool
        
        :return str: GUID of the created view if successful
        
        """
        create_materialized_view_resp = self.client.create_materialized_snapshot(
            datasetId=dataset_id,
            destinationType=destination_type, 
            partitionColumns=partition_columns,
            sortColumns=sort_columns,
            autoUpdate=True,
            destinationProperties=destination_properties
        )
        view_id = create_materialized_view_resp['id']
        if wait_for_completion:
            self.wait_for_view(dataset_id=dataset_id, view_id=view_id)
        return view_id
        
    def wait_for_ingestion(self, dataset_id: str, changeset_id: str, sleep_sec = 10):
        """
        function that will continuously poll the changeset creation to ensure it completes or fails before returning.
        
        :param dataset_id: GUID of the dataset
        :type: str
        
        :param changeset_id: GUID of the changeset
        :type: str
        
        :param sleep_sec: seconds to wait between checks
        :type: int
        
        """
        while True:
            status = self.describe_changeset(dataset_id=dataset_id, changeset_id=changeset_id)['status']
            if status == 'SUCCESS':
                print(f"Changeset complete")
                break
            elif status == 'PENDING' or status == 'RUNNING':
                print(f"Changeset status is still PENDING, waiting {sleep_sec} sec ...")
                time.sleep(sleep_sec)
                continue
            else:
                raise Exception(f"Bad changeset status: {status}, failing now.")
                
    def wait_for_view(self, dataset_id: str, view_id: str, sleep_sec = 10):
        """
        function that will continuously poll the view creation to ensure it completes or fails before returning.
        
        :param dataset_id: GUID of the dataset
        :type: str
        
        :param view_id: GUID of the view
        :type: str
        
        :param sleep_sec: seconds to wait between checks
        :type: int

        """
        while True:
            list_views_resp = self.client.list_materialization_snapshots(datasetId=dataset_id, maxResults=100)
            matched_views = list(filter(lambda d: d['id'] == view_id, list_views_resp['materializationSnapshots']))

            if len(matched_views) != 1:
                size = len(matched_views)
                raise Exception(f"Unexpected error: found {size} views that match the view Id: {view_id}")

            status = matched_views[0]['status']
            if status == 'SUCCESS':
                print(f"View complete")
                break
            elif status == 'PENDING' or status == 'RUNNING':
                print(f"View status is still PENDING, continue to wait till finish...")
                time.sleep(sleep_sec)
                continue
            else:
                raise Exception(f"Bad view status: {status}, failing now.")

    def list_changesets(self, dataset_id: str):
        resp = self.client.list_changesets(datasetId=dataset_id, sortKey='CREATE_TIMESTAMP')
        results = resp['changesets']

        while "nextToken" in resp:
            resp = self.client.list_changesets(datasetId=dataset_id, sortKey='CREATE_TIMESTAMP', nextToken=resp['nextToken'])
            results.extend(resp['changesets'])

        return( results )
    
    def list_views(self, dataset_id: str, max_results = 50):
        resp = self.client.list_materialization_snapshots(datasetId=dataset_id, maxResults=max_results)
        results = resp['materializationSnapshots']

        while "nextToken" in resp:
            resp = self.client.list_materialization_snapshots(datasetId=dataset_id, maxResults=max_results, nextToken=resp['nextToken'])
            results.extend(resp['materializationSnapshots'])

        return( results )

    def list_datasets(self, maxResults: int):
        all_datasets = self.client.list_datasets(maxResults=maxResults)
        return ( self.get_list( all_datasets, 'datasets') )
    
    def list_dataset_types(self):
        resp = self.client.list_dataset_types(sort='NAME')
        results = resp['datasetTypeSummaries']

        while "nextToken" in resp:
            resp = self.client.list_dataset_types(sort='NAME', nextToken=resp['nextToken'])
            results.extend(resp['datasetTypeSummaries'])

        return( results )
    
    def get_execution_role(self):
        """
        Convenience function from SageMaker to get the execution role of the user of the sagemaker studio notebook
        
        :return: the ARN of the execution role in the sagemaker studio notebook
        """
        import sagemaker as sm
        
        e_role = sm.get_execution_role()
        return ( f"{e_role}" )
    
    def get_user_ingestion_info(self):
        return( self.client.get_user_ingestion_info() )

    def upload_pandas(self, data_frame: pd.DataFrame):
        import awswrangler as wr
        resp = self.client.get_user_ingestion_info()
        upload_location = resp['ingestionPath']
        wr.s3.to_parquet(data_frame, f"{upload_location}data.parquet", index=False, boto3_session=self._boto3_session)
        return upload_location
    
    def ingest_pandas(self, data_frame: pd.DataFrame, dataset_id: str, change_type: str, wait_for_completion=True):
        print("Uploading the pandas dataframe ...")
        upload_location = self.upload_pandas(data_frame)
        
        print("Data upload finished. Ingesting data ...")
        return self.ingest_from_s3(upload_location, dataset_id, change_type, wait_for_completion, format_type='PARQUET')

    def read_view_as_pandas(
        self,
        dataset_id: str,
        view_id: str
        ):
        import awswrangler as wr   # use awswrangler to read the table
        """
        Returns a pandas dataframe the view of the given dataset.  Views in FinSpace can be quite large, be careful!
        
        :param dataset_id: 
        :param view_id:
        
        :return: Pandas dataframe with all data of the view
        """
        
        # @todo: switch to DescribeMateriliazation when available in HFS
        views = self.list_views(dataset_id=dataset_id, max_results=50)
        filtered = [v for v in views if v['id'] == view_id]

        if len(filtered) == 0:
            raise Exception('No such view found')
        if len(filtered) > 1:
            raise Exception('Internal Server error')
        view = filtered[0]
        
        # 0. Ensure view is ready to be read
        if (view['status'] != 'SUCCESS'): 
            status = view['status'] 
            print(f'view run status is not ready: {status}. Returning empty.')
            return

        glue_db_name = view['destinationTypeProperties']['databaseName']
        glue_table_name = view['destinationTypeProperties']['tableName']
        
        # determine if the table has partitions first, different way to read is there are partitions
        p = wr.catalog.get_partitions( table = glue_table_name, database = glue_db_name, boto3_session=self._boto3_session )
        df = None
        
        def no_filter(partitions):
            if len(partitions.keys()) > 0: 
                return True

            return False
        
        if (len(p) == 0):
            df = wr.s3.read_parquet_table( table = glue_table_name, database = glue_db_name, boto3_session=self._boto3_session )
        else:
            spath = wr.catalog.get_table_location( table = glue_table_name, database = glue_db_name, boto3_session=self._boto3_session )
            cpath = wr.s3.list_directories(f"{spath}/*", boto3_session=self._boto3_session)

            read_path = f"{spath}/"
            
            # just one?  Read it
            if len(cpath) == 1: 
                read_path = cpath[0]

            df = wr.s3.read_parquet( read_path, dataset=True, partition_filter=no_filter, boto3_session=hab_session )

            
        # Query Glue table directly with wrangler
        return df
    
    def get_schema_from_pandas(self, df: pd.DataFrame):
        """
        Returns the FinSpace schema columns from the given pandas dataframe.
        
        :param df: pandas dataframe to interrogate for the schema
        :type pd.DataFrame:
        
        :return: FinSpace column schema list
        """
        
        # for translation to FinSpace's schema
        # 'STRING'|'CHAR'|'INTEGER'|'TINYINT'|'SMALLINT'|'BIGINT'|'FLOAT'|'DOUBLE'|'DATE'|'DATETIME'|'BOOLEAN'|'BINARY'
        DoubleType    = "DOUBLE"
        FloatType     = "FLOAT"
        DateType      = "DATE"
        StringType    = "STRING"
        IntegerType   = "INTEGER"
        LongType      = "BIGINT"
        BooleanType   = "BOOLEAN"
        TimestampType = "DATETIME"

        hab_columns = []
        
        for name in dict(df.dtypes):

            p_type = df.dtypes[name]

            switcher = {
                "float64"             : DoubleType,
                "int64"               : IntegerType,
                "datetime64[ns, UTC]" : TimestampType,
                "datetime64[ns]"      : DateType
            }

            habType = switcher.get( str(p_type), StringType)

            hab_columns.append({
                "dataType"    : habType, 
                "name"        : name,
                "description" : ""
            })

        return( hab_columns )

    def get_date_cols(self, df: pd.DataFrame):
        """
        Returns which are the data columns found in the pandas dataframe. 
        Pandas does the hard work to figure out which of the columns can be considered to be date columns.
        
        :param df: pandas dataframe to interrogate for the schema
        :type pd.DataFrame:
        
        :return: list of column names that can be parsed as dates by pandas

        """
        dateCols = []

        for name in dict(df.dtypes):

            p_type = df.dtypes[name]

            switcher = {
                "datetime64[ns, UTC]" : True,
                "datetime64[ns]"      : True
            }

            if str(p_type).startswith("date"):
                dateCols.append(name)

        return( dateCols )
        
    def get_best_schema_from_csv(self, path, is_s3 = True, read_rows=500, sep=','):
        """
        Uses multiple reads of the file with pandas to determine schema of the referenced files. Files are expected to be csv.
        
        :param path: path to the files to read
        :type str
        
        :param is_s3: True if the path is s3;  False if filesystem
        :type bool
        
        :return dict: schema for FinSpace
        """
        #
        # best efforts to determine the schema, sight unseen
        import awswrangler as wr

        schema_rows = 500

        # 1: get the base schema
        df1 = None

        if is_s3:
            df1 = wr.s3.read_csv(path, nrows=schema_rows, sep=sep) 
        else:
            df1 = pd.read_csv(path, nrows=schema_rows, sep=sep)

        num_cols = len(df1.columns)

        # with number of columns, try to infer dates
        df2 = None
        
        if is_s3:
            df2 = wr.s3.read_csv(path, parse_dates=list(range(0,num_cols)), infer_datetime_format=True, nrows=schema_rows, sep=sep)
        else:
            df2 = pd.read_csv(path, parse_dates=list(range(0,num_cols)), infer_datetime_format=True, nrows=schema_rows, sep=sep)

        date_cols = self.get_date_cols(df2)

        # with dates known, parse the file fully
        df = None
        
        if is_s3:
            df = wr.s3.read_csv(path, parse_dates=date_cols, infer_datetime_format=True, nrows=schema_rows, sep=sep)
        else:
            df = pd.read_csv(path, parse_dates=date_cols, infer_datetime_format=True, nrows=schema_rows, sep=sep)
        
        schema_cols = self.get_schema_from_pandas(df)
        
        return( schema_cols )

    def s3_upload_file(self, sourceFile: str, s3_destination: str):
        """
        Uploads a local file (full path) to the s3 destination given (expected form: s3://<bucket>/<prefix>/). The filename will have spaces replaced with _.
        
        :param s3_destination: full path to where to save the file
        :type str
        
        
        """

        hab_s3_client = self._boto3_session.client(service_name = 's3')
        
        o = urlparse(s3_destination)
        bucket = o.netloc
        prefix = o.path.lstrip('/')

        fname = os.path.basename(sourceFile)

        hab_s3_client.upload_file(sourceFile, bucket, f"{prefix}{fname.replace(' ', '_')}" )
        
    def list_objects( self, s3_location: str ):
        """
        lists the objects found at the s3_location. Strips out the boto API response header, just returns the contents of the location. Internally uses the list_objects_v2.
        
        :param s3_location: path, starting with s3:// to get the list of objects from
        :type str
                
        """
        o = urlparse(s3_location)
        bucket = o.netloc
        prefix = o.path.lstrip('/')

        results = []
        
        hab_s3_client = self._boto3_session.client(service_name = 's3')

        paginator = hab_s3_client.get_paginator('list_objects_v2')
        pages = paginator.paginate(Bucket=bucket, Prefix=prefix)

        for page in pages:
            if 'Contents' in page:
                results.extend(page['Contents'])
                
        return ( results )

    def list_clusters( self, status: str = None): 
        """
        Lists current clusters and their statuses
        
        :param status: status to filter for
        
        :return dict: list of clusters
        """
        
        resp = finspace.client.list_clusters()

        clusters = []
        
        if 'clusters' not in resp:
            return( clusters )

        for c in resp['clusters']:
            if status is None:
                clusters.append(c)
            else:
                if c['clusterStatus']['state'] in status: 
                    clusters.append(c)

        return( clusters )
    
    def get_cluster( self, clusterId ):
        """
        Resize the given cluster to desired template
        
        :param cid: cluster id
        :param template: target template to resize to
        """

        clusters = self.list_clusters()
        
        for c in clusters:
            if c['clusterId'] == cid:
                return( c )
            
        return( None )
            
    def update_cluster( self, clusterId:str, template:str ): 
        """
        Resize the given cluster to desired template
        
        :param clusterId: cluster id
        :param template: target template to resize to
        """
        
        cluster = self.get_cluster(clusterId = clusterId)
        
        if cluster['currentTemplate'] == template:
            print(f"Already using template: {template}")
            return( cluster )
        
        self.client.update_cluster(clusterId=cid, template=template)
        
        return( self.get_cluster(clusterId = clusterId) )
        
        
    def wait_for_status( self, clusterId:str, status:str, sleep_sec = 10, max_wait_sec = 900 ):
        """
        Function polls service until cluster is in desired status.
        
        :param clusterId: the cluster's ID
        :param status: desired status for clsuter to reach
        :
        """
        total_wait = 0
        
        while True and total_wait < max_wait_sec:
            resp = self.client.list_clusters()

            this_cluster = None
            
            # is this the cluster?
            for c in resp['clusters']:
                if cid == c['clusterId']:
                    this_cluster = c

            if this_cluster is None:
                print(f"clusterId:{cid} not found")
                return( None )
            
            this_status = this_cluster['clusterStatus']['state']
                    
            if this_status.upper() != status.upper():
                print(f"Cluster status is {this_status}, waiting {sleep_sec} sec ...")
                time.sleep(sleep_sec)
                total_wait = total_wait + sleep_sec
                continue
            else:
                return( this_cluster )
            
    def get_working_location(self, locationType='SAGEMAKER'):
        resp = None
        location = self.client.get_working_location(locationType=locationType)
        
        if 's3Uri' in location:
            resp = location['s3Uri']
        
        return( resp )

    
