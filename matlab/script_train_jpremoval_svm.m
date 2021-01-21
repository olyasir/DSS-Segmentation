%collcect data for japanesepaper removaal 
% run multiple times
% first time collect parchment and letters area
% second time collect japanese paper area

imFolder='train_jp_removal';


D=dir([imFolder,'/*.png']);
TR=[];
%X=[];
for d=1:numel(D),
    im=imread(fullfile(imFolder,D(d).name));
    
    frag=imcrop(im);
    fragHsv=rgb2hsv(frag);
    hsvData=reshape(fragHsv,[size(fragHsv,1)*size(fragHsv,2),3]);
    TR=[TR;hsvData];
    
end

X=[X;TR];
%Y=zeros(size(TR,1),1);
Y=[Y;ones(size(TR,1),1)];
Mdl = fitcsvm(X,Y);

im1=imread(fullfile('jp_removal_test','P1025-Fg001-R-C01-R01-D23052013-T104028-LR445_ColorCalData_IAA_Both_CC110304_110702.png'));
fragTest=imcrop(im1);
fragTestHsv=rgb2hsv(fragTest);
testData=reshape(fragTestHsv,[size(fragTestHsv,1)*size(fragTestHsv,2),3]);

[labelIdx,score] = predict(Mdl,testData);

save('JP_SVM_MODEL.mat',Mdl);