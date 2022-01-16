function flag=RestrictTube(NODE,BARS)
tol = 1e-3;

R = 7/3; H = 11;
flag = rCylinder([0 0 0],[0 0 H],R-tol,NODE,BARS);