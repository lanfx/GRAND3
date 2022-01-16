function flag=rRod(A,B,r,NODE,BARS)
% Collision test for a rod A-B, with radius r
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
V = NODE(BARS(:,1),:) - repmat(A,size(BARS,1),1);
N = B - A;

VD = sum(V.*D,2);
VN = V*N';
DN = D*N';
NN = N*N';
VV = sum(V.^2,2);
DD = sum(D.^2,2);

% A endcap
T = -VN./DN;
W = V + [T.*D(:,1) T.*D(:,2) T.*D(:,3)];
flag1 = ( sum(W.^2,2)<=r^2 ) & (T>=0) & (T<=1);

% B endcap
T = (NN-VN)./DN;
W = V + [T.*D(:,1)-N(1) T.*D(:,2)-N(2) T.*D(:,3)-N(3)];
flag2 = ( sum(W.^2,2)<=r^2 ) & (T>=0) & (T<=1);

% Cylinder surface check
a = NN*DD - DN.^2;
b = NN*VD - DN.*VN; % Actually this is b/2
c = NN*(VV-r^2) - VN.^2;
discr = b.^2 - a.*c;
flag3 = false(size(discr,1),2);
ind = find(discr>=0);
if ~isempty(ind)
    T = [ (-b(ind)+sqrt(discr(ind)))./a(ind) (-b(ind)-sqrt(discr(ind)))./a(ind) ];
    W = V(ind,:) + [D(ind,1).*T(:,1) D(ind,2).*T(:,1) D(ind,3).*T(:,1)];
    WN= W*N';
    flag3(ind,1) = (WN>=0).*(WN<=NN).*(T(:,1)>=0).*(T(:,1)<=1);
    W = V(ind,:) + [D(ind,1).*T(:,2) D(ind,2).*T(:,2) D(ind,3).*T(:,2)];
    WN= W*N';
    flag3(ind,2) = (WN>=0) & (WN<=NN) & (T(:,2)>=0) & (T(:,2)<=1);
end

% Check for point A if segment is completely contained within the rod
T = VN./NN;
W = V - T*N;
flag4 = ( sum(W.^2,2)<=r^2 ) & (T>=0) & (T<=1);

% If any collision, return true
flag = any([flag1 flag2 flag3 flag4],2);