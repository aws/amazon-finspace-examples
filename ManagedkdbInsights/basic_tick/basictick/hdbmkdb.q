show "HDB: START"
show system "pwd"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
dbname:first params`dbname
codebase:first params`codebase
tphostfile:first params`tphostfile

/ assign paths
app_path: "/opt/kx/app"

dbpath: app_path, "/db/", dbname
codepath: app_path, "/code/", codebase

/ if code directory exists, cd to it
$[count key hsym `$codepath;[ show "cd to code directory: ", codepath; system "cd ", codepath;];
    [show "no code at: ", codepath;]];

/ BEGIN load libraries relative to the codepath

\l query.q
\l example.schema.q

/ END load libraries

/ If database exists, mount it, AFTER having loaded the empty schema
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; system "l ", dbpath;];
    [show "no database at: ", dbpath;]]

/ must be in this path for db reads to work
system "cd /opt/kx"

/ count partitioned tables
count each value each tables[]

show "HDB: DONE"
show system "pwd"
