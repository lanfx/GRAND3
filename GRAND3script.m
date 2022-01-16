%GRAND3 - 3D Ground Structure Analysis and Design Code.
%   Tomas Zegard, Glaucio H Paulino - Version 1.0, Nov-2014

%% === MESH GENERATION LOADS/BCS ==========================================
kappa = 1.0; ColTol = 0.999999;
Ff = 2; Cutoff = 0.005; % Plot: Facet factor & member Cutoff

% --- OPTION 1: STRUCTURED-ORTHOGONAL MESH GENERATION ---------------------
[NODE,ELEM,SUPP,LOAD]=StructDomain3(12,4,4,3,1,1,'Cantilever');
Lvl=3; RestrictDomain=[];

% --- OPTION 2: LOAD EXTERNALLY GENERATED MESH ----------------------------
% load MeshCylinder
% Lvl=3; RestrictDomain=[];

% load MeshTube
% Lvl=3; RestrictDomain=@RestrictTube;

% load MeshCone
% Lvl=3; RestrictDomain=[];

% load MeshBallHollow
% Lvl=3; RestrictDomain=@RestrictBallHollow;

% load MeshDiamond
% Lvl=3; RestrictDomain=@RestrictDiamond;

% load MeshCantileverWedges
% Lvl=6; RestrictDomain=[];

% load MeshCantileverHole
% Lvl=6; RestrictDomain=@RestrictCantileverHole;

% load MeshCup
% Lvl=3; RestrictDomain=@RestrictCup;

% load MeshCraneFine
% load MeshCraneCoarse
% Lvl=3; RestrictDomain=@RestrictCrane;

% load MeshLotteLat
% load MeshLotteTor
% Lvl=5; RestrictDomain=@(N,B)rSurf(RNODE,ELEM.S,N,B);

% load MeshCraniofacial
% Lvl=2; RestrictDomain=@RestrictCraniofacial;

%% === GROUND STRUCTURE METHOD ============================================
PlotDomain3(NODE,ELEM,SUPP,LOAD) % Plot the base mesh
[BARS] = GenerateGS3(NODE,ELEM,Lvl,RestrictDomain,ColTol); % Generate the GS
Nn = size(NODE,1); Nb = size(BARS,1); Ne = 0;
if isfield(ELEM,'V'), Ne = Ne + length(ELEM.V); end
if isfield(ELEM,'S'), Ne = Ne + length(ELEM.S); end
[BC] = GetSupports3(SUPP);                 % Get reaction nodes
[BT,L] = GetMatrixBT3(NODE,BARS,BC,Nn,Nb); % Get equilibrium matrix
[F] = GetVectorF3(LOAD,BC,Nn);             % Get nodal force vector

fprintf('Mesh: Elements %d, Nodes %d, Bars %d, Level %d\n',Ne,Nn,Nb,Lvl)
BTBT = [BT -BT]; LL = [L; kappa*L]; sizeBTBT = whos('BTBT'); clear BT L
fprintf('Matrix [BT -BT]: %d x %d in %gMB (%gGB full)\n',...
        length(F),length(LL),sizeBTBT.bytes/2^20,16*(3*Nn)*Nb/2^30)

tic, [S,vol,exitflag,output] = linprog(LL,[],[],BTBT,F,zeros(2*Nb,1));
fprintf('Objective V = %f\nlinprog CPU time = %g s\n',vol,toc);

S = reshape(S,numel(S)/2,2);  % Separate slack variables
A = S(:,1) + kappa*S(:,2);    % Get cross-sectional areas
N = S(:,1) - S(:,2);          % Get member forces

%% === PLOTTING ===========================================================
PlotGroundStructure3(NODE,BARS,A,Cutoff,Ff)