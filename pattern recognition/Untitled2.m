clc
clear all
% A = [2 4 6 8 10]
% B = [100 75 83 75 58]
% y = [78 85 88 96 100]
% figure
%    % add third plot to span positions 3 and 4
% 
% % yyaxis left           % plot against left y-axis 
% % bar(A,B)
% % plotyy (A,B,A,y)
% bar(A,[100 78;75 85;83 88 ;75 96 ;58 100 ])
% xlabel('Number of Pedestrian in Frame')
% 
% legend('Detection Rate (percent)','CPU Usage (percent)')
% xlim([0 12])
% ylim([0 110])
% % yyaxis right          % plot against right y-axis
% % plot(A,y2)
% % ylabel ('CPU Usage (percent)')
%%

% k = 5;
% q = 1;
% Xi = [1.36 1.41 1.22 2.46 0.68 2.51 0.60 0.64 0.85 0.66];
% x = 0:0.1:3;
% Cq = (pi^(q/2))/(gamma((q+2)/2));
% n = length(x);
% sam = length(Xi)
% for i = 1:n
%     D = 0;
%     for j = 1:10
%         V = x(i) - Xi(j);
%         D(j) = sqrt(V * V');
%     end
%     r = sort(D);
%     R = r(1:k);
%     y1 = k./(10.*R.*Cq);
%     y(i) = (sum(y1))/sam;
% end
% hold on
% plot(x,y)
% xlim= ([0,3]);
% ylim = ([0 1]);
% legend('One dimentional Density stimation k=5');
% xlabel('data');
% ylabel('p(x)');
% hold off

%% part a)
mu = [0 0 0;0 0 5;0 5 0;1 5 5];
sigma=repmat(1*eye(3),[1,1,4]);
r = zeros(125,3,4); %initializing matrix for data gereration
for i = 1:4
    r(:,:,i) = mvnrnd(mu(i,:),sigma(:,:,i),125);
end

%% part b)
figure()
hold all
scatter3(r(:,1,1),r(:,2,1),r(:,3,1),'r') %plotting data
scatter3(r(:,1,2),r(:,2,2),r(:,3,2),'b')
scatter3(r(:,1,3),r(:,2,3),r(:,3,3),'g')
scatter3(r(:,1,4),r(:,2,4),r(:,3,4),'y')

%% part c)
R = [r(:,:,1);r(:,:,2);r(:,:,3);r(:,:,4)];   %putting all the data for different classes together
[pc,score,latent] = pca(R);
%pc gives the new basis in each column in order of maximum variance
%score is the projection on the new axis
%latent is the variance of each dimention of data in the new axis

%% part d)
figure()
plot (score(:,1),score(:,2),'*') %plotting the PCA output

%% part e)
net2 = newff( R', score(:,1:2)',2);
net2.layers{1}.transferFcn = 'purelin';
net2.trainParam.epochs = 10000;

%% part f)
net2 = train(net2,R',score(:,1:2)');
view(net2)

%% part g)
wb = getwb(net2);
[b,IW,LW] = separatewb(net2,wb);
PCA_eigvector = latent
IW{1,1} % weights of the first layer t hidden layer 
LW{2,1} % weights of the hidden layer to output layer 

%% part h)
k = sim(net2,R');
figure()
plot(k(1,:),k(2,:),'+')

%% part i)
%PCA is a linear transformation of the data that finds the direction along 
%which the variance is maximum. As its name suggests, it finds principal 
%components. These components are the structure in the data along which 
%the data is most spread out. So mathematically, PCA is doing following 
%operation: h=W.x
%Where xx is the data with higher dimension and hh is the projection of the
%data using WW in a lower dimensional space. This transformation maps the 
%data to a space with uncorrelated features (take first k components showing
%high variance).
% Also, it can be prooven that if we use linear
% activation function then the output of each layer of the FeedForward 
% network created in part (e) should be equal to: h= WTx+b. This also yields
% a linear transfer function (linear Regression) from the 3-D input space 
%to the 2-D output space.    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% part jc)
class = [ones(125,1);2*ones(125,1);3*ones(125,1);4*ones(125,1)];
[Y, W, lambda] = LDA(R,class);
LDA_coefficient = W
%w is the discovered linear coefficients (first column is the constants)

%% part jd)
figure()
plot (Y(:,1),Y(:,2),'*') %plotting the PCA output

%% part je)
net = newff( R', Y(:,1:2)',2);
net.layers{1}.transferFcn = 'purelin';
net.trainParam.epochs = 10000;

%% part jf)
net = train(net,R',Y(:,1:2)');
view(net)

%% part jg)
wb = getwb(net);
[b,IW,LW] = separatewb(net,wb);
PCA_eigvector = latent
IW{1,1} % weights of the first layer t hidden layer 
LW{2,1} % weights of the hidden layer to output layer 

%% part jh)
k2 = sim(net,R');
figure()
plot(k2(1,:),k2(2,:),'+')

%% part ji)
%LDA is a linear transformation of the data that finds the direction along 
%which the variance is maximum. As its name suggests, it finds principal 
%components. These components are the structure in the data along which 
%the data is most spread out. So mathematically, PCA is doing following 
%operation: h=W.x
%Where xx is the data with higher dimension and hh is the projection of the
%data using WW in a lower dimensional space. This transformation maps the 
%data to a space with uncorrelated features (take first k components showing
%high variance).
% Also, it can be prooven that if we use linear
% activation function then the output of each layer of the FeedForward 
% network created in part (e) should be equal to: h= WTx+b. This also yields
% a linear transfer function (linear Regression) from the 3-D input space 
%to the 2-D output space.











