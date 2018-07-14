clc
clear all

%% part a)
mu = [0 0 0;0 0 5;0 5 0;1 5 5];
sigma=repmat(1*eye(3),[1,1,4])
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
xlabel('feature 1')
ylabel('feature 2')
zlabel('feature 3')
legend ('class 1','class 2', 'class 3','class 4')
title('figure of 3-D data')

%% part c)
R = [r(:,:,1);r(:,:,2);r(:,:,3);r(:,:,4)];   %putting all the data for different classes together
[pc,score,latent] = pca(R);
%pc gives the new basis in each column in order of maximum variance
%score is the projection on the new axis
%latent is the variance of each dimention of data in the new axis

%% part d)
figure()
plot (score(:,1),score(:,2),'*') %plotting the PCA output
xlabel('feature 1')
ylabel('feature 2')
%legend ('class 1','class 2', 'class 3','class 4')
title('figure of 2-D data')

%% part e)
net2 = newff( R', score(:,1:2)',2);
net2.layers{1}.transferFcn = 'purelin';
net2.trainParam.epochs = 10000;
view(net2)

%% part f)
net2 = train(net2,R',score(:,1:2)');

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
xlabel('feature 1')
ylabel('feature 2')
title('figure of 2-D data (ANN)')

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
xlabel('feature 1')
ylabel('feature 2')
title('figure of 2-D data')

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
LDA_eigvector = lambda
IW{1,1} % weights of the first layer t hidden layer 
LW{2,1} % weights of the hidden layer to output layer 

%% part jh)
k2 = sim(net,R');
figure()
plot(k2(1,:),k2(2,:),'+')
xlabel('feature 1')
ylabel('feature 2')
title('figure of 2-D data (ANN)')

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











