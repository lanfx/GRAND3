function flag=rBox(Amin,Amax,NODE,BARS)
% Amin and Amax are the box's limit coords: minimum and maximum
Nb= size(BARS,1);
Tmin = zeros(Nb,1); Tmax = ones(Nb,1);
D = NODE(BARS(:,2),:) - NODE(BARS(:,1),:);
for i=1:3 % Check all 3 coordinates [X,Y,Z]
    T1 = ( Amin(i) - NODE(BARS(:,1),i) ) ./ D(:,i);
    T2 = ( Amax(i) - NODE(BARS(:,1),i) ) ./ D(:,i);
    ind = find(T1>T2); % We require T1<T2, swap if not
    [T1(ind),T2(ind)] = deal(T2(ind),T1(ind)); % Swap operation
    Tmin = max(Tmin,T1); Tmax = min(Tmax,T2);
end
% No intersection with box if Tmin>Tmax
flag = (Tmin<=Tmax);