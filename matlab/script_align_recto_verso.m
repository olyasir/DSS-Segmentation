
P=config_params();

fragname1='P589-Fg001-R';
im1 = imread(fullfile(P.MASK_PATH,[fragname1,'_mask.png']));

fragname2='P589-Fg001-V';
im2 = imread(fullfile(P.MASK_PATH,[fragname2,'_mask.png']));
im2f = fliplr(im2);

stats1 = regionprops(im1,'Orientation')
stats2 = regionprops(im2f,'Orientation')

figure(1);
subplot(1,2,1);title('Recto')
imshow(im1);
subplot(1,2,2);title('Verso');
imshow(im2f);


figure(2);
subplot(1,2,1);title('Recto')
imshow(im1);
subplot(1,2,2);title('Verso');
imshow(im2f);

rotationAngle = stats2.Orientation-stats1.Orientation;
im2fr=imrotate(im2f,-rotationAngle);

imwrite(im2f,fullfile(P.MASK_PATH,[fragname2,'_filped_mask.png']));
imwrite(im2fr,fullfile(P.MASK_PATH,[fragname2,'_fliped_rotated_mask.png']));

im2frag = imread(fullfile(P.FRAGMENTS_PATH,[fragname2,'_frag.png']));
im2fragrot=imrotate(im2frag,-rotationAngle);
imwrite(im2fragrot,fullfile(P.FRAGMENTS_PATH,[fragname2,'_rotated_frag.png']));


figure(3);
subplot(1,2,1);
imshow(im1);
subplot(1,2,2);
imshow(im2fr);

%BoundingBox: [23.5000 26.5000 553 750] uperleft x,y.. width x, width y
stats = regionprops(im2fr,'BoundingBox');
bb=stats.BoundingBox;
im2frc = im2fr(bb(2)+0.5:bb(2)+bb(4)-0.5,bb(1)+0.5:bb(1)+bb(3)-0.5);

im2frc = im2frc(1:size(im1,1),:);
aligned_mask=bitor(im1, im2frc);

imwrite(aligned_mask, fullfile(P.MASK_PATH,[fragname1,'_mask_av.png']));

figure(4);
subplot(1,3,1);
imshow(im1);
subplot(1,3,2);
imshow(im2frc);
subplot(1,3,3);
imshow(aligned_mask);

