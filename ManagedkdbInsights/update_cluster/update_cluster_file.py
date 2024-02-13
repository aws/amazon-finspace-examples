import argparse
import pprint
import pykx as kx

from urllib.parse import urlparse
from pathlib import Path

from managed_kx import *
from update_cluster_code import *

pp = pprint.PrettyPrinter(indent=2)

def divide_chunks(l, n):

    # looping till length l
    for i in range(0, len(l), n):
        yield l[i:i + n]

class S3Url(object):
    def __init__(self, url):
        self._parsed = urlparse(url, allow_fragments=False)

    @property
    def bucket(self):
        return self._parsed.netloc

    @property
    def key(self):
        if self._parsed.query:
            return self._parsed.path.lstrip('/') + '?' + self._parsed.query
        else:
            return self._parsed.path.lstrip('/')

    @property
    def url(self):
        return self._parsed.geturl()

#
# This program assumes that you have credentials in $HOME/.aws/credentials
# those credentials must also be linked to a FinSpace user with ability to create datasets
#

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # arguments
    parser.add_argument("-environmentId", "-e",  help="Finspace with managed kdb Insights Environment ID", required=True)
    parser.add_argument("-profile",       "-p",  help="profile to use for API access", default ="default")
    parser.add_argument("-cluster",       "-cl", help="Cluster to update", required=True)
    parser.add_argument("-user",          "-u",  help="FinSpace user name", required=True)
    parser.add_argument("-code",          "-co", help="Code directory", required=True)
    parser.add_argument("-file",          "-f", help="File to send to cluster, path must be relative to code directory", required=True)

    args = parser.parse_args()

    ENV_ID = args.environmentId
    CLUSTER_NAME = args.cluster
    KDB_USERNAME = args.user
    local_code_home = Path(args.code)
    source_file = args.file

    cluster_code_home = "/opt/kx/app/code"

    # use the user's AWS credentials from environment
    session = boto3.Session(profile_name = args.profile)
    client = session.client(service_name='finspace')

    # check arguments
    #   - code location exists
    #   - file in code location exists
    #   - cluster exists
    # -------------------------------------------------------------

    # does code location exist?
    if local_code_home.is_dir() is False:
        sys.exit(f"directory {local_code_home.absolute()} not found")

    # does the source file exist?
    if local_code_home.is_dir() is False:
        sys.exit(f"file {source_file} not found in {local_code_home.absolute()}")

    # cluster exists?
    if has_cluster(client, environmentId=ENV_ID, clusterName=CLUSTER_NAME) is False:
        sys.exit(f"cluster {CLUSTER_NAME} not found")

    # connect to cluster
    local_file = f"{local_code_home.absolute()}/{source_file}"
    remote_file = f"{cluster_code_home}/{source_file}"

    conn = get_pykx_connection(client,
                              environmentId=ENV_ID, clusterName=CLUSTER_NAME,
                              userName=KDB_USERNAME, boto_session=session)

    # read file contents into local q
    update_cluster_code(kx_remote=conn,
                        filesPath=local_file,
                        remotePath=remote_file)

    # push file contents to cluster

    # save file on cluster

