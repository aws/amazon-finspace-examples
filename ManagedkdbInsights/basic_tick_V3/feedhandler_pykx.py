import asyncio
import argparse
import boto3
import sys
import time

import pandas as pd
import pykx as kx

from managed_kx import *

async def main():
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-profile",    "-pr", help="Profile to use for access", default=None)
    parser.add_argument("-env",        "-e", help="environment ID", required=True)
    parser.add_argument("-username",   "-u", help="kdb Username", required=True)

    parser.add_argument("-tp_name",    "-tp", help="Tickerplant Cluster Name", required=True)
    parser.add_argument("-debug",      "-d",  help="Debug True/False", default="False")
    parser.add_argument("-port",       "-p",  help="Port to listen two for external connections", default="5030")
    

    args = parser.parse_args()
    
    port = int(args.port)

    session = boto3.Session(profile_name = args.profile)

    service_name = 'finspace'

    client = session.client(service_name=service_name)

    conn_str = get_kx_connection_string(client, 
                                        environmentId=args.env, 
                                        clusterName=args.tp_name, 
                                        userName=args.username, 
                                        boto_session=session)

    print(conn_str)
    
    # PyKX
    # pass args to q process

    kx.q("\\t 10000")

    kx.q['DEBUG'] = 1
    kx.q['conn_str']=kx.toq(conn_str, kx.CharVector)

    # source libraries
    kx.q("\\cd basictick")
    kx.q("\\l feed.q")

    # run function, pass the connection string
    kx.q('.feed.establishTpConnection[ enlist ["-tp"; conn_str] ]')

    total_runtime = 0
    sleep_sec = 10

    while True:
        kx.q.feed.pubToTp();
        
        print(f"Total runtime {datetime.timedelta(seconds=total_runtime)}, waiting {sleep_sec} sec ...")

        time.sleep(sleep_sec)
        total_runtime = total_runtime + sleep_sec
        continue
    
    # now run async
#    async with kx.RawQConnection(port=port, as_server=True, conn_gc_time=20.0) as q:
#        print(q['conn_str'])
              
        # source libraries
#        q("\\cd basictick")
#        q("\\l feed.q")

        # run function, pass the connection string
#        q('.feed.establishTpConnection[ enlist ["-tp"; conn_str] ]')

#        total_runtime = 0
#        sleep_sec = 10
        
#        while True:
#            q.poll_recv()
            
#            print(f"Total runtime {datetime.timedelta(seconds=total_runtime)}, waiting {sleep_sec} sec ...")
#
#            time.sleep(sleep_sec)
#            total_runtime = total_runtime + sleep_sec
#            continue

if __name__ == '__main__':
    asyncio.run(main())

    
