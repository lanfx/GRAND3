function flag=rDisc(A,B,r,NODE,BARS)
% Collision test for a disc centered at A, with radius r and normal towards B
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
V = NODE(BARS(:,1),:) - repmat(A,size(BARS,1),1);
N = B - A;
% Project onto disc plane
VN = V*N';
DN = D*N';
T = -VN./DN;
% Calculate distance to center
W = V + [T.*D(:,1) T.*D(:,2) T.*D(:,3)];
flag = ( sum(W.^2,2)<=r^2 ) & (T>=0) & (T<=1);