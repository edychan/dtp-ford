clipper @dtp   -o..\OBJ
            if errorlevel 1 goto exit 
clipper @rdtp   -o..\OBJ
            if errorlevel 1 goto exit 
clipper @rinv   -o..\OBJ
            if errorlevel 1 goto exit 
clipper @rcom   -o..\OBJ
            if errorlevel 1 goto exit 
clipper @rrpt   -o..\OBJ
            if errorlevel 1 goto exit 
clipper @rsys   -o..\OBJ
            if errorlevel 1 goto exit 
clipper rafunc   -o..\OBJ
            if errorlevel 1 goto exit 
 clipper rafunc3  -o..\OBJ
             if errorlevel 1 goto exit 
 clipper rafunc4  -o..\OBJ
             if errorlevel 1 goto exit 
:EXIT
