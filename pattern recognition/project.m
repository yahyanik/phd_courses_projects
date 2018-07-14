clear;
clc;
close all;

%% get the values in the Excel using xlsread.
[num,txt,raw] = xlsread('HistoricalQuote.xlsx');
length = length(txt);
Date = zeros(length,1);
for i = 1:length-1
    DateString  = txt{i+1,1};
    formatIn = 'mmm/dd/yyyy';
    Date(i,1) = datenum(DateString,formatIn);
end
date = Date(1:length-1,:);
datas = fints(date,num,{'close','volume','open','high','low'});




%% indicators

%vroc: Volume rate of change
Vroc = volroc(datas);
vroc = fts2mat(Vroc.VolumeROC);
%ado: Accumulation/Distribution oscillato
Ado = adosc(datas);
ado = fts2mat(Ado.ADOsc);
%macd: Moving Average Convergence/Divergence
Macdvec = macd(datas);
macdLine = fts2mat(Macdvec.MACDLine);
NinePerMA = fts2mat(Macdvec.NinePerMA);
%stochosc: Stochastic oscillator
Stosc = stochosc(datas);
sok = fts2mat(Stosc.SOK);
sod = fts2mat(Stosc.SOD);
in1 = pvtrend(datas);
pvt = fts2mat(in1.PVT);
in2 = adline(datas);
adl = fts2mat(in2.ADLine);
% in3 = onbalvol(datas);
% on = fts2mat(in3.OnBalVol);t
in4 = medprice(datas);
med = fts2mat(in4.MedPrice);
wcls = wclose(datas);
wc = fts2mat(wcls.WClose);
%nTimes = 12;
% proc = prcroc(datas);
% pr = fts2mat(proc.PriceROC);
wadl = willad(datas);
wa = fts2mat(wadl.WillAD);
num = xlsread('number.xlsx');
indicator = [num,vroc,ado,macdLine,NinePerMA,sok,pvt,adl,med,wc,wa];

wr_feat(indicator,'step1.dat')
step1 = rd_feat('step1.dat');

%%

days_ahead = step1(:,:);
high = days_ahead(:,7);
low = days_ahead(:,8);
open = days_ahead(:,6);
[length,column] = size(days_ahead);

highest = max(high);
lowest = min(low);
for i= 1:length
    Nhigh_per(i) = (high(i)-open(i))/open(i);
end
for i = 1:length
    Nlow_per(i) = (low(i)-open(i))/open(i);
end

teresh = Nhigh_per+Nlow_per;
low_per = Nlow_per(1:730);
high_per = Nhigh_per(1:730);
for i=1:length
    if teresh(i) >0.01 
        label(i) = 1;
    else if teresh(i) < -0.01
         label(i) = 2;
    else 
         label(i) = 3;
        end
    end
end
wr_feat(label,'step2.dat');
  
figure
x=1:1:90;
scatter(x,label(2431:2520));

intor = [vroc,ado,macdLine,NinePerMA,sok,pvt,adl,med,wc,wa]; %these are the indicators
[coeff, score, latent, tsquared, explained, mu] = pca(intor);
feature_low = [ado,sok,adl,med,wc,wa];
feature_high = [ado,macdLine,NinePerMA,sok,med,wa];
feature = score(:,1:5);


%% Step 4 HMM training
label1 = label(1,1:2430);
days_ahead = feature (50:100,:);
trg = rand(5);
emg = rand(5,3);
[ESTTR,ESTEMIT] = hmmtrain(label1,trg,emg);
[seq,states] = hmmgenerate(90,ESTTR,ESTEMIT);
label_HMMtrue = label(2431:2520);
figure 
title('HMM result');
x = 1:1:90;
scatter(x,seq);
hold on
scatter(x,label_HMMtrue);

%% Step 5 NN train
% normalize feature  
[weigh,length] = size(feature);
for i = 1:length
    max_line(i) = max(feature(:,i));
    for Error = 1:weigh
        Nfeature(Error,i) = feature(Error,i)./max_line(i);
    end
end
feature1 = Nfeature(1:730,:)';

%% price low long term
[weigh_low,length_low] = size(feature_low);
for i = 1:length_low
    max_line(i) = max(feature_low(:,i));
    for Error = 1:weigh_low
        Nfeature_low(Error,i) = feature_low(Error,i)./max_line(i);
    end
