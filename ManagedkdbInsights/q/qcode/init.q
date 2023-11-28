/ so text of log messages are wide enough
\c 30 200

/ command line arguments
params:.Q.opt .z.X

show "Init Script: START"

show "Command Line Arguments..."
show params

/ get the name of the database given to use
dbname:first params`dbname

/ cd to database directory
\cd /opt/kx/app/db

/ load the db
.Q.l `$dbname

/ run this to capture counts of partitioned tables (updated global variables)
count each value each tables[]

/ back to code directory
\cd /opt/kx/app/code

/ load libraries (relative to /opt/kx/app/code directory)

\l lib.q

show "Init Script: DONE"