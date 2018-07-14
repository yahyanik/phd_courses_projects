function [y1,y2,y3,y4,y5,y6] = three_dim_1(n1,n2,n3)
f = 1;
syms x11 x21 x22 x12 x13 x23
c12= cov(n1,n2);
c23 = cov(n3,n2);
c13 = cov(n1,n3);
sig = [x21 0 0;0 x22 0;0 0 x23];
for i = 1:10 
    A1 = n1(i)-x11;
    A2 = n2(i)-x12;
    A3 = n3(i)-x13;
    A = [A1;A2;A3];
    f = (1/(sqrt((2*pi)^3)*det(sig)))*exp(-1/2*(transpose(A)*inv(sig)*(A))) * f;
end
log_f = log (f);

mu11 = diff(log_f,x11);
jj = subs (mu11,[x13,x12,x21,x22,x23],[mean(n3),mean(n2),var(n1),var(n2),var(n3)]);
equ11 = jj == 0;
j = vpasolve(equ11,x11);
y1 = (j);

mu12 = diff(log_f,x12);
jj = subs (mu12,[x11,x13,x21,x22,x23],[mean(n1),mean(n3),var(n1),var(n2),var(n3)]);
equ12 = jj == 0;
j = vpasolve(equ12,x12);
y2 = (j);

mu13 = diff(log_f,x13);
jj = subs (mu13,[x11,x12,x21,x22,x23],[mean(n1),mean(n2),var(n1),var(n2),var(n3)]);
equ13 = jj == 0;
j = vpasolve(equ13,x13);
y3 = (j);

mu21 = diff(log_f,x21);
jj = subs (mu21,[x12,x13,x11,x22,x23],[mean(n2),mean(n3),mean(n1),var(n2),var(n3)]);
equ21 = jj == 0;
j = vpasolve(equ21,x21);
y4 = (j);

mu22 = diff(log_f,x22);
jj = subs (mu22,[x12,x13,x11,x21,x23],[mean(n2),mean(n3),mean(n1),var(n1),var(n3)]);
equ22 = jj == 0;
j = vpasolve(equ22,x22);
y5 = (j);

mu23 = diff(log_f,x23);
jj = subs (mu23,[x12,x13,x11,x21,x22],[mean(n2),mean(n3),mean(n1),var(n1),var(n2)]);
equ23 = jj == 0;
j = vpasolve(equ23,x23);
y6 = (j);
end