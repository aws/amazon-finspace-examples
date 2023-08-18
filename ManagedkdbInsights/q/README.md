#  Managed kdb Insights q Examples
Here you will find q code examples using Managed kdb Insights

## Directories
[qcode](qcode)     
Example of local q code that will be deployed to clusters, includes an init script (init.q) and library functions (lib.q).   

## Scripts

[aws.q](aws.q)   
q functions in the .aws namespace that call the underlying AWS CLI APIs. You will need to have configured the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) and set your credentials to access your AWS account and the finspace environment you have already created.

[env_example.q](env_example.q)    
This script sets environment specific variables such as AWS account and FinSpace environment ID. An example of its use can be founf in the [welcome.q](welcome.q) script where loading it sets specific environment variables of a Managed kdb Insights environment. This is an example.

[welcome.q](welcome.q)   
q example of the [boto based welcome notebook](https://github.com/aws/amazon-finspace-examples/blob/main/ManagedkdbInsights/boto/welcome.ipynb). This script uses the aws.q functions.

