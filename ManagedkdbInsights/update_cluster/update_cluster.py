import argparse
import pprint
import awswrangler as wr

from urllib.parse import urlparse
from pathlib import Path

from managed_kx import *

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
    parser.add_argument("-environmentId", "-e", help="Finspace with managed kdb Insights Environment ID", required=True)
    parser.add_argument("-profile",       "-p", help="profile to use for API access", default ="default")
    parser.add_argument("-s3",            "-s3", help="S3 Staging location", required=True)
    parser.add_argument("-cluster",       "-cl", help="Cluster to update", required=True)
    parser.add_argument("-code",          "-co", help="Code directory to send to cluster", required=True)
    parser.add_argument("-wait",          "-w", help="Wait for cluster status", default=True)

    args = parser.parse_args()

    ENV_ID = args.environmentId
    S3_PATH = args.s3
    CLUSTER_NAME = args.cluster
    code_path = Path(args.code)
    wait = args.wait

    deploy_strategy = 'NO_RESTART'

    # use the user's AWS credentials from environment
    session = boto3.Session(profile_name = args.profile)
    client = session.client(service_name='finspace')

    # check arguments
    #   - code location exists
    #   - S3 bucket exists
    #   - cluster exists
    # -------------------------------------------------------------

    # does code location exist?
    if code_path.is_dir() is False:
        sys.exit(f"directory {code_path.absolute()} not found")

    # cluster exists?
    if has_cluster(client, environmentId=ENV_ID, clusterName=CLUSTER_NAME) is False:
        sys.exit(f"cluster {CLUSTER_NAME} not found")

    # zip the code, ignore known temp files
    print(f"Zipping: {code_path.absolute()}")

    os.system(f"cd {code_path.name}; zip -r -X ../{code_path.name}.zip . -x '*.ipynb_checkpoints*';")

    # copy to S3
    s3_code_path = f"{S3_PATH}/{code_path.name}.zip"

    print(f"Copying to: {s3_code_path}")

    wr.s3.upload(f"{code_path.name}.zip", s3_code_path)

    # update cluster
    # get current state and use its arguments in update
    # -------------------------------------------------------------

    print(f"Updating Cluster: {CLUSTER_NAME}")

    # ensure the cluster is running
    current_state = get_kx_cluster(client, environmentId=ENV_ID, clusterName=CLUSTER_NAME)

    status = current_state.get('status', 'UNKNOWN')

    if status != 'RUNNING':
        sys.exit(f"Cluster: {CLUSTER_NAME} is not in RUNNING, state is {status}")

    print(f"State of {CLUSTER_NAME}:")
    pp.pprint(current_state)
    print(80*'-')

    # split s3 URL into bucket and key
    s3 = S3Url(s3_code_path)

    kwargs = {
        'environmentId': ENV_ID,
        'clusterName': CLUSTER_NAME,
        'code': {
            's3Bucket': s3.bucket,
            's3Key': s3.key
        },
        'deploymentConfiguration': {
            'deploymentStrategy': deploy_strategy  # 'NO_RESTART'|'ROLLING'|'FORCE'
        }
    }

    # copy arguments from current state to keep them unchanged
    arg_list = [] #['commandLineArguments', 'initializationScript']

    if deploy_strategy != 'NO_RESTART':
        arg_list.append('initializationScript')
        arg_list.append('commandLineArguments')

    # add arguments not changing
    for a in arg_list:
        if a in current_state:
            kwargs[a] = current_state[a]

    resp = client.update_kx_cluster_code_configuration( **kwargs)

    print("Requested State")
    pp.pprint(resp)
    print(80*'-')

    # wait for the update
    if wait:
        wait_for_cluster_status(client, environmentId=ENV_ID, clusterName=CLUSTER_NAME, sleep_sec=10, show_wait=True)

        # new (updated) state
        resp = get_kx_cluster(client, environmentId=ENV_ID, clusterName=CLUSTER_NAME)

        print(80*'-')
        print(f"New Current State")
        pp.pprint(resp)