end
%intor1 = intor(11:711,:);
net = lstmLayer(6,'Name','priceHigh') % lstm
%net = feedforwardnet(10);
%net.trainParam.epochs = 10000;
% net.trainParam.max_fail = 10;
data_trainLow = zeros(6,1);
data_targetLow = zeros();
for i = 1:17
    data_trainLow = [data_trainLow,Nfeature_low((100*(i-1)+1):(730+100*(i-1)),:)'];
    data_targetLow = [data_targetLow,Nlow_per((100*(i-1)+2):(731+100*(i-1)))];
end
[net,tr_low] = train(net,data_trainLow,data_targetLow);
view(net);
wb = formwb(net,net.b,net.iw,net.lw);
[b_low,iw_low,lw_low] = separatewb(net,wb);

data_pre = Nfeature_low(2431:2520,:)';
data_lowPre = [Nlow_per(2432:2520),0];
output_low = (net(data_pre))';
figure
x = 1:1:90;
plot(x,output_low);
hold on
plot(x,data_lowPre);
title('low price');

%% price low short term
%net = feedforwardnet(10);
%net.trainParam.epochs = 10000;
% net.trainParam.max_fail = 10;
net = lstmLayer(6,'Name','priceHigh') % lstm
data_trainLowST = Nfeature_low(1700:2430,:)';
data_targetLowST = Nlow_per(1701:2431);

[net,tr_lowST] = train(net,data_trainLowST,data_targetLowST);
view(net);
wb = formwb(net,net.b,net.iw,net.lw);
[b_lowST,iw_lowST,lw_lowST] = separatewb(net,wb);

data_pre = Nfeature_low(2431:2520,:)';
data_lowPre = [Nlow_per(2432:2520),0];
output_lowST = (net(data_pre))';
figure
x = 1:1:90;
plot(x,output_low);
hold on
plot(x,data_lowPre);
title('low price');
%% price high
[weigh_high,length_high] = size(feature_high);
for i = 1:length_high
    max_line(i) = max(feature_high(:,i));
    for Error = 1:weigh_high
        Nfeature_high(Error,i) = feature_high(Error,i)./max_line(i);
    end
end

%net = feedforwardnet(10);
net = lstmLayer(6,'Name','priceHigh') % lstm
%net.trainParam.epochs = 10000;
data_trainHigh = zeros(6,1);
data_targetHigh = zeros();
for i = 1:17
    data_trainHigh = [data_trainHigh,Nfeature_high((100*(i-1)+1):(730+100*(i-1)),:)'];
    data_targetHigh = [data_targetHigh,Nhigh_per((100*(i-1)+2):(731+100*(i-1)))];
end
[net,tr_high] = train(net,data_trainHigh,data_targetHigh);
view(net);
wb = formwb(net,net.b,net.iw,net.lw);
[b_high,iw_high,lw_high] = separatewb(net,wb);

data_pre = Nfeature_high(2431:2520,:)';
data_highPre = [Nhigh_per(2432:2520),0];
output_high = (net(data_pre))';
figure
x = 1:1:90;
plot(x,output_high);
hold on
plot(x,data_highPre);
title('high');

%% high price short term
net = feedforwardnet(10);
net.trainParam.epochs = 10000;
data_trainHighST = Nfeature_high(1700:2430,:)';
data_targetHighST = Nhigh_per(1701:2431);
[net,tr_highST] = train(net,data_trainHighST,data_targetHighST);
view(net);
wb = formwb(net,net.b,net.iw,net.lw);
[b_highST,iw_highST,lw_highST] = separatewb(net,wb);

data_pre = Nfeature_high(2431:2520,:)';
data_highPreST = [Nhigh_per(2432:2520),0];
output_highST = (net(data_pre))';
figure
x = 1:1:90;
plot(x,output_highST);
hold on
plot(x,data_highPreST);
title('high');

%% compare with threshold long term
output = output_low+output_high;
[length_output,weigh_output] = size(output);
for i=1:length_output
    if output(i) >0.01
        label_output(i) = 1;
    else if output(i) < -0.01
         label_output(i) = 2;
    else 
         label_output(i) = 3;
        end
    end
end
label_true = [label(2432:2520),0];
figure
x = 1:1:90;
scatter(x,label_output);
hold on
scatter(x,label_true);
title('label');
j = 0;
for i =1:90
    k(i) = label_output(i)- label_true(i);
    if k(i) ~= 0
        j = j+1;
    end
end

%% short term
outputST = output_lowST+output_highST;
[length_output,weigh_output] = size(output);
for i=1:length_output
    if outputST(i) >0.01
        label_outputST(i) = 1;
    else if output(i) < -0.01
         label_outputST(i) = 2;
    else 
         label_outputST(i) = 3;
        end
    end
end
label_true = [label(2432:2520),0];
figure
x = 1:1:90;
scatter(x,label_outputST);
hold on
scatter(x,label_true);
title('label');
Error = 0;
for i =1:90
    k(i) = label_outputST(i)- label_true(i);
    if k(i) ~= 0
        Error = Error+1;
    end
end