import datetime
import time
import boto3
from botocore.config import Config

# FinSpace class with Spark bindings

class SparkFinSpace(FinSpace):
    import pyspark
    def __init__(
        self, 
        spark: pyspark.sql.session.SparkSession = None,
        config = Config(retries = {'max_attempts': 0, 'mode': 'standard'}),
        dev_overrides: dict = None
    ):
        FinSpace.__init__(self, config=config, dev_overrides=dev_overrides)
        self.spark = spark # used on Spark cluster for reading views, creating changesets from DataFrames
        
    def upload_dataframe(self, data_frame: pyspark.sql.dataframe.DataFrame):
        resp = self.client.get_user_ingestion_info()
        upload_location = resp['ingestionPath']
#        data_frame.write.option('header', 'true').csv(upload_location)
        data_frame.write.parquet(upload_location)
        return upload_location
    
    def ingest_dataframe(self, data_frame: pyspark.sql.dataframe.DataFrame, dataset_id: str, change_type: str, wait_for_completion=True):
        print("Uploading data...")
        upload_location = self.upload_dataframe(data_frame)
        
        print("Data upload finished. Ingesting data...")
        
        return self.ingest_from_s3(upload_location, dataset_id, change_type, wait_for_completion, format_type='parquet')
    
    def read_view_as_spark(
        self,
        dataset_id: str,
        view_id: str
        ):
        # TODO: switch to DescribeMatz when available in HFS
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
        
        # Query Glue table directly with catalog function of spark
        return self.spark.table(f"`{glue_db_name}`.`{glue_table_name}`")
    
    def get_schema_from_spark(self, data_frame: pyspark.sql.dataframe.DataFrame):
        from pyspark.sql.types import StructType

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

        items = [i for i in data_frame.schema] 

        switcher = {
            "BinaryType"    : StringType,
            "BooleanType"   : BooleanType,
            "ByteType"      : IntegerType,
            "DateType"      : DateType,
            "DoubleType"    : FloatType,
            "IntegerType"   : IntegerType,
            "LongType"      : IntegerType,
            "NullType"      : StringType,
            "ShortType"     : IntegerType,
            "StringType"    : StringType,
            "TimestampType" : TimestampType,
        }

        
        for i in items:
#            print( f"name: {i.name} type: {i.dataType}" )

            habType = switcher.get( str(i.dataType), StringType)

            hab_columns.append({
                "dataType"    : habType, 
                "name"        : i.name,
                "description" : ""
            })

        return( hab_columns )