function [F]=GetVectorF3(LOAD,BC,Nn)
% Return nodal force vector
Nl = sum(sum(~isnan(LOAD(:,2:4))));
F = sparse([],[],[],3*Nn,1,Nl);
for i=1:size(LOAD,1)
    n = LOAD(i,1);
    if ~isnan(LOAD(i,2)), F(3*n-2) = LOAD(i,2); end
    if ~isnan(LOAD(i,3)), F(3*n-1) = LOAD(i,3); end
    if ~isnan(LOAD(i,4)), F(3*n) = LOAD(i,4);   end
end
F(BC) = [];