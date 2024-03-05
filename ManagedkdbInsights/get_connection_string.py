import argparse

from managed_kx import *

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-profile",    "-p", help="Profile to use for access", default=None)
    parser.add_argument("-env",        "-e", help="environment ID", required=True)
    parser.add_argument("-cluster",    "-c", help="Cluster Name", required=True)
    parser.add_argument("-username",   "-u", help="kdb Username", required=True)

    parser.add_argument("-string",    "-str", help="print as string", default=False, action=argparse.BooleanOptionalAction)
    parser.add_argument("-symbol",    "-sym", help="print as symbol", default=False, action=argparse.BooleanOptionalAction)
    parser.add_argument("-parts",   "-parts", help="print parts", default=False, action=argparse.BooleanOptionalAction)

    args = parser.parse_args()

    session = boto3.Session(profile_name = args.profile)

    service_name = 'finspace'

    client = session.client(service_name=service_name)

    conn_str = get_kx_connection_string(client, 
                                        environmentId=args.env, 
                                        clusterName=args.cluster, 
                                        userName=args.username, 
                                        boto_session=session)

    if bool(args.string):
        print()
        print("Single String")
        print(80*"-")
        print(conn_str)
        print(80*"-")

    if bool(args.symbol):
        print()
        print("Symbol")
        print(80*"-")
        sym_parts = conn_str.split("/")

        print(f"`{sym_parts[2]}")
        print(80*"-")

    if bool(args.parts):
        print()
        print("In Parts")
        print(80*"-")

        conn_parts = conn_str.split(":")

        host=conn_parts[2].strip("/")
        port = int(conn_parts[3])
        username=conn_parts[4]
        password=conn_parts[5]

        print(f"""
HOST: {host}
PORT: {port}
USERNAME: {username}
PASSWORD:
{password}""")

        print(80*"-")
