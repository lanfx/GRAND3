function [BARS]=GenerateGS3(NODE,ELEM,Lvl,RestrictDomain,ColTol)
nargchk(nargin,3,5);
if nargin<5, ColTol=0.9999; end % Default collinear tolerance
if (nargin<4 || isempty(RestrictDomain)), RestrictDomain=@(~,~)[]; end

% Get element connectivity matrix
if isfield(ELEM,'V'), Nn(1) = max(cellfun(@max,ELEM.V)); end
if isfield(ELEM,'S'), Nn(2) = max(cellfun(@max,ELEM.S)); end
Nn = max(Nn); A1 = sparse(Nn,Nn);
if isfield(ELEM,'V'), for i=1:length(ELEM.V), A1(ELEM.V{i},ELEM.V{i}) = true; end, end
if isfield(ELEM,'S'), for i=1:length(ELEM.S), A1(ELEM.S{i},ELEM.S{i}) = true; end, end
A1 = A1 - speye(Nn,Nn); An = A1;

% Level 1 connectivity
[J,I] = find(An); % Reversed because find returns values column-major
BARS = [I J];
D = [NODE(I,1)-NODE(J,1) NODE(I,2)-NODE(J,2) NODE(I,3)-NODE(J,3)];
L = sqrt(D(:,1).^2+D(:,2).^2+D(:,3).^2);  % Length of bars
D = [D(:,1)./L D(:,2)./L D(:,3)./L];      % Normalized dir

% Levels 2 and above
for i=2:Lvl
    Aold = An; An = logical(An*A1); Gn = An - Aold; % Get NEW bars @ level 'n'
    [J,I] = find(Gn-diag(diag(Gn)));
    if isempty(J), Lvl = i - 1; fprintf('-INFO- No new bars at Level %g\n',Lvl); break, end
    
    RemoveFlag = RestrictDomain(NODE,[I J]); % Find and remove bars within restriction zone
    I(RemoveFlag) = []; J(RemoveFlag) = [];
    
    newD = [NODE(I,1)-NODE(J,1) NODE(I,2)-NODE(J,2) NODE(I,3)-NODE(J,3)];
    L = sqrt(newD(:,1).^2+newD(:,2).^2+newD(:,3).^2);
    newD = [newD(:,1)./L newD(:,2)./L newD(:,3)./L];
    
    % Collinearity Check
    p = 1; m = 1; RemoveFlag = zeros(size(I)); Nb = size(BARS,1);
    for j=1:Nn
        % Find I(p:q) - NEW bars starting @ node 'j'
        for p=p:length(I), if I(p)>=j, break, end, end
        for q=p:length(I), if I(q)>j, break, end, end
        if I(q)>j, q = q - 1; end
        
        if I(p)==j
            % Find BARS(m:n) - OLD bars starting @ node 'j'
            for m=1:Nb, if BARS(m,1)>=j, break, end, end
            for n=m:Nb, if BARS(n,1)>j, break, end, end
            if BARS(n,1)>j, n = n - 1; end
            
            if BARS(n,1)==j
                % Dot products of old vs. new bars. If ~collinear: mark
                C = max(D(m:n,:)*newD(p:q,:)',[],1);
                RemoveFlag(p-1+find(C>ColTol)) = true;
            end
        end
    end
    
    % Remove collinear bars and make symmetric again. Bars that have one
    % angle marked as collinear but the other not, will be spared
    ind = find(RemoveFlag==false);
    H = sparse(I(ind),J(ind),true,Nn,Nn,length(ind));
    [J,I] = find(H+H');
    fprintf('Lvl %2g - Collinear bars removed: %g\n',i,(length(RemoveFlag)-length(I))/2);
    
    BARS = sortrows([BARS; I J]);
    D = [NODE(BARS(:,1),1) - NODE(BARS(:,2),1)...
         NODE(BARS(:,1),2) - NODE(BARS(:,2),2)...
         NODE(BARS(:,1),3) - NODE(BARS(:,2),3)];
    L = sqrt(D(:,1).^2+D(:,2).^2+D(:,3).^2);  % Length of bars
    D = [D(:,1)./L D(:,2)./L D(:,3)./L];      % Normalized dir
end

% Only return bars {i,j} with i<j (no duplicate bars)
A = sparse(BARS(:,1),BARS(:,2),true,Nn,Nn);
[J,I] = find(tril(A)); BARS = [I J];