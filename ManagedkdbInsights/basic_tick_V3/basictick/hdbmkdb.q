show "HDB: START"

show "Command Line Arguments..."

params:.Q.opt .z.X
show params

/ read in params
/tphostfile:first params`tphostfile

/ database path
dbpath: "/opt/kx/app/db/", .aws.akdb

/ cd to code directory
\cd /opt/kx/app/code

/ BEGIN load libraries relative to the code path

\l query.q

/ END load libraries

/ If database exists, mount it, AFTER having loaded the empty schema
$[count key hsym `$dbpath;[ show "loading database: ", dbpath; .Q.l `$dbpath;];
    [show "no database at: ", dbpath;]]

/ must finished at this path for db reads to work
\cd /opt/kx/app

/ count partitioned tables
count each value each tables[]

show "HDB: DONE"
