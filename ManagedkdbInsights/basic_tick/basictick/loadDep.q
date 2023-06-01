/Given directory and lib (without .q or .q_ extension, load either one with .q_ preferably)
.load.dependency:{[dir;toLoad]
    
    files:key hsym dir;
    comp:files where files like "*.q_";
    uncomp:files where files like "*.q";

    /Check if there is compiled version to load first
    if[toLoad in `$(".q_" vs/: string comp)[;0];
        system"l ",("/" sv string (dir;toLoad)),".q_";
        show"loaded ",string[toLoad],".q_";
        :()
        ];

    /otherwise get non compiled version
    if[toLoad in `$(".q" vs/: string uncomp)[;0];
        system"l ",("/" sv string (dir;toLoad)),".q";
        show"loaded ",string[toLoad],".q";
        :()
        ];

    /If still here, couldn't find the lib
    show"Could not find library ",string[toLoad];
    }
   
