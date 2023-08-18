ACCOUNT_ID:""
ENV_ID:""

VPC_ID:"vpc-"
SECURITY_GROUP: "sg-"
SUBNET_ID:"subnet-"
AZ_MODE:"SINGLE"
AZ_ID:"use1-az6"

S3_BUCKET:"kdb-demo-XXXXXXXX-kms"

/ USER
KDB_USERNAME:"bob"

/ IAM Role
EXECUTION_ROLE:"arn:aws:iam::",ACCOUNT_ID,":role/kdb-all-user"

/ TP
TP:":172.31.22.143:5000"

