function flag=rSphere(C,r,NODE,BARS)

D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
V = repmat(C,size(BARS,1),1) - NODE(BARS(:,1),:);

VD = sum(V.*D,2);
VV = sum(V.^2,2);
DD = sum(D.^2,2);

% Point X in L(t) is inside sphere
VDn = VD./DD;
VmW = V - [VDn.*D(:,1) VDn.*D(:,2) VDn.*D(:,3)];
flag1 = ( sum(VmW.^2,2)<=r^2 ) & (VDn>=0) & (VDn<=1);

% Point A is inside sphere
flag2 = ( VV<=r^2 );

% Point B is inside sphere
flag3 = ( VV-2*VD+DD<=r^2 );

% If any collision, return true
flag = any([flag1 flag2 flag3],2);