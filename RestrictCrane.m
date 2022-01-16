function flag=RestrictCrane(NODE,BARS)
tol = 1e-3;

Lx = 2; Ly1 = 6; Ly2 = 2; Lz = 10;
flag = rBox([-Lx -Ly1-Ly2/2 -Lz],[Lx -Ly2/2-tol 0-tol],NODE,BARS) | ...
       rBox([-Lx  Ly1+Ly2/2 -Lz],[Lx  Ly2/2+tol 0-tol],NODE,BARS);