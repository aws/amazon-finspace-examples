# HDB Backup
This script can be used to backup an existing filesystem based HDB to FinSpace with Managed kdd Insights.

## The Script
[hdb_backup,py](hdb_backup,py)

```
usage: hdb_backup.py [-h] -environmentId ENVIRONMENTID [-profile PROFILE] -hdb_directory HDB_DIRECTORY -database DATABASE -s3 S3 [-chunk_size CHUNK_SIZE] [-clean_up CLEAN_UP]
                     -start_date START_DATE -end_date END_DATE

optional arguments:
  -h, --help            show this help message and exit   
  -environmentId ENVIRONMENTID, -e ENVIRONMENTID   
                        Finspace with managed kdb Insights Environment ID   
  -profile PROFILE, -p PROFILE   
                        profile to use for API access   
  -hdb_directory HDB_DIRECTORY, -hdb HDB_DIRECTORY   
                        Location of the HDB to be backed up   
  -database DATABASE, -db DATABASE   
                        Managed kdb database name   
  -s3 S3, -s3 S3        S3 Staging location   
  -chunk_size CHUNK_SIZE, -cs CHUNK_SIZE   
                        Chunk Size   
  -clean_up CLEAN_UP, -c CLEAN_UP   
                        Clean up   
  -start_date START_DATE, -sd START_DATE   
                        start date   
  -end_date END_DATE, -ed END_DATE   
                        end date   
```