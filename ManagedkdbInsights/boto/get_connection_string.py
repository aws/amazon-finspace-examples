import argparse

from managed_kx import *

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-profile",    "-p", help="Profile to use for access", default=None)
    parser.add_argument("-env",        "-e", help="environment ID", required=True)
    parser.add_argument("-cluster",    "-c", help="Cluster Name", required=True)
    parser.add_argument("-username",   "-u", help="kdb Username", required=True)

    args = parser.parse_args()

    session = boto3.Session(profile_name = args.profile)

    service_name = 'finspace'

    client = session.client(service_name=service_name)

    conn_str = get_kx_connection_string(client, 
                                        environmentId=args.env, 
                                        clusterName=args.cluster, 
                                        userName=args.username, 
                                        boto_session=session)
    
    print(conn_str)