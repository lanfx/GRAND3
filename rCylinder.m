function flag=rCylinder(A,B,r,NODE,BARS)
% Collision test for an infinite cylinder A-B, with radius r
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
V = NODE(BARS(:,1),:) - repmat(A,size(BARS,1),1);
N = B - A;

VD = sum(V.*D,2);
VN = V*N';
DN = D*N';
NN = N*N';
VV = sum(V.^2,2);
DD = sum(D.^2,2);

% Cylinder surface check
a = NN*DD - DN.^2;
b = NN*VD - DN.*VN; % Actually this is b/2
c = NN*(VV-r^2) - VN.^2;
discr = b.^2 - a.*c;
ind = find(discr>=0);
flag1 = false(size(discr,1),2);
if ~isempty(ind)
    T = [ (-b(ind)+sqrt(discr(ind)))./a(ind) (-b(ind)-sqrt(discr(ind)))./a(ind) ];
    flag1(ind,:) = (T>=0) & (T<=1);
end

% Check for point A if segment is completely contained within the cylinder
T = VN./NN;
W = V - T*N;
flag2= ( sum(W.^2,2)<=r^2 );

% If any collision, return true
flag = any([flag1 flag2],2);