

import numpy as np
import cv2
from matplotlib import pyplot as plt

#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/ShadeRemoval/images/M43124-1-E_8_frag.png')
#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments/P589-Fg001-V_frag.png')
imgpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/ShadeRemoval/images/'
imgname='M43124-1-E_frag_03orig.jpg'
imggrayname=imgpath+ imgname
imggray = cv2.imread(imggrayname)
imggray = imggray[:,:,0]
print imggray.shape
img = cv2.cvtColor(imggray,cv2.COLOR_GRAY2RGB)
#plt.imshow(img),plt.colorbar(),plt.show()

#raise SystemExit(0)

mask = np.zeros(img.shape[:2],np.uint8)
bgdModel = np.zeros((1,65),np.float64)
fgdModel = np.zeros((1,65),np.float64)

img_w=imggray.shape[1];
img_h=imggray.shape[0];

print 'grabcut - rect'
rect = (5,5,img_w-10,img_h-10)
cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)
mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
img = img*mask2[:,:,np.newaxis]
outimgname = imgname[0:-4]+'_gc_rect.png'
cv2.imwrite(imgpath+outimgname,img)

#raise SystemExit(0)

print 'read stroke mask image'
# newmask is the mask image I manually labelled
#newmask = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/ShadeRemoval/GrabCut/M43124-1-E_8_frag_a.png',0)
stroke_mask_name = imgname[0:-4]+'_gc_stroke_mask.png'
newmask = cv2.imread(imgpath +stroke_mask_name,0)

# whereever it is marked white (sure foreground), change mask=1
# whereever it is marked black (sure background), change mask=0
mask[newmask == 0] = 0
mask[newmask == 255] = 1

#plt.imshow(mask)
print 'grabcut with mask'
mask, bgdModel, fgdModel = cv2.grabCut(img,mask,None,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_MASK)

mask = np.where((mask==2)|(mask==0),0,1).astype('uint8')
img1 = img*mask[:,:,np.newaxis]
#plt.imshow(img),plt.colorbar(),plt.show()
outimgname = imgname[0:-4]+'_gc_final.png'
cv2.imwrite(imgpath+outimgname,img1)



#rect = (50,50,450,290)
#cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)

#mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
#img = img*mask2[:,:,np.newaxis]

#plt.imshow(img),plt.colorbar(),plt.show()

