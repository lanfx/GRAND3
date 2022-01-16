function [NODE,ELEM,SUPP,LOAD]=StructDomain3(Nx,Ny,Nz,Lx,Ly,Lz,ProblemID)
nargchk(nargin,6,7);

% Generate structured-orthogonal domains
[X,Y,Z] = meshgrid(linspace(0,Lx,Nx+1),linspace(0,Ly,Ny+1),linspace(0,Lz,Nz+1));
NODE = [reshape(X,numel(X),1) reshape(Y,numel(Y),1) reshape(Z,numel(Z),1)];
Nn = (Nx+1)*(Ny+1)*(Nz+1); Ne = Nx*Ny*Nz;

ELEM.V = cell(Ne,1);
aux = [1 Ny+2 Ny+3 2 (Nx+1)*(Ny+1)+[1 Ny+2 Ny+3 2]];
for k=1:Nz
    for j=1:Nx
        for i=1:Ny
            n = (k-1)*Ny*Nx + (j-1)*Ny + i;
            ELEM.V{n} = aux + (k-1)*(Ny+1)*(Nx+1) + (j-1)*(Ny+1) + i-1;
        end
    end
end

if (nargin<7 || isempty(ProblemID)), ProblemID = 1; end
switch ProblemID
    case {'Cantilever','cantilever',1}
        if rem(Ny,2)~=0, fprintf('INFO - Ideal Ny is EVEN.\n'), end
        SUPP = [ (1:(Nx+1)*(Ny+1):Nn)'   ones(Nz+1,3);
                (Ny+1:(Nx+1)*(Ny+1):Nn)' ones(Nz+1,3)];
        LOAD = [round((Nz+1)/2)*(Nx+1)*(Ny+1)-round(Ny/2) 0 0 -1];
    case {'Bridge','bridge',2}
        if rem(Ny,2)~=0, fprintf('INFO - Ideal Ny is EVEN.\n'), end
        ind = find(NODE(:,1)==0);
        SUPP = [     ind      ones(size(ind)) nan(length(ind),2);
                 Nx*(Ny+1)+1        NaN           ones(1,2)     ;
                (Nx+1)*(Ny+1)       NaN           ones(1,2)     ];
        LOAD = [Nz*(Nx+1)*(Ny+1)+round((Ny+1)/2) 0 0 -1];
    case {'Tripod','tripod',3}
        if any(rem([Nx Ny],2)), fprintf('INFO - Ideal Nx and Ny are EVEN.\n'), end
        SUPP = [      1       1 1 1;
                    Ny+1      1 1 1;
                 Nx*(Ny+1)+1  1 1 1;
                (Nx+1)*(Ny+1) 1 1 1];
        LOAD = [round(Nx/2)*(Ny+1)+round((Ny+1)/2) 0 0 -1];
    case {'Torsion','torsion',4}
        if ~all(rem([Nx Ny],2)), fprintf('INFO - Ideal Nx and Ny are ODD.\n'), end
        mid = round(Nx/2)*(Ny+1) + round(Ny/2) + [-Ny-1 -Ny 0 1]';
        SUPP = [mid zeros(4,3)];
        M = 1; % Applied moment
        f = [-Ly/Ny Lx/Nx]; dL = norm(f);
        f = (M/4)*(f/dL)*(2/dL); % Nodal loads are applied at 4 locations
        LOAD = [Nz*(Nx+1)*(Ny+1)+mid [-f 0; f(1) -f(2) 0; -f(1) f(2) 0; f 0] ];
        NODE = NODE - repmat([Lx Ly Lz]/2,Nn,1); % Center the model at the origin
    case {'Pyramid','pyramid',5}
        if any(rem([Nx Ny],2)), fprintf('INFO - Ideal Nx and Ny are EVEN.\n'), end
        SUPP = [      1        0   0  0;
                    Ny+1       0  NaN 0;
                 Nx*(Ny+1)+1  NaN NaN 0;
                (Nx+1)*(Ny+1) NaN NaN 0];
        LOAD = [Nn-round(Nx/2)*(Ny+1)-round(Ny/2) 0 0 -1];
    otherwise
        SUPP = []; LOAD = [];
        disp('-INFO- Structured domain generated with no loads/BC')
end