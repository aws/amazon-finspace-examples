# Projects
- [Basic Tick V3](basic_tick_V3)  
- [Boto Use Examples](boto)  
- [dbmaint](dbmaint)  
- [HDB Backup](hdb_backup)  
- [CSV Processing](processing_data)  
- [q Code Examples](q)  
- [TorQ](torq)  
- [Update Cluster](update_cluster)  

# Important notes

The parent directory contains common python scripts which are sym linked from the project directories. 

## Directions
- env.py contains environment specific information, enter details of your environment
  - Your AWS Account ID for ACCOUNT_ID
  - Your FinSpace Managed kdb Insights Environment ID for ENV_ID
  - Your VPC ID for VPC_ID
- Do above at the "ManagedkdbInsights" folder level
- Sym link the env.py file into sub-directories, such as boto and basic_tick
- Modify notebooks to import the env.py file
  - with symlink, the file will be 'local' to the notebook

# Appendix

## Update requirements.txt
Generating an updated requirements.txt file.

```
pip freeze > ~/ManagedKdbInsights/requirements.txt
```

## zip creation
REMEMBER, the zip knows the paths, the file's filename will determine the directories created when unzipped.

```
zip -r -X code.zip code -x '*.ipynb_checkpoints*'
```
