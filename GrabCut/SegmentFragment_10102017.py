

from os import listdir
from os.path import isfile, join
import numpy as np
import cv2
from matplotlib import pyplot as plt

#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/ShadeRemoval/images/M43124-1-E_8_frag.png')
#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments/P589-Fg001-V_frag.png')
imgpath='/Volumes/Maxtor/DSS_IAA_100717/Bronson_sent/p1095/'
outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask_gc/'

onlyfiles = [f for f in listdir(imgpath) if isfile(join(imgpath, f))]
onlycolorimgs = [f for f in onlyfiles if f.find('IAA')>0]

#onlycolorimgs = onlycolorimgs[:3]
#print onlycolorimgs
resize_factor=0.5

for j in range(0,1):#len(onlycolorimgs)):
    imgname = onlycolorimgs[j]
    imgcolorname = imgpath + imgname
    imgorig = cv2.imread(imgcolorname)
    imgscaled = cv2.resize(imgorig, None, fx=resize_factor, fy=resize_factor, interpolation=cv2.INTER_CUBIC)

    imggray = cv2.cvtColor(imgscaled, cv2.COLOR_BGR2GRAY)
    outimgname = imgname[0:-4] + '_gc_img_gray.png'
    cv2.imwrite(outpath + outimgname, imggray)

    # Otsu's thresholding after Gaussian filtering
    blur = cv2.GaussianBlur(imggray, (5, 5), 0)
    ret3, imbinary = cv2.threshold(blur, 80, 255, cv2.THRESH_BINARY)
#    ret3, imbinary = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    kernel = np.ones((5, 5), np.uint8)
    imbinary = cv2.morphologyEx(imbinary, cv2.MORPH_CLOSE, kernel)
    outimgname = imgname[0:-4] + '_gc_img_bin.png'
    cv2.imwrite(outpath + outimgname, imbinary)

    # You need to choose 4 or 8 for connectivity type
    connectivity = 4
    # Perform the operation
    output = cv2.connectedComponentsWithStats(imbinary, connectivity, cv2.CV_32S)
    # Get the results
    # The first cell is the number of labels
    num_labels = output[0]
    # The second cell is the label matrix
    labels = output[1]
    # The third cell is the stat matrix
    stats = output[2]
    # The fourth cell is the centroid matrix
    centroids = output[3]
    #print num_labels
    #print stats
    #print centroids
    #plt.imshow(imggray)
  #  cv2.waitKey(0)

    # find distance of cc centroids to center of image
    d=[]
    imgcenter = np.divide(imgscaled.shape[0:2],2)
    for k in range(0, centroids.shape[0]):
        print k, centroids[k]
        d.append(np.linalg.norm(np.flip(imgcenter,0) - np.array(centroids[k])))
    cc_ind=np.argmin(d) #connected component index

    print (stats[cc_ind])

    crop_cc=imgscaled[stats[cc_ind][1]:stats[cc_ind][1]+stats[cc_ind][3],stats[cc_ind][0]:stats[cc_ind][0]+stats[cc_ind][2]]
    outimgname = imgname[0:-4] + '_gc_img_cc.png'
    cv2.imwrite(outpath + outimgname, crop_cc)

    raise SystemExit(0)

for j in range(0,1):#len(onlycolorimgs)):
    #f in onlycolorimgs:
    imgname = onlycolorimgs[j];
    print imgname

    imgcolorname=imgpath+ imgname
    imgorig=cv2.imread(imgcolorname)
    print imgorig.shape
    img = cv2.resize(imgorig, None, fx=resize_factor, fy=resize_factor, interpolation=cv2.INTER_CUBIC)
    print img.shape
   # plt.imshow(img),plt.colorbar(),plt.show()

    #raise SystemExit(0)

    mask = np.zeros(img.shape[:2],np.uint8)
    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    img_w=img.shape[1];
    img_h=img.shape[0];

    print 'grabcut - rect'
    if img_w > img_h:
        rect = (5*3,5*3,img_w-10*3,img_h-10*3)
    else:
      #  rect = (120, 50, img_w - 165, img_h - 50)
        rect = (5*3, 5*3, img_w - 10*3, img_h - 10*3)

    cropx=int(900)
    cropy=int(418)
    cropw=int(1800)
    croph=int(1720)

    crop_img = img[cropy:cropy+croph,cropx:cropx+cropw]
    crop_mask = np.zeros(crop_img.shape[:2], np.uint8)
    outimgname = imgname[0:-4] + '_gc_crop_img.png'
    cv2.imwrite(outpath + outimgname, crop_img)

    cimg_w=crop_img.shape[1]
    cimg_h = crop_img.shape[0]
    print 'crop_img.shape'
    print crop_img.shape
    rect = (20 , 20 , cimg_w - 40 , cimg_h - 40 )
    print rect

    plt.imshow(crop_img),plt.colorbar(),plt.show()

    #raise SystemExit(0)

    cv2.imshow("cropped",crop_img)
    #cv2.waitKey(0)

    cv2.grabCut(crop_img, crop_mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)
    mask2 = np.where((crop_mask==2)|(crop_mask==0),0,1).astype('uint8')
    img = crop_img*mask2[:,:,np.newaxis]

    #    cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)
#    mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
#    img = img*mask2[:,:,np.newaxis]
    outimgname = imgname[0:-4]+'_gc_rect.png'
    cv2.imwrite(outpath+outimgname,img)

raise SystemExit(0)


imgname='M43124-1-E_frag_03orig.jpg'
imggrayname=imgpath+ imgname
imggray = cv2.imread(imggrayname)
imggray = imggray[:,:,0]
print imggray.shape
imgorig = cv2.cvtColor(imggray,cv2.COLOR_GRAY2RGB)
img = cv2.resize(imgorig,None,fx=0.25, fy=0.25, interpolation = cv2.INTER_CUBIC)
plt.imshow(img),plt.colorbar(),plt.show()

raise SystemExit(0)

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
cv2.imwrite(imgpath+'/tmp/'+outimgname,img1)



#rect = (50,50,450,290)
#cv2.grabCut(img,mask,rect,bgdModel,fgdModel,5,cv2.GC_INIT_WITH_RECT)

#mask2 = np.where((mask==2)|(mask==0),0,1).astype('uint8')
#img = img*mask2[:,:,np.newaxis]

#plt.imshow(img),plt.colorbar(),plt.show()

