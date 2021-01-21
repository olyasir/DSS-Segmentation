
imgname='P10-Fg001-R-C01-R01-D03062015-T110259-LR445 _PSC.jpg'
boundaries_file='P10-Fg001-R-C01-R01-D03062015-T110259-LR445 _PSC_frag_boundaries.mat'
load(boundaries_file);

origimg=imread(imgname);
figure;
imshow(origimg);
hold on
for kk = 1:length(B_orig)
    boundary = B_orig{kk}.*(1/gc_resize);
    plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

