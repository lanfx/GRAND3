function flag=rTriangle(A,B,C,NODE,BARS)

Nb = size(BARS,1);

% Find intersection point
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
PA= repmat(A,Nb,1) - NODE(BARS(:,1),:);
N = cross( B - A , C - A );
T = (PA*N')./(D*N');
ind = find( (T>=0).*(T<=1) );
flag = zeros(Nb,1);

% If R between P and Q, check if inside triangle
if ~isempty(ind)
    D = D(ind,:); PA= PA(ind,:);
    PB= repmat(B,length(ind),1) - NODE(BARS(ind,1),:);
    PC= repmat(C,length(ind),1) - NODE(BARS(ind,1),:);
    E = [D(:,2).*PC(:,3) - D(:,3).*PC(:,2)...
         D(:,3).*PC(:,1) - D(:,1).*PC(:,3)...
         D(:,1).*PC(:,2) - D(:,2).*PC(:,1)];
    V1= sum(PB.*E,2);
    V2=-sum(PA.*E,2);
    E = [D(:,2).*PB(:,3) - D(:,3).*PB(:,2)...
         D(:,3).*PB(:,1) - D(:,1).*PB(:,3)...
         D(:,1).*PB(:,2) - D(:,2).*PB(:,1)];
    V3= sum(PA.*E,2);
    aux = [sign(V1) sign(V2) sign(V3)];
    % Check for signs and consider case with zero volumes
    flag(ind) = max(aux,[],2) - min(aux,[],2)<2;
end