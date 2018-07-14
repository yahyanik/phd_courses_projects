function y = pso (x)

global ESTTR11
global ESTEMIT11
global ESTTR22
global ESTEMIT22
A = 1;
B = 2;
C = 3;
D = 4;
seq = [B,A,D,B,D,C,B,A];
p1 = [x(1) x(2) x(3)];
p2 = [x(4) x(5) x(6)];
% ESTTR11 =[    0.0859    0.0000    0.9141
%     0.4195    0.5805    0.0000
%     0.0000    0.2707    0.7293];
% ESTEMIT11 =[    0.0000    0.1312    0.0000    0.0000    0.8688
%     0.0000    0.0000    0.3476    0.6524    0.0000
%     0.3977    0.4290    0.1733    0.0000    0.0000];
% ESTTR22 =[    0.6418    0.0535    0.3047
%     0.6704    0.3296    0.0000
%     0.0000    0.3686    0.6314];
% ESTEMIT22 =[0.0138    0.0000    0.1657    0.5320    0.2886
%     0.8173    0.0000    0.0000    0.1827    0.0000
%     0.1849    0.5712    0.2439    0.0000    0.0000];
t1 = [0 p1; zeros(size(ESTTR11,1),1) ESTTR11];
t2 = [0 p2; zeros(size(ESTTR22,1),1) ESTTR22];
E1 = [zeros(1,size(ESTEMIT11,2)); ESTEMIT11] ;
E2 = [zeros(1,size(ESTEMIT22,2)); ESTEMIT22];
PSTATES_c_1 = hmmdecode(seq,t1,E1);
PSTATES_c_2 = hmmdecode(seq,t2,E2);

y = sum(sum(abs(PSTATES_c_1 - PSTATES_c_2)));

end
