function [y1,y2,y3,y4] = two_dim(n1,n2)
f = 1;
format short
syms x11 x21 x22 x12
C = cov(n1,n2);
p = C(2,1)/(x21*x22);
for i = 1:10 
    f = 1/(sqrt(1-p^2)*2*pi*x21*x21)*exp(-1/(2*(1-p^2))) *... 
        (((n1(i)-x11)^2/x21^2)+((n2(i)-x12)^2/x22^2)-...
        (2*p*(n1(i)-x11)*(n2(i)-x12)/(x21*x22))) * f;
    
end
log_f = log (f);

mu11 = diff(log_f,x11);
jj = subs (mu11,[x12,x21,x22],[mean(n2),var(n1),var(n2)]);
equ11 = jj == 0;
j = vpasolve(equ11,x11);
y1 = (j);

mu12 = diff(log_f,x12);
jj = subs (mu12,[x11,x21,x22],[mean(n1),var(n1),var(n2)]);
equ12 = jj == 0;
j = vpasolve(equ12,x12);
y2 = (j);

mu21 = diff(log_f,x21);
jj = subs (mu21,[x12,x11,x22],[mean(n2),mean(n1),var(n2)]);
equ21 = jj == 0;
j = vpasolve(equ21,x21);
y3 = (j);

mu22 = diff(log_f,x22);
jj = subs (mu22,[x12,x11,x21],[mean(n2),mean(n1),var(n1)]);
equ22 = jj == 0;
j = vpasolve(equ22,x22);
y4 = (j);

end




