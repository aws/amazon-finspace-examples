ACCOUNT_ID:"829845998889"
ENV_ID:"jlcenjvtkgzrdek2qqv7ic"

VPC_ID:"vpc-0fe2b9c50f3ad382f"
SECURITY_GROUP: "sg-0c99f1cfb9c3c7fd9"
SUBNET_ID:"subnet-04052219ec25b062b"
AZ_MODE:"SINGLE"
AZ_ID:"use1-az6"

/S3_BUCKET:"kdb-demo-829845998889"
S3_BUCKET:"kdb-demo-829845998889-kms"

/ USER
KDB_USERNAME:"bob"

/ IAM Role
EXECUTION_ROLE:"arn:aws:iam::",ACCOUNT_ID,":role/kdb-all-user"

/ TP
TP:":172.31.22.143:5000"

