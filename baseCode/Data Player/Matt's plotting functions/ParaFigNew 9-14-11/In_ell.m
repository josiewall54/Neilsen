function [I] = in_ell(Ellsumm,data)

cent = Ellsumm(1:2);
R = zeros(2,2);
C=R;
R(1:4) = Ellsumm(3:6);
C(1:4) = Ellsumm(7:10);
ellang = -atan2(R(1,2),R(1,1))
c11 = C(1,1);
c22 = C(2,2);
tdat = data;
tdat(:,1) = tdat(:,1) - cent(1);
tdat(:,2) = tdat(:,2) - cent(2);
tdat = rotate2(tdat',ellang*180/pi);
m = tdat(2,:)./tdat(1,:);
x2 = (c11*c22)^2./(c22^2 + c11*c11*(m.^2));
x = sqrt(x2);
y = m.*x;
Rell = sqrt(x.^2 + y.^2);
Rdat = sqrt(sum(tdat.*tdat));
I = find(Rdat<Rell);


