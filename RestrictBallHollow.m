function flag=RestrictBallHollow(NODE,BARS)
tol = 1e-3;

flag = rSphere([0 0 0],2.9-tol,NODE,BARS);