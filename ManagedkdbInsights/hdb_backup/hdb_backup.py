import os
import boto3
import argparse
import awswrangler as wr
import pandas as pd

from managed_kx import *

def divide_chunks(l, n):

    # looping till length l
    for i in range(0, len(l), n):
        yield l[i:i + n]

#
# This program assumes that you have credentials in $HOME/.aws/credentials
# those credentials must also be linked to a FinSpace user with ability to create datasets
#

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-environmentId",  "-e", help="Finspace with managed kdb Insights Environment ID", required=True)
    parser.add_argument("-profile",        "-p", help="profile to use for API access", default ="default")
    parser.add_argument("-hdb_directory",  "-hdb", help="Location of the HDB to be backed up", required=True)
    parser.add_argument("-database",       "-db", help="Managed kdb database name", required=True)
    parser.add_argument("-s3",             "-s3", help="S3 Staging location", required=True)
    parser.add_argument("-chunk_size",     "-cs", help="Chunk Size", type=int, default=30)
    parser.add_argument("-clean_up",       "-c", help="Clean up", default=True)
    parser.add_argument("-start_date",     "-sd", help="start date", required=True)
    parser.add_argument("-end_date",       "-ed", help="end date", required=True)

    args = parser.parse_args()

    ENV_ID = args.environmentId
    DB_NAME = args.database

    # use the user's AWS credentials from environment
    session = boto3.Session(profile_name = args.profile)

    service_name = 'finspace'
    client = session.client(service_name=service_name)

    # check arguments
    #   - environment ID, ability to get the environment details (confirms permissions)
    #   - kdb database exists
    #   - HDB location and files exist (sym and date partitions)
    #   - if backing up all dates, get the list of all dates from local disk
    #   - S3 bucket exists
    # -------------------------------------------------------------


    # Get dates for the range
    dates = pd.date_range(start=args.start_date, end=args.end_date)
    date_list = list(divide_chunks(dates, args.chunk_size))

    # copy sym and dates to s3, use system s3 sync

    # sync sym
    os.system(f"aws s3 cp {args.hdb_directory}/sym {args.s3}/sym")

    # sync dates
    for l in date_list:
        for d in l:
            source_date = f"{args.hdb_directory}/{d.strftime('%Y.%m.%d')}"
            dest_date = f"{args.s3}/{d.strftime('%Y.%m.%d')}"

            if os.path.exists(source_date):
                os.system(f"aws s3 sync {source_date} {dest_date}")
            else:
                print(f"Source: {source_date} does not exist")

    # all data to import now staged on s3

    # create chunks of dates
    dir_list = wr.s3.list_directories(f"{args.s3}/*", boto3_session=session)
    s3_list = list(divide_chunks(dir_list, args.chunk_size))

    # By chunk_size, create_kx_changeset and push to database in Managed kdb
    changes = []

    # day import, starting with sym file, then date directories...
    changes = [{'changeType': 'PUT', 's3Path': f"{args.s3}/sym", 'dbPath': f"/"}]

    # all dates to import
    dir_list = wr.s3.list_directories(f"{args.s3}/*", boto3_session=session)

    # create chunks of dates
    d_list = list(divide_chunks(dir_list, 30))

    # by chunk of dates....
    for l in d_list:
        for d in l:
            db_path = os.path.basename(os.path.normpath(d))
            changes.append({'changeType': 'PUT', 's3Path': d, 'dbPath': f"/{db_path}/"})

        resp = client.create_kx_changeset(environmentId=ENV_ID, databaseName=DB_NAME,
                                          changeRequests=changes)

        resp.pop('ResponseMetadata', None)
        changeset_id = resp['changesetId']

        # IMPORTANT: WAIT!
        wait_for_changeset_status(client, environmentId=ENV_ID, databaseName=DB_NAME, changesetId=changeset_id, show_wait=True)
        print("**Done**")

        # clear list
        changes = []

    # Print New State of Database and its changesets
    note_str = ""
    c_set_list = []

    try:
        c_set_list = client.list_kx_changesets(environmentId=ENV_ID, databaseName=DB_NAME)['kxChangesets']
    except:
        note_str = "<<Could not get changesets>>"

    print(100*"=")
    print(f"Database: {DB_NAME}, Changesets: {len(c_set_list)} {note_str}")
    print(100*"=")

    # sort by create time
    c_set_list = sorted(c_set_list, key=lambda d: d['createdTimestamp'])

    for c in c_set_list:
        c_set_id = c['changesetId']
        print(f"Changeset ({c['status']}): {c_set_id}: Created: {c['createdTimestamp']}")
        c_rqs = client.get_kx_changeset(environmentId=ENV_ID, databaseName=DB_NAME, changesetId=c_set_id)['changeRequests']

        chs_pdf = pd.DataFrame.from_dict(c_rqs).style.hide(axis='index')
        print(chs_pdf.to_string())
