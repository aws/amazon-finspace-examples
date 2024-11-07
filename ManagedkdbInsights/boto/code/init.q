/ so text of log messages are wide enough
\c 50 1000

/ command line arguments
params:.Q.opt .z.X

show "Init Script: START"

show "Command Line Arguments..."
show params

/ load the database
.Q.l `$.aws.akdbp,"/",.aws.akdb

/ back to code directory
\cd /opt/kx/app/code

/ load libraries (relative to /opt/kx/app/code directory)

\l lib.q

show "Init Script: DONE"