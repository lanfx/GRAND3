function flag=RestrictDiamond(NODE,BARS)
tol = 1e-3;

R = 0.80;
flag = rDisc([0 0 0],[0 0 1],R-tol,NODE,BARS);