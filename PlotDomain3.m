function []=PlotDomain3(NODE,ELEM,SUPP,LOAD,Color)
nargchk(nargin,4,5);

Alpha = 0.15; % Alpha transparency value
if nargin<5, Color = 0.3*[1 1 1]; end % Default color is gray

%% Create index lists for every element type
ELEMlist = cell(7,1);
if isfield(ELEM,'V')
    VNp = cellfun(@numel,ELEM.V);
    VELEMtype = [VNp==8 VNp==6 VNp==5 VNp==4]; % Hexahedra, Prism & Tetrahedra
    ELEMlist{1} = find(VELEMtype(:,1)); % --- Hexahedra
    ELEMlist{2} = find(VELEMtype(:,2)); % --- Prism
    ELEMlist{3} = find(VELEMtype(:,3)); % --- Pyramid
    ELEMlist{4} = find(VELEMtype(:,4)); % --- Tetrahedra
end
if isfield(ELEM,'S')
    SNp = cellfun(@numel,ELEM.S);
    SELEMtype = [SNp==4 SNp==3 SNp==2]; % Quadrangles, Triangles & Lines
    ELEMlist{5} = find(SELEMtype(:,1)); % --- Quadrangles
    ELEMlist{6} = find(SELEMtype(:,2)); % --- Triangles
    ELEMlist{7} = find(SELEMtype(:,3)); % --- Lines
end
Ne = cellfun(@numel,ELEMlist);
FACE4 = nan(6*Ne(1)+3*Ne(2)+Ne(3)+Ne(5),4); N4 = 0; % Faces: hexa-6, prism-3, pyra-1, quad-1
FACE3 = nan(2*Ne(2)+4*Ne(3)+4*Ne(4)+Ne(6),3); N3 = 0; % Faces: prism-2, pyra-4, tetra-4, tria-1

for i=1:Ne(1) % --- Hexahedra
    FACE4(N4+(1:6),:) = ELEM.V{ELEMlist{1}(i)}([1 2 3 4; 5 6 7 8; 1 2 6 5; 4 3 7 8; 2 3 7 6; 1 4 8 5]);
    N4 = N4 + 6;
end
for i=1:Ne(2) % --- Prisms
    FACE3(N3+(1:2),:) = ELEM.V{ELEMlist{2}(i)}([1 2 3; 4 5 6]); N3 = N3 + 2;
    FACE4(N4+(1:3),:) = ELEM.V{ELEMlist{2}(i)}([1 2 5 4; 2 3 6 5; 3 1 4 6]); N4 = N4 + 3;
end
for i=1:Ne(3) % --- Pyramids
    FACE3(N3+(1:4),:) = ELEM.V{ELEMlist{3}(i)}([1 2 5; 2 3 5; 3 4 5; 4 1 5]); N3 = N3 + 4;
    FACE4(N4+1,:) = ELEM.V{ELEMlist{3}(i)}([1 2 3 4]); N4 = N4 + 1;
end
for i=1:Ne(4) % --- Tetrahedra
    FACE3(N3+(1:4),:) = ELEM.V{ELEMlist{4}(i)}([1 2 3; 1 4 2; 2 4 3; 3 4 1]); N3 = N3 + 4;
end
if Ne(5)>0, FACE4(N4+(1:Ne(5)),:) = vertcat(ELEM.S{ELEMlist{5}}); N4 = N4 + Ne(5); end
if Ne(6)>0, FACE3(N3+(1:Ne(6)),:) = vertcat(ELEM.S{ELEMlist{6}}); N3 = N3 + Ne(6); end

% --- Reorder face numbering for sorting and plot
figure, hold on, axis equal, axis off, set(gcf,'Color','w')
if ~isempty(FACE3)
    [~,ind] = min(FACE3,[],2);
    for i=1:size(FACE3,1)
        if ind(i)~=1, FACE3(i,:) = FACE3(i,[ind(i):3 1:ind(i)-1]); end
    end
    ind = find(FACE3(:,2)>FACE3(:,3)); FACE3(ind,2:3) = FACE3(ind,[3 2]);
    [FACE3,~,ind] = unique(FACE3,'rows');
    IsBoundary = sparse(ind,ones(size(ind)),ones(size(ind))); % 2 = INNER
    BOUND3 = find(IsBoundary==1);
    patch('Faces',FACE3(BOUND3,:),'Vertices',NODE,'FaceColor',Color,'FaceAlpha',Alpha);
end
if ~isempty(FACE4)
    [~,ind] = min(FACE4,[],2);
    for i=1:size(FACE4,1)
        if ind(i)~=1, FACE4(i,:) = FACE4(i,[ind(i):4 1:ind(i)-1]); end
    end
    ind = find(FACE4(:,2)>FACE4(:,end)); FACE4(ind,2:4) = fliplr(FACE4(ind,2:4));
    [FACE4,~,ind] = unique(FACE4,'rows');
    IsBoundary = sparse(ind,ones(size(ind)),ones(size(ind))); % 2 = INNER
    BOUND4 = find(IsBoundary==1);
    patch('Faces',FACE4(BOUND4,:),'Vertices',NODE,'FaceColor',Color,'FaceAlpha',Alpha);
end
if ~isempty(ELEMlist{7}) % --- Plot line elements
    LINE=cat(1,ELEM.S{ELEMlist{7}});
    plot3([NODE(LINE(:,1),1) NODE(LINE(:,2),1)]',[NODE(LINE(:,1),2) NODE(LINE(:,2),2)]',...
          [NODE(LINE(:,1),3) NODE(LINE(:,2),3)]','Color',[4 21 9]/30,'LineWidth',1.5)
end
if (nargin>2 && ~isempty(SUPP) && ~isempty(LOAD)) % --- Plot boundary conditions if available
    plot3(NODE(SUPP(:,1),1),NODE(SUPP(:,1),2),NODE(SUPP(:,1),3),'b>','MarkerSize',8);
    plot3(NODE(LOAD(:,1),1),NODE(LOAD(:,1),2),NODE(LOAD(:,1),3),'m^','MarkerSize',8);
end
view(30,20), rotate3d on, drawnow