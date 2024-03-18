"TorQ FinSpace Starting", string .z.z

/setenv[`KDBDATABASETRADE; "finspace-database"];
setenv[`KDBDATABASETRADE; .aws.akdb];

/sharedVolume:"SHARED_torq"
sharedVolume: string first key `:/opt/kx/app/shared

opts:.Q.opt .z.x;
codeDir:$[`codeDir in key opts; first opts`codeDir; .aws.akcp ];
hdbDir:$[`hdbDir in key opts; first opts`hdbDir; .aws.akdbp, "/", getenv `KDBDATABASETRADE];

torqDir:codeDir,"/TorQ";
appDir:codeDir,"/TorQ-Amazon-FinSpace-Starter-Pack";

setenv[`TORQHOME; torqDir];
setenv[`TORQAPPHOME; appDir];

setenv[`KDBSCRATCH; "/opt/kx/app/shared/",sharedVolume,"/common"];

setenv[`KDBFINSPACE; "true"];

setenv[`KDBCODE; torqDir,"/code"];
setenv[`KDBCONFIG; torqDir,"/config"];
setenv[`KDBLOG; getenv[`KDBSCRATCH],"/logs"];
setenv[`KDBHTML; torqDir,"/html"]
setenv[`KDBLIB; torqDir,"/lib"];
setenv[`KDBHDB; hdbDir];

setenv[`KDBAPPCONFIG; appDir,"/appconfig"];
setenv[`KDBAPPCODE; appDir,"/code"];

setenv[`KDBBASEPORT; "17000"];
setenv[`KDBSTACKID; "-stackid ",getenv`KDBBASEPORT];
setenv[`TORQPROCESSES; getenv[`KDBAPPCONFIG],"/process.csv"];

/ TODO - remove this once we can pass in the env file as a cmd line parameter
system"l ",torqDir,"/torq.q";

"TorQ FinSpace Started", string .z.z
