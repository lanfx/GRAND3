function flag=RestrictCup(NODE,BARS)
tol = 1e-3;

R = 0.7; H = 0.6;
flag = rRod([0 0 -tol],[0 0 H-tol],R-tol,NODE,BARS);