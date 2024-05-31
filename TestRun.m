function test_network(net_stutter,image)
I=imread(image);
R=imresize(I,[224,224]);
[YPred]=classify(net_stutter,R);

figure;
imshow(R);
title({char(YPred)})
end
