#  Managed kdb Insights q Examples
Here you will find q code examples using **Managed kdb Insights**.

## Library: [aws.q](aws.q)
There are two core use cases where [aws.q](aws.q) can help
1. Developing Q code that is intended to be run from **Managed kdb Insights** clusters
2. Remotely managing an Amazon FinSpace with Managed kdb Insights environment from Q ([welcome.q](welcome.q) is an example of this)

## Directories
[qcode](qcode)  
Example of local Q code that will be deployed to clusters, includes an init script ([init.q](qcode/init.q)) and library functions ([lib.q](qcode/lib.q)).   

## Scripts
[aws.q](aws.q)   
Q functions in the `.aws` namespace that call the underlying AWS CLI APIs. You will need to have configured the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) and set your credentials to access your AWS account and the FinSpace environment you have already created.

Most functions require initializing the local environment by calling `.aws.prefs`. There's more information in code comments.

Note: when using this library for use case 1 (simulating a **Managed kdb Insights** environment outside FinSpace), please keep in mind that error handling is different between the two environments. Functions in [aws.q](aws.q) fail when they hit an error, whereas on-cluster functions generally trap errors and return Q objets. 

[env.q](env.q)    
This script sets environment-specific variables such as AWS account and FinSpace environment ID. An example of its use can be found in the [welcome.q](welcome.q) script where loading it sets environment variables of a **Managed kdb Insights** environment. This is an example.

[welcome.q](welcome.q)   
Q example of the [boto based welcome notebook](https://github.com/aws/amazon-finspace-examples/blob/main/ManagedkdbInsights/boto/welcome.ipynb). This script uses the [aws.q](aws.q) functions.

