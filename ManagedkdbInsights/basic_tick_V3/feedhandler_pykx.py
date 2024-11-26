import faulthandler
faulthandler.enable()

import argparse
import boto3
import sys
import time

import pykx as kx

from managed_kx import *

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-profile",    "-pr", help="Profile to use for access", default=None)
    parser.add_argument("-env",        "-e", help="environment ID", required=True)
    parser.add_argument("-username",   "-u", help="kdb Username", required=True)

    parser.add_argument("-tick",       "-t",  help="Timer ticks (milliseconds)", default="10000")
    parser.add_argument("-tp_name",    "-tp", help="Tickerplant Cluster Name", required=True)
    parser.add_argument("-debug",      "-d",  help="Debugging output", default=False, action='store_true')

    args = parser.parse_args()

    ticks = int(args.tick)
    debug = args.debug

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
    # set pykx local q console width and height
    kx.q.system.display_size = [50, 100]    
    
    # pass args to q process

    kx.q['FREQ'] = ticks
    kx.q['DEBUG'] = debug
    kx.q['CONN_STR']=kx.toq(conn_str, kx.CharVector)

    # source libraries
    kx.q("\\cd basictick")
    kx.q("\\l feed.q")

    # run function, pass the connection string
    kx.q('.feed.establishTpConnection[ enlist ["-tp"; CONN_STR] ]')

    total_runtime = 0.0
    sleep_sec = ticks/1000.0

    # will loop forever
    while True:

        # with async sending, make sure its all sent
        kx.q("handle:exec first handle from .conn.procs where process=`tp")
        kx.q.feed.pubToTp()
        kx.q('neg[handle][]')

        print(f"Total runtime {datetime.timedelta(seconds=total_runtime)}, waiting {sleep_sec} sec ...")

        time.sleep(sleep_sec)
        total_runtime = total_runtime + sleep_sec
        continue
