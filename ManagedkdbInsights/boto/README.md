# FinSpace Managed kdb Boto Examples
Collection of notebooks to demonstrate uses of the FinSpace AWS CLI and Boto libraries (Python).

## Setup
- Parent directory python scripts are symlinked to this directory and then referenced directly in notebooks
- env_*.py files contain environemnt specific variables such as ENV_ID, and auth credentials
  - Actual files are in parent directory, sym linked to this directory


## Notebooks

[CLI_Environment_Setup](CLI_Environment_Setup.ipynb)
Notebook using teh AWS CLI to create and setup a basic Managed mkb Insights environment. Setup includes environment creation, database creation and population, user creation, getting a connection string to the cluster.

[create_cluster_HDB](create_cluster_HDB.ipynb)
Creates an HDB cluster using AWS Python boto library.

[create_cluster_RDB](create_cluster_RDB.ipynb)
Creates an RDB cluster using AWS Python boto library.

[generate_welcome_data](generate_welcome_data.ipynb)
q Notebook to generate the hdb database.

[delete_cluster](delete_cluster.ipynb)
Deletes the given cluster.

[delete_db](delete_db.ipynb)
Deletes the given database.

[get_cluster](get_cluster.ipynb)
Displays all information about the given cluster.

[get_database](get_database.ipynb)
Displays all information about the given datbase, including its changesets.

[get_environment](get_environment.ipynb)
Get all information about the given environment.

[list_clusters](list_clusters.ipynb)
Lists all clisters of an environment.

[list_databases](list_databases.ipynb)
Lists all databases of an environment.

[query_cluster](query_cluster.ipynb)
q Notebook to show how to connect to and query a cluster.

[query_env](query_env.ipynb)
Displays all information about the given environment. Information includes databases and clusters.

[query_welcomedb](query_welcomedb.ipynb)
q Notebook to demonstrate how to query the welcome database.

[welcome](welcome.ipynb)
Welcome notebook, demonstrates use of the Python AWS boto libraries to create the welcome datbase and a cluster to query it.

## Python
Python files.

[get_connection_string](get_connection_string.py)
Python file meant to be used from the command line to generate a cluster's connection string.

[managed_kx](managed_kx.py)
Utility functions for the finspace service atop the AWS Python boto library.

## q Code
Example q files.

### Code Folder
[init.q](code/init.q)
Example script for initializing the cluster, accepts two arguments (dbname and codebase). If dbname folder exists, will load that into memory. The codebase is used to demonstrate how to load relative files located in the zip file provided at cluster creation, in this case lib.q.

[lib.q](code/lib.q)
Example library loaded by init.q.
