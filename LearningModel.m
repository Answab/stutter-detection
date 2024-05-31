clear all
clc
imds = imageDatastore('deeptransfer\Dataset1', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
[imdsTrain,imdsTest]=splitEachLabel(imds,0.8,0.2);
numClasses = numel(categories(imds.Labels));
net=resnet50;
    lgraph = layerGraph(net);
    %clear net;
    % New Learnable Layer
    analyzeNetwork(net)
    newLearnableLayer = fullyConnectedLayer(numClasses,'Name', 'new_fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10);
    % Replacing the last layers with new layers
    lgraph = replaceLayer(lgraph,'fc1000',newLearnableLayer);
    newsoftmaxLayer = softmaxLayer('Name','new_softmax');
    lgraph = replaceLayer(lgraph,'fc1000_softmax',newsoftmaxLayer);
    newClassLayer = classificationLayer('Name','new_classoutput');
    lgraph = replaceLayer(lgraph,'ClassificationLayer_fc1000',newClassLayer);
    % Training Options, we choose a small mini-batch size due to limited images 
    options = trainingOptions('sgdm','MaxEpochs',10,'MiniBatchSize',16,'Shuffle','every-epoch','InitialLearnRate',1e-4, 'Verbose',false,'Plots','training-progress');
    % Data Augumentation
    augmenter = imageDataAugmenter( 'RandRotation',[-5 5],'RandXReflection',1,'RandYReflection',1,'RandXShear',[-0.05 0.05],'RandYShear',[-0.05 0.05]);
    % Resizing all training images to [224 224] for ResNet architecture
    auimdsTrain = augmentedImageDatastore([224 224],imdsTrain,'DataAugmentation',augmenter);
    auimdsTest = augmentedImageDatastore([224 224],imdsTest,'DataAugmentation',augmenter);
   % auimdsvalidation= augmentedImageDatastore([224 224],imdsValidate,'DataAugmentation',augmenter);
    % Training
    net_word = trainNetwork(auimdsTrain,lgraph,options);
    %net=trainNetwork(augimdsTrain,lgraph,options);
    [YPred]=classify(net_word,auimdsTrain);
    train_accuracy=mean(YPred == imdsTrain.Labels)
    [YPred1]=classify(net_word,auimdsTest);
    test_accuracy=mean(YPred1==imdsTest.Labels)
    %[YPred,probs]=classify(net,auimdsValidation);
   % accuracy=mean(YPred == imdsValidate.Labels)
    save('net_word')
        