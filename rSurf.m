function flag=rSurf(RNODE,RFACE,NODE,BARS)

flag = false(size(BARS,1));
for i=1:length(RFACE)
    switch length(RFACE{i})
        case {1,2}
            error('Surface facets must have 3+ nodes.')
        case 3
            flag = any([flag rTriangle(RNODE(RFACE{i}(1),:),RNODE(RFACE{i}(2),:),...
                        RNODE(RFACE{i}(3),:),NODE,BARS)],2);
        case 4
            flag = any([flag rQuad(RNODE(RFACE{i}(1),:),RNODE(RFACE{i}(2),:),...
                        RNODE(RFACE{i}(3),:),RNODE(RFACE{i}(4),:),NODE,BARS)],2);
        otherwise
            for j=3:length(RFACE{i})
                flag = any([flag rTriangle(RNODE(RFACE{i}(1),:),RNODE(RFACE{i}(j-2),:),...
                            RNODE(RFACE{i}(j),:),NODE,BARS)],2);
            end
    end
end    