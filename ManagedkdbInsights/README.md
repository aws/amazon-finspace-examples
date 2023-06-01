# Projects
- [basic_tick](basic_tick)
- [boto](boto)

# Important notes

The parent directory contains common python scripts and symlinks to aws environment files (config and credentials). 

## Directions
- Copy env-example.py to a new file, ex: env.py 
- Replace the values found in the py files with values of your environment 
  - Your AWS Account ID for ACCOUNT_ID
  - Your FinSpace Managed kdb Insights Envirinment ID for ENV_ID
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
REMEMBER, the zip knows the paths, the filefile's filename dwill determine the directories created when unzipped.

```
zip -r -X code.zip code -x '*.ipynb_checkpoints*'
```
