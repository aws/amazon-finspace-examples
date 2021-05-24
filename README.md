# Amazon FinSpace Examples. 
This repository contains example notebooks and python scripts that show how to work with [Amazon FinSpace](https://aws.amazon.com/finspace/).

## Examples

### Notebooks: Inside Amazon FinSpace

These notebooks are intended to be run from the FinSpace managed notebook environment. Notebooks will reference a dataset (and others a permission group as well) found in FinSpace, be sure you have entered the empty identifiers for dataset_id, view_id, and basicPermissionGroupId found in your environment installation. All example notebooks assume that the Capital Markets Sample Data bundle was installed with the FinSpace environment. Some example notebooks make use of Utility classes found in the Utilities folder (e.g. finspace.py and finspace_spak.py) be sure to have run the '%load' for the python files twice, first to load the file contents into the notebook, and a second time to ensure the code is run and pushed onto your Spark cluster.

- [Analyzing petabytes of trade and quote data with Amazon FinSpace](notebooks/analyze_trade_and_quote_data/) shows how to use the FinSpace Time Series Library.  
- [Cluster Management](notebooks/cluster_management/) demonstrates using the cluster management APIs from within a  notebook.  
- [Collect Timebars and Summarize](notebooks/collect_timebars_and_summarize/) demonstrates how to create a summary time-bar dataset and add it to FinSpace.  
- [Compute and Plot Volatility from TAQ](notebooks/compute_and_plot_volatility_from_taq/) demonstrates how to compute and plot valatility using the FinSpace Time Series Libraries.  
- [Working in FinSpace](notebooks/working_in_finspace/) how to get and use your scratch space within FinSpace. 
- [Technical Indicators](notebooks/technical_indicators/) demonstrates the creation of a Spark DataFrame that uses all of the FinSpace technical indicators. 

### Notebooks: Outside Amazon FinSpace

These notebooks are intended to be run from outside of FinSpace. 

- [Exploring FinSpace APIs](notebooks/exploring_finspace_apis/) demonstrates common FinSpace APIs calls you will use when analyzing data within FinSpace notebooks.  
- [Remote Cluster Management](notebooks/remote_cluster_management/) shows how to use the cluster management APIs from outside of FinSpace.
- [S3 Import](notebooks/s3_import) shows how to import data from an external (to FinSpace) S3 bucket into a FinSpace dataset

### Python: Helper Code

- [Utility Classes](notebooks/Utilities/) that are used on the notebooks that facilitate the use of the FinSpace APIs.  

### Notebooks: Outside FinSpace
These notebooks are intended to be run from outside of FinSpace, communicating with the FinSpace service using the FinSpace APIs.

## FAQ

*How do I contribute my own example notebook?*

- Although we're extremely excited to receive contributions from the community, we're still working on the best mechanism to take in examples from external sources.  Please bare with us in the short-term if pull requests take longer than expected or are closed.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

