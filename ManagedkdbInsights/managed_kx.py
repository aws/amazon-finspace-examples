import os
import boto3
import sys
import time
import json
import datetime

import botocore.exceptions

import pandas as pd

# set width of pandas tables
pd.set_option('display.max_colwidth', None)

#
# Functions
# ----------------------------------------------------------------------------

def get_kx_environment_id(client):
    l = list_kx_environments(client)
    envs = []
    
    for e in l:
        if e['status'] == "CREATED":
            envs.append(e)
    
    if len(envs) != 1:
        print(f"Environment count: {len(envs)} cannot infer which to use")
        return None

    # determined list len == 1, return that environmentId
    return envs[0].get('environmentId')


def list_kx_environments(client):
    envs = []

    envs.extend(client.list_kx_environments()['environments'])

    return envs


def list_kx_databases(client, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)
        
    resp = client.list_kx_databases(environmentId=environmentId)

    results = resp['kxDatabases']

    while "nextToken" in resp:
        resp = client.list_kx_databases(environmentId=environmentId, nextToken=resp['nextToken'])
        results.extend(resp['kxDatabases'])

    return results


def list_kx_clusters(client, clusterType=None, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    resp = None
    
    if clusterType is not None:
        resp = client.list_kx_clusters(environmentId=environmentId, clusterType=clusterType)
    else:
        resp = client.list_kx_clusters(environmentId=environmentId)

    results = resp['kxClusterSummaries']

    while "nextToken" in resp:
        if clusterType is not None:
            resp = client.list_kx_clusters(environmentId=environmentId, clusterType=clusterType, nextToken=resp['nextToken'])
        else:
            resp = client.list_kx_clusters(environmentId=environmentId, nextToken=resp['nextToken'])

        results.extend(resp['kxClusterSummaries'])

    return results


def list_kx_changesets(client, databaseName, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    resp = client.list_kx_changesets(environmentId=environmentId, databaseName=databaseName)
    
    results = resp.get('kxChangesets', [])

    while "nextToken" in resp:
        resp = client.list_kx_changesets(environmentId=environmentId, nextToken=resp['nextToken'])
        results.extend(resp['kxChangesets'])
    
    return results


def has_database(client, databaseName, environmentId: str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    has_database = True

    try:
        resp = client.get_kx_database(environmentId=environmentId, databaseName=databaseName)
        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
            sys.stderr.write("Error:\n {resp}")
        else:
            resp.pop('ResponseMetadata', None)
    except client.exceptions.ResourceNotFoundException:
        has_database = False

    return has_database


def has_cluster(client, clusterName, environmentId: str = None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    has_cluster = True

    try:
        resp = client.get_kx_cluster(environmentId=environmentId, clusterName=clusterName)
        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
            sys.stderr.write("Error:\n {resp}")
        else:
            resp.pop('ResponseMetadata', None)
    except client.exceptions.ResourceNotFoundException:
        has_cluster = False

    return has_cluster


def get_kx_environment(client, environmentId: str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)
    
    try:
        resp = client.get_kx_environment(environmentId=environmentId)
    except client.exceptions.ResourceNotFoundException:
        return None

    if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
            sys.stderr.write("Error:\n {resp}")
    else:
        resp.pop('ResponseMetadata', None)

    resp = resp.get('environment', resp)    

    return resp
    
    
def wait_for_environment_status(client, environmentId:str, status: str='CREATED', sleep_sec=10, max_wait_sec=1200, show_wait=False):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    """
    Function polls until environment is in desired status
    """
    total_wait = 0

    while True and total_wait < max_wait_sec:
        resp = get_kx_environment(client, environmentId=environmentId)

        if resp is None:
            print(f"Environment: {environmentId} does not exist")
            continue
        
        a_status = resp.get('status')
        
        if a_status is None:
            print("status is None, returning")
            return resp

        if a_status.upper() == "FAILED_CREATION":
            print(f"Failed, total wait {datetime.timedelta(seconds=total_wait)}")

            error_info = resp.get('errorInfo', None)
            if error_info is not None:
                print(f"Type: {error_info.get('errorType', '')}")
                print(f"Message: {error_info.get('errorMessage', '')}")
                print(error_info)

#            print(resp)
            return None
        elif a_status.upper() != status.upper():
            if show_wait: 
                print(f"Status is {a_status}, total wait {datetime.timedelta(seconds=total_wait)}, waiting {sleep_sec} sec ...")

            time.sleep(sleep_sec)
            total_wait = total_wait + sleep_sec
            continue
        else:
            return resp

    return None


def wait_for_changeset_status(client, environmentId:str, databaseName: str, changesetId: str, status: str='COMPLETED', sleep_sec=10, max_wait_sec=1200, show_wait=False):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    """
    Function polls until changeset is in desired status
    """
    total_wait = 0

    while True and total_wait < max_wait_sec:
        try:
            resp = client.get_kx_changeset(environmentId=environmentId, databaseName=databaseName, changesetId=changesetId)
        except client.exceptions.ResourceNotFoundException:
            resp = None
            continue

        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
                sys.stderr.write("Error:\n {resp}")
        else:
            resp.pop('ResponseMetadata', None)

        a_status = resp.get('status')

        if a_status is not None and a_status.upper() == "FAILED":
            print(f"Failed, total wait {datetime.timedelta(seconds=total_wait)}")

            error_info = resp.get('errorInfo', None)
            if error_info is not None:
                print(f"Type: {error_info.get('errorType', '')}")
                print(f"Message: {error_info.get('errorMessage', '')}")
                print(error_info)

#            print(resp)
            return None
        elif a_status is not None and a_status.upper() != status.upper():
            if show_wait: 
                print(f"Status is {a_status}, total wait {datetime.timedelta(seconds=total_wait)}, waiting {sleep_sec} sec ...")

            time.sleep(sleep_sec)
            total_wait = total_wait + sleep_sec
            continue
        else:
            return resp

    return None


def wait_for_cluster_status(client, environmentId:str, clusterName: str, status: str='RUNNING', sleep_sec=30, max_wait_sec=3600, show_wait=False):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    """
    Function polls until cluster is in desired status
    """
    total_wait = 0

    while True and total_wait < max_wait_sec:
        try:
            resp = client.get_kx_cluster(environmentId = environmentId, clusterName=clusterName)

            if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
                    sys.stderr.write("Error:\n {resp}")
            else:
                resp.pop('ResponseMetadata', None)

            this_cluster = resp
        except client.exceptions.ResourceNotFoundException:
            return None

        if this_cluster is None:
            print(f"cluster:{clusterName} not found")
            return None

        this_status = this_cluster['status']

        if this_status.upper() == "CREATE_FAILED":
            print(f"Cluster: {this_status}, total wait {datetime.timedelta(seconds=total_wait)}")

            error_info = resp.get('errorInfo', None)
            if error_info is not None:
                print(f"Type: {error_info.get('errorType', '')}")
                print(f"Message: {error_info.get('errorMessage', '')}")
                print(error_info)

#            print(resp)
            return None
        elif this_status.upper() != status.upper():
            if show_wait:
                print(f"Cluster: {clusterName} status is {this_status}, total wait {datetime.timedelta(seconds=total_wait)}, waiting {sleep_sec} sec ...")
            time.sleep(sleep_sec)
            total_wait = total_wait + sleep_sec
            continue
        else:
            if show_wait:
                print(f"Cluster: {clusterName} status is now {this_status}, total wait {datetime.timedelta(seconds=total_wait)}")
            return this_cluster

    print(f"No Cluster after {datetime.timedelta(seconds=total_wait)}")


def get_kx_cluster(client, clusterName: str, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    try:
        resp = client.get_kx_cluster(environmentId=environmentId, clusterName=clusterName)
    except client.exceptions.ResourceNotFoundException:
        return None

    if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
            sys.stderr.write("Error:\n {resp}")
    else:
        resp.pop('ResponseMetadata', None)

    resp = resp.get('environment', resp)

    return resp
    
    
def get_kx_connection_string(client, clusterName: str, userName: str, boto_session, endpoint_url: str=None, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    resp=client.get_kx_user(environmentId=environmentId, userName=userName)

    userArn = resp.get("userArn")
    iamRole = resp.get("iamRole")

    sts_client = boto_session.client(service_name='sts')

    resp = sts_client.assume_role(RoleArn=iamRole, RoleSessionName="Connect-to-kdb-cluster")

    creds = resp.get('Credentials')

    # session for calling get connection String
    cred_session = boto3.Session(
        aws_access_key_id=creds.get('AccessKeyId'),
        aws_secret_access_key=creds.get('SecretAccessKey'),
        aws_session_token=creds.get('SessionToken')
    )

    cred_client = cred_session.client(service_name='finspace', endpoint_url=endpoint_url)
    resp=cred_client.get_kx_connection_string(environmentId=environmentId, userArn=userArn, clusterName=clusterName)
    
    return resp.get("signedConnectionString", None)
   

def get_clusters(client, clusterType: str=None, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    svcs=[]

    try:
        svcs = list_kx_clusters(client, environmentId=environmentId, clusterType=clusterType)
    except botocore.exceptions.ClientError as error:
        code = error.response['Error']['Code']
        print(f"ClientError: {code} to environmentId: {environmentId}")
        return None
    except:
        return None

    svcs = sorted(svcs, key=lambda d: d['clusterName']) 

    dict_l = []

    for s in svcs:
        svc_name = s['clusterName']

        resp = client.get_kx_cluster(environmentId=environmentId, clusterName=svc_name)
        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
                sys.stderr.write("Error:\n {resp}")
        else:
            resp.pop('ResponseMetadata', None)

        svc_details = resp

        d = {}

        k_list = ['clusterName', 'status', 
                  'clusterType', 'capacityConfiguration', 'commandLineArguments', 
                  'clusterDescription', 'lastModifiedTimestamp', 'createdTimestamp']

        for k in k_list:
            d[k] = resp.get(k, None)
        
        dbs = resp.get('databases', None)
        
        if dbs is not None:
            db = dbs[0]
            d['databaseName'] = db.get('databaseName', None)
            d['cacheConfigurations'] = db.get('cacheConfigurations', None)
        else:
            d['databaseName'] = None

        dict_l.append(d)

    return pd.DataFrame.from_dict(dict_l)

def print_clusters(client, print_empty=False, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    svcs=[]
    
    try:
        svcs = list_kx_clusters(client, environmentId=environmentId)
    except:
        svcs=[]

    if len(svcs) > 0 or print_empty == True:        
        print(f"Environment: {environmentId} Clusters found: {len(svcs)}")
    
    svcs = sorted(svcs, key=lambda d: d['clusterName']) 

    for s in svcs:
        svc_name = s['clusterName']

        resp = client.get_kx_cluster(environmentId=environmentId, clusterName=svc_name)
        if resp['ResponseMetadata']['HTTPStatusCode'] != 200:
                sys.stderr.write("Error:\n {resp}")
        else:
            resp.pop('ResponseMetadata', None)

        svc_details = resp
        
        print(f"{svc_name.ljust(20)} {svc_details['status'].ljust(13)} {svc_details.get('connectionString', '')}")    
        
def dump_database(client, db_name:str, changset_details=False, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    c_set_list=[]
    note_str=""

    db = client.get_kx_database(environmentId=environmentId, databaseName=db_name)

    try:
        c_set_list = client.list_kx_changesets(environmentId=environmentId, databaseName=db_name)['kxChangesets']
    except:
        note_str = "<<Could not get changesets>>"

    print(100*"=")
    print(f"Database: {db_name}, Changesets: ")
    print(f"{db.get('description', '')}")
    print(f"Bytes: {db['numBytes']:,} Changesets: {db['numChangesets']:,} Files: {db['numFiles']:,}")
    print(100*"-")

    # sort by create time
    c_set_list = sorted(c_set_list, key=lambda d: d['createdTimestamp'], reverse=True) 

    if changset_details:
        for c in c_set_list:
            c_set_id = c['changesetId']
            print(f"Changeset ({c['status']}): {c_set_id}: Created: {c['createdTimestamp']}")
            c_rqs = client.get_kx_changeset(environmentId=environmentId, databaseName=db_name, changesetId=c_set_id)['changeRequests']

            chs_pdf = pd.DataFrame.from_dict(c_rqs)# .style.hide_index()
            display(chs_pdf)
        print()
    else:
        display( pd.DataFrame.from_dict(c_set_list) )

        
def get_pykx_connection(client, clusterName: str, userName: str, boto_session, endpoint_url: str=None, environmentId:str=None):
    if environmentId is None:
        environmentId = get_kx_environment_id(client)

    import pykx as kx

    conn_str = get_kx_connection_string(client, 
                                      environmentId=environmentId, clusterName=clusterName, userName=userName,
                                      boto_session=boto_session, endpoint_url=endpoint_url)

    conn_parts = conn_str.split(":")

    host=conn_parts[2].strip("/")
    port = int(conn_parts[3])
    username=conn_parts[4]
    password=conn_parts[5]

    return kx.QConnection(host=host, port=port, username=username, password=password, tls=True)
        
    