clear all;
close all;


name='387';
n=6;
imgname=['../../images/PAM-forgil1/',name,'.jpg'];
matname=['../results/PAM/Preprocessed/',name,'/',name,'_frags.mat'];


im=imread(imgname);
load(matname);

bw=zeros(size(im));
bw(CCstats(n).PixelIdxList)=1;
ccmask = imfill(bw,'holes');
imshow(ccmask);
