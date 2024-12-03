# TorQ - Amazon FinSpace Starter Pack
Example of deploying a TorQ based application on Amazon FinSpace with Managed kdb Insights.

Based on the TorQ Amazon FinSpace Starter Pack but uses Scaling Groups and Shared Volumes for cost savings.

Reference: [TorQ Amazon FinSpace Starter Pack](https://dataintellecttech.github.io/TorQ-Amazon-FinSpace-Starter-Pack/)

## Steps
- Edit [env.py](env.py) set variables for your environment
- Run the [create_all](create_all.ipynb) notebook
  - Creates all resources and starts all clusters
- Use PyKX to query the gateway in the [pykx_query_all](pykx_query_all.ipynb) notebook
- Updatecode across all clusters with the [refresh_code](refresh_code.ipynb) notebook

To clean up and delete all resources, run the [delete_all](delete_all.ipynb) notebook.

### Other Files
[finspace_torq.q](finspace_torq.q) q script that sets environment variables then calls torq.q   
[config.py](config.py) configuration details of the application   
[managed_kx.py](managed_kx.py) Utility functions atop boto3 APIs   
