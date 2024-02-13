import os
import pykx as kx_local


def get_pykx_remote_connection(connectionString: str):
    import pykx as kx

    conn_parts = connectionString.split(":")

    host=conn_parts[2].strip("/")
    port = int(conn_parts[3])
    username=conn_parts[4]
    password=conn_parts[5]
    
    return kx.QConnection(host=host, port=port, username=username, password=password, tls=True)


def _set_directories(filesPath: str, remotePath: str):
    file_directories = []
    file_remote_directories = []

    for root, dirs, files in os.walk(filesPath):
        path = root.split(os.sep)
        for file in files:
            if "checkpoint" not in file:
                file_directories.append(os.path.join(root, file))
                _, remote_subdirectory = root.split(filesPath)

                if remote_subdirectory:
                    remote_subdirectory += "/"

                file_remote_directories.append(remotePath + remote_subdirectory + file)

    kx_local.q["fileDirectories"] = file_directories
    kx_local.q["fileRemoteDirectories"] = file_remote_directories
    
def copy_local_to_cluster(kx_remote, filesPath: str, remotePath: str):
    _set_directories(filesPath, remotePath)
    print(kx_local.q("fileDirectories"))
    # Get a list of bytes representations of the files to update
    kx_local.q('files: {read1 fileDirectories[x]} each til count fileDirectories')

    # Pass on variables to remote
    kx_remote['files'] = kx_local.q('files')
    kx_remote['fileRemoteDirectories'] = kx_local.q('fileRemoteDirectories')
    
    kx_remote('{fileRemoteDirectories[x] 1: files[x]} each til count files')

