
function Imgbw= binarize_Img(Img,se_background)
    [height_pic, width_pic, colors]=size(Img);
    figure;subplot(1,5,1);imshow(Img);
    if colors>1 
        grayimage=rgb2gray(Img); 
    else
        grayimage=Img;
    end
    background = imclose(grayimage,se_background);
    subplot(1,5,2);imshow(background)
    foreground = background-grayimage;
    subplot(1,5,3);imshow(foreground)
    fore_adjusted = imadjust(foreground);
    subplot(1,5,4);imshow(fore_adjusted)
    grayt=graythresh(fore_adjusted);
    Imgbw=im2bw(fore_adjusted,grayt);
    subplot(1,5,5);imshow(Imgbw)
    

