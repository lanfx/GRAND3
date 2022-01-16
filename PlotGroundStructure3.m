function []=PlotGroundStructure3(NODE,BARS,A,Cutoff,Ff)
nargchk(nargin,4,5);

RGBcolor = [0.6 0.6 1];   % Default member color
c = 1/100;                % Member size scale factor
if nargin==4, Ff = 2; end % Default facet factor (plot quality)

lim = [min(NODE); max(NODE)]; % Domain limits
dim = max(diff(lim));         % Domain dimension (for cylinder width)
A = A / max(A);               % Normalize to [0,1] areas
indC = find(A>Cutoff);        % Only plot A > cutoff * A_max
figure('Name','GRAND3 v1.0 -- Zegard T, Paulino GH','NumberTitle','off')
hold on, axis equal, axis off, set(gcf,'Color','w'), view(30,20)
axis(lim(:)' + c*dim * [-1 1 -1 1 -1 1]) % Note that max(R) = c*dim*sqrt(1)

% PLOT CYLINDERS & GET SPHERE'S RADII
nodeA = zeros(size(NODE,1),1); % Store nodal areas (sphere radii)
for i=1:length(indC)
    Nf = round(Ff*(6*sqrt(A(indC(i)))+8)); % Number of facets (empirical)
    aux = BARS(indC(i),:);
    DrawRod([NODE(aux(1),1) NODE(aux(2),1)],[NODE(aux(1),2) NODE(aux(2),2)],...
            [NODE(aux(1),3) NODE(aux(2),3)],c*dim*sqrt(A(indC(i))),RGBcolor,Nf)
    nodeA(aux) = max([nodeA(aux) A(indC(i))*[1;1]],[],2); 
end
% PLOT SPHERES
indS = find(nodeA>0);
Nf = round(Ff*(4*sqrt(nodeA(indS))+6)); % Number of facets (empirical)
for i=1:max(Nf)
    [Sx,Sy,Sz] = sphere(i); Sc = repmat(reshape(RGBcolor,[1 1 3]),i+1,i+1);
    aux = find(Nf==i);
    for j=1:length(aux)
        Sr = c*dim*sqrt(nodeA(indS(aux(j))));
        surf(Sr*Sx+NODE(indS(aux(j)),1),Sr*Sy+NODE(indS(aux(j)),2),...
             Sr*Sz+NODE(indS(aux(j)),3),Sc,'EdgeColor','none')
    end
end

rotate3d on, light
fprintf('-PLOT- Cutoff %g, Facet factor %g, Bars %g, Spheres %g\n',...
        Cutoff,Ff,length(indC),length(indS))

function []=DrawRod(X,Y,Z,R,C,Nt)
% Draws rods connecting points X(:,1)-X(:,2), Y(:,1)-Y(:,2) & Z(:,1)-Z(:,2)
% Rods have radius R, color C and Nt facets.
nargchk(nargin,3,6);
Nc = size(X,1);
if nargin<6, Nt = 12; end % Draw 12 facets by default
if (nargin<5 || isempty(C)), C = 0.5*[1 1 1]; end % Default color is gray
if (nargin<4 || isempty(R)), R = ones(size(X,1),1); end % Default radius=1
if ~isequal(size(X),size(Y),size(Z)), error('Vectors must be the same lengths.'), end
if size(X,2)~=2, error('Coordinates must have size [N x 2]'), end
if isscalar(R), R = R*ones(Nc,1); end

Cc = zeros(Nt,2,3);
if size(C,1)==1, for i=1:3, Cc(:,:,i) = C(i); end, end % 3D RGB matrix

t = linspace(0,2*pi,Nt)';
qt = cos(t); rt = sin(t); % Parametrized circle for cylinder's cap
p = [diff(X,[],2) diff(Y,[],2) diff(Z,[],2)]; % Directional vector
L = sqrt(sum(p.^2,2));
p = [p(:,1)./L p(:,2)./L p(:,3)./L]; % Normalized cylinder axis director
for i=1:Nc
    if abs(p(i,3))<0.9, q = cross([0 0 1],p(i,:)); % If not pointing to +Z
    else, q = cross([0 1 0],p(i,:));
    end
    q = q / norm(q);     % Normalize second basis vector
    r = cross(q,p(i,:)); % Get the third basis vector
    r = r / norm(r);     % Normalize third basis vector
    
    S = R(i)*repmat(qt*q(1)+rt*r(1),1,2) + repmat(X(i,:),Nt,1);
    T = R(i)*repmat(qt*q(2)+rt*r(2),1,2) + repmat(Y(i,:),Nt,1);
    U = R(i)*repmat(qt*q(3)+rt*r(3),1,2) + repmat(Z(i,:),Nt,1);
    % If each member has different color specified
    if size(C,1)~=1, for j=1:3, Cc(:,:,j) = C(i,j); end, end
    surf(S,T,U,Cc,'EdgeColor','none')
end