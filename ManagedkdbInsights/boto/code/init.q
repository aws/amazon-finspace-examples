/ command line arguments
params:.Q.opt .z.X

show "Init Script: START"
show system "pwd"

show "Command Line Arguments..."
show params

dbname:first params`dbname
codebase:first params`codebase

app_path: "/opt/kx/app"

dbpath: app_path, "/db/", dbname
codepath: app_path, "/code/", codebase

/If database directory exists, mount it
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; system "l ", dbpath;];
    [show "no database at: ", dbpath;]]

/ if code directory exists, cd to it
$[count key hsym `$codepath;[ show "cd to code directory: ", codepath; system "cd ", codepath;];
    [show "no code at: ", codepath;]];

/ BEGIN load libraries relative to the codepath

\l lib.q

/ END load libraries

/ must be in this path for db reads to work
system "cd /opt/kx"

/ run this to capture counts of partitioned tables
count each value each tables[]

show "Finished in directory..."
show system "pwd"

show "Init Script: DONE"