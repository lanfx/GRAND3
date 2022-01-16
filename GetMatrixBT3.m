function [BT,L]=GetMatrixBT3(NODE,BARS,BC,Nn,Nb)
% Generate equilibrium matrix BT and get member lengths L
D = [NODE(BARS(:,2),1)-NODE(BARS(:,1),1)...
     NODE(BARS(:,2),2)-NODE(BARS(:,1),2)...
     NODE(BARS(:,2),3)-NODE(BARS(:,1),3)];
L = sqrt(D(:,1).^2+D(:,2).^2+D(:,3).^2);
D = [D(:,1)./L D(:,2)./L D(:,3)./L];
BT = sparse([3*BARS(:,1)-2 3*BARS(:,1)-1 3*BARS(:,1)...
             3*BARS(:,2)-2 3*BARS(:,2)-1 3*BARS(:,2)],...
             repmat((1:Nb)',1,6),[-D D],3*Nn,Nb);
BT(BC,:) = [];