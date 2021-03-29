# Amazon FinSpace Examples. 
This repository contains example notebooks and python scripts that show how to work with [Amazon FinSpace](https://aws.amazon.com/finspace/).

## Examples

### Notebooks: Inside FinSpace

These notebooks are intended to be run from the FinSpace managed notebook environment.

- [Analyzing petabytes of trade and quote data with Amazon FinSpace](amazon-finspace-examples/notebooks/analyze_trade_and_quote_data/) shows how to use the FinSpace Time Series Library.  
- [Cluster Management](amazon-finspace-examples/notebooks/cluster_management/) demonstrates using the cluster management APIs from within a  notebook.  
- [Collect Timebars and Summarize](amazon-finspace-examples/notebooks/collect_timebars_and_summarize/) demonstrates how to create a summary time bar dataset and add it to FinSpace.  
- [Compute and Plot Volatility from TAQ](amazon-finspace-examples/notebooks/compute_and_plot_volatility_from_taq/) demonstrates how to compute and plot valatility using the finSpace Time Series Library.  
- [Exploring FinSpace APIs](amazon-finspace-examples/notebooks/exploring_finspace_apis/) demonstration of common FinSpace APIs calls you will use when analyzing data within notebooks in FinSpace.  
- [Working in FinSpace](amazon-finspace-examples/notebooks/WorkingInFinSpace/) how to get and use your scratch space within finSpace. 
- [Technical Indicators](amazon-finspace-examples/notebooks/technical_indicators/) Demonstration of creating a DataFrame that uses all the FinSpace technical indicators. 

### Notebooks: Outside FinSpace

These notebooks are intended to be run from outside of FinSpace. 

- [Putting Data into FinSpace](amazon-finspace-examples/notebooks/putting_data_into_finspace/) show how to use the FinSpace APIs to create and populate a dataset. 
- [Remote Cluster Management](amazon-finspace-examples/notebooks/remote_cluster_management/) shows how to use the cluster management APIs from outside of FinSpace.

### Python: Helper Code

- [Utility Classes](amazon-finspace-examples/notebooks/Utilities/) that are used on the notebooks that facilitate the use of the inSpace boto3 APIs.  

### Notebooks: Outside FinSpace
These notebooks are intended to be run from outside of FinSpace, communicating with the FinSpace service using the FinSpace APIs.

## FAQ

*How do I contribute my own example notebook?*

- Although we're extremely excited to receive contributions from the community, we're still working on the best mechanism to take in examples from external sources.  Please bare with us in the short-term if pull requests take longer than expected or are closed.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

