function flag=rQuad(A,B1,C,B2,NODE,BARS)

Nb = size(BARS,1);

% Find intersection point
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
PA= repmat(A,Nb,1) - NODE(BARS(:,1),:);
N = cross( B1 - A , B2 - A );
T = (PA*N')./(D*N');
ind = find( (T>=0).*(T<=1) );
flag = zeros(Nb,1);

% Check along diagonal AC and identify the triangle to check
D = D(ind,:); PA= PA(ind,:);
PB1= repmat(B1,length(ind),1) - NODE(BARS(ind,1),:);
PC = repmat( C,length(ind),1) - NODE(BARS(ind,1),:);
PB2= repmat(B2,length(ind),1) - NODE(BARS(ind,1),:);
E = [D(:,2).*PC(:,3)-D(:,3).*PC(:,2) D(:,3).*PC(:,1)-D(:,1).*PC(:,3) D(:,1).*PC(:,2)-D(:,2).*PC(:,1)];
VA= sum(PB1.*E,2);
VB= sum(PB2.*E,2);
V2=-sum( PA.*E,2);
aux = [sign(VA) sign(VB) sign(V2)];
tri1 = find(abs(aux(:,1)-aux(:,3))<2);
tri2 = find(abs(aux(:,2)-aux(:,3))<2);
if ~isempty(tri1) % Indices to check for AB1C
    E(tri1,:)=[D(tri1,2).*PB1(tri1,3) - D(tri1,3).*PB1(tri1,2)...
               D(tri1,3).*PB1(tri1,1) - D(tri1,1).*PB1(tri1,3)...
               D(tri1,1).*PB1(tri1,2) - D(tri1,2).*PB1(tri1,1)]; % E1 = D x PB1
end
V31= sum(PA(tri1,:).*E(tri1,:),2);
if ~isempty(tri2) % Indices to check for BCB2
    E(tri2,:)=[D(tri2,2).*PB2(tri2,3) - D(tri2,3).*PB2(tri2,2)...
               D(tri2,3).*PB2(tri2,1) - D(tri2,1).*PB2(tri2,3)...
               D(tri2,1).*PB2(tri2,2) - D(tri2,2).*PB2(tri2,1)]; % E2 = D x PB2
end
V32= sum(PA(tri2,:).*E(tri2,:),2);

flag1 = false(length(ind),1); flag2 = false(length(ind),1);
flag1(tri1) = max(abs(aux(tri1,3)-sign(V31)),[],2)<2;
flag2(tri2) = max(abs(aux(tri2,3)-sign(V32)),[],2)<2;
flag(ind) = any([flag1 flag2],2);