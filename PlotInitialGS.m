function []=PlotInitialGS(NODE,BARS,SUPP,LOAD)

if size(BARS,1)<10000
    figure, hold on, axis equal, axis off, set(gcf,'Color','w')
    plot3([NODE(BARS(:,1),1) NODE(BARS(:,2),1)]',...
        [NODE(BARS(:,1),2) NODE(BARS(:,2),2)]',...
        [NODE(BARS(:,1),3) NODE(BARS(:,2),3)]','k','LineWidth',0.75)
    if (nargin>2 && ~isempty(SUPP) && ~isempty(LOAD)) % --- Plot BCs if available
        plot3(NODE(SUPP(:,1),1),NODE(SUPP(:,1),2),NODE(SUPP(:,1),3),'b>','MarkerSize',8);
        plot3(NODE(LOAD(:,1),1),NODE(LOAD(:,1),2),NODE(LOAD(:,1),3),'m^','MarkerSize',8);
    end
    view(30,20), rotate3d on, drawnow
else
    fprintf('--- Number of bars >10000, will skip initial GS plot\n')
end