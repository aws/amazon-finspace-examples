# Dataset Browser Notebooks 
These notebooks are intended to be run from the FinSpace managed notebook environment. 
Notebooks will reference a dataset (and others a permission group as well) found in FinSpace, 
be sure you have entered the empty identifiers for dataset_id, view_id, and basicPermissionGroupId found in your 
environment installation. All example notebooks assume that the Capital Markets Sample Data bundle was installed 
with the FinSpace environment. Some example notebooks make use of Utility classes found in the Utilities folder 
(e.g. finspace.py and finspace_spak.py) be sure to have run the '%load' for the python files twice, first to load 
the file contents into the notebook, and a second time to ensure the code is run and pushed onto your Spark cluster.  

- [Analyzing petabytes of trade and quote data with Amazon FinSpace](notebooks/analyze_trade_and_quote_data) shows how to use the FinSpace Time Series Library.  
- [Cluster Management](notebooks/cluster_management) demonstrates using the cluster management APIs from within a  notebook.  
- [Collect Timebars and Summarize](notebooks/collect_timebars_and_summarize) demonstrates how to create a summary time-bar dataset and add it to FinSpace.  
- [Compute and Plot Volatility from TAQ](notebooks/compute_and_plot_volatility_from_taq) demonstrates how to compute and plot volatility using the FinSpace Time Series Libraries.  
- [Technical Indicators](notebooks/technical_indicators) demonstrates the creation of a Spark DataFrame that uses all the FinSpace technical indicators. 
- [S3 Import](notebooks/s3_import) shows how to import data from an external (to FinSpace) S3 bucket into a FinSpace dataset
- [Using Third Party APIs](notebooks/third_party_apis) shows how you can install and use third party APIs from FinSpace
- [Custom Calendars](notebooks/custom_calendar) shows how you can create a custom calendar for the time series fill and filter stage

### Python: Helper Code  
- [Utility Classes](notebooks/Utilities) facilitates the use of the FinSpace APIs.  

