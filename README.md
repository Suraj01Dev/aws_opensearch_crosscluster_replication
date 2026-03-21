# Building Resilient OpenSearch Clusters with Cross-Cluster Replication

This project demonstrates how to perform AWS OpenSearch cross-cluster replication.  
AWS OpenSearch cross-cluster replication is not straightforward as it has various constraints involved. When the OpenSearch is powered with the Elastic engine below version 7.7, it becomes hard to perform cross-cluster replication. There is no default method provided by AWS to perform this.

## Performing the POC

Follow the below steps to perform this POC.

### Setting up the Workspace

```
git clone https://github.com/Suraj01Dev/aws_opensearch_crosscluster_replication.git
```

```
cd aws_opensearch_crosscluster_replication
```

```
uv sync
```

```
source .venv/bin/activate
```

### Creating the Snapshot IAM Role

**Purpose:** OpenSearch requires a dedicated IAM role to access S3 for snapshot operations. This role grants permissions for backup/restore across clusters.

```
# 1. Create the SnapshotRole
aws iam create-role --role-name SnapshotRole --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "es.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'
```

```
# 2. Attach S3 policy for snapshot access
aws iam attach-role-policy --role-name SnapshotRole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

**Note:** Copy the generated `ROLE_ARN` output from step 1 for use in environment variables. This role allows both clusters to read/write snapshots to the S3 bucket.

### Creating the OpenSearch POC Stack

**Creating the OpenSearch POC stack:** This involves an OpenSearch cluster in the ap-south-1 region and another cluster in the us-east-1 region for DR. It also creates an S3 bucket for the snapshots. To execute this, run the below command:

```
bash create_es_replication_stack.sh
```

Wait for 15-20 mins for this to take effect!  
Once done, follow the steps mentioned in the Jupyter notebook.

### Setting up the Environment Variables

Once the OpenSearch stack is created, it's time to populate the `.env` file.

```
DESTINATION_ENDPOINT=
SOURCE_ENDPOINT=
SOURCE_REGION=ap-south-1
DESTINATION_REGION=us-east-1
ROLE_ARN=<Role_ARN>
BUCKET_NAME=
REPOSITORY_NAME=
SNAPSHOT_NAME=
```

`DESTINATION_ENDPOINT` and `SOURCE_ENDPOINT` will be different each time you execute the script, so copy the endpoints and paste them here.

The cluster will be created in us-east-1 as the DR region and ap-south-1 as the primary region. The ARN of the snapshot role should be pasted here. The name of the bucket will be output by the script and should be pasted here. Repository name and snapshot name are up to you; any name can be used.

### Jupyter Notebook Steps

**Steps followed:**

- Import the necessary libraries
- Set up the AWS authentication
- Load the env variables
- Populate the OpenSearch with some data in the south cluster
- Check the populated data
- Register the S3 repo in the OpenSearch for the backup in both the clusters
- Create a snapshot of the data in the south cluster
- Restore the data onto the us-east-1 cluster
- Finally view the restored data

### Cleanup Instructions

To delete the OpenSearch stack after the POC, execute the below command:
```
bash delete_es_replication_stack.sh
```