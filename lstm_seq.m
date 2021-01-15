
for i=1:20
   %asd =resample(squeeze([data(:,2:end-1,i) data(:,4:end,i)]),squeeze(tim2(2:end,i)),25,'pchip');%CTPE. Broken 3rd column removed
    asd =resample(squeeze([data(:,2:end-1,i) ]),squeeze(tim2(2:end,i)),25,'pchip');
  
   asd2=resample(squeeze(data(:,1,i)),squeeze(tim2(2:end,i)),25,'pchip');%ground truth

   inp{i}=asd(5:6400,1:2)';
    out{i}=asd2(5:6400,:)';
end

tr=[1,3:10,12:20];


x=inp(tr)';

y=(out(tr))';


XTest=inp';
YTest=out';
%YTest=cell2mat(vel')';

 mu = mean([x{:}],2);
 sig = std([x{:}],0,2);
 
  mu2 = mean([y{:}],2);
 sig2 = std([y{:}],0,2);

for i = 1:numel(x)
     x{i} = (x{i} - mu) ./ sig;
  %  x{i} = (x{i}) ./ sig;
    XTest{i} = (XTest{i}-mu) ./ sig;
end
for i = 1:numel(y)
     y{i} = (y{i} - mu2) ./ sig2;
  %  x{i} = (x{i}) ./ sig;
    YTest{i} = (YTest{i}-mu2) ./ sig2;
end

numResponses = size(y{1},1);
%numResponses = size(y,1);
featureDimension = size(x{1},1);
numHiddenUnits =50;

layers = [ ...
    sequenceInputLayer(featureDimension)
    % lstmLayer(numHiddenUnits,'OutputMode','sequence')
     lstmLayer(numHiddenUnits,'OutputMode','sequence')
   %dropoutLayer(0.05)
   % lstmLayer(numHiddenUnits)
    fullyConnectedLayer(numResponses)
    % tanhLayer
    regressionLayer];

maxEpochs = 2000;
miniBatchSize =5;

options = trainingOptions('adam', ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',0.005*1, ...
    'ValidationData',{XTest(2),YTest(2 )}, ...%
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',100, ...
    'GradientThreshold',0.01*1000, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress',...
    'L2Regularization',0.00001,...
     'ExecutionEnvironment', 'GPU',...
    'Verbose',1);
%
[net,info] = trainNetwork(x,y,layers,options);

%XTest=inp_all;
%YTest=out;



[net,YPred_o]= predictAndUpdateState(net,XTest,'MiniBatchSize',1);

YPred = predict(net,XTest,'MiniBatchSize',1);

asd=(YTest{11});

asd2=(YPred{11});


asd3=(YPred_o{2});

plot(asd)
hold on
plot(asd2)

%
% for i=1:421
%     pos=pos_all{i, 1}(:,1:end);
%     if pos(1,500)==NaN
%         i
%     end
%    % scatter3(pos(1,:),pos(2,:),pos(3,:))
%     hold on
%
% end
