
import os
from os import listdir
from os.path import isfile, join
import numpy as np
import cv2
from matplotlib import pyplot as plt

#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/ShadeRemoval/images/M43124-1-E_8_frag.png')
#imggray = cv2.imread('/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Fragments/P589-Fg001-V_frag.png')

#imgpath='/Volumes/Maxtor/DSS_IAA_100717/Bronson_sent/p1095/'
#outpath='/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask_gc/haifa_priority1/'
#onlycolorimgs = onlyfiles


DEBUG=1
RUNFROMTEXTFILE=0

base_path='/Users/adiel/Dropbox/temp/anna_331_2/'
list_to_process='jm_RA_n8_Y49UKCnPJ_files'

if RUNFROMTEXTFILE:
    text_file = open(base_path+list_to_process+'.txt', 'r')
    outpath = base_path+'results/'+list_to_process+'_debug/'
    outpathfrag = base_path+'results/'+list_to_process+'_gc/'
    outcords = base_path+'results/'+list_to_process+'_cords/'
    onlycolorimgs = text_file.readlines()
else:
    imgpath = '//Users/adiel/Dropbox/Projects/TAU/DeadSeatScrolls/images/Berlin/fragments/'
    outpath = '/Users/adiel/Dropbox/Projects/TAU/DeadSeatScrolls/images/Berlin/results/'
    outpathfrag = '/Users/adiel/Dropbox/Projects/TAU/DeadSeatScrolls/images/Berlin/results/'
    base_path = imgpath
    outcords = base_path + 'results/' + 'cords/'
    outpathfrag=outpath

    onlyfiles = [f for f in listdir(imgpath) if isfile(join(imgpath, f))]
    # onlycolorimgs = [f for f in onlyfiles if f.find('IAA')>0]
    onlycolorimgs = [f for f in onlyfiles if f.find('DS_Store') < 0]

#onlycolorimgs = onlycolorimgs[:3]
#print onlycolorimgs


print len(onlycolorimgs)

#range(0,2):
for j in range(0, len(onlycolorimgs)):
    print 'process image ' + str(j) + 'outof' + str(len(onlycolorimgs))
    print onlycolorimgs[j]

    if RUNFROMTEXTFILE:
        (fpath, ffile) = os.path.split(onlycolorimgs[j])
        imgname = ffile
        imgpath = base_path
        imgcolorname = imgpath + '/' + imgname
        imgcolorname = imgcolorname[0:-1]
    else:
        imgname = onlycolorimgs[j]
        imgcolorname = imgpath + '/' + imgname

    print imgname
    print imgcolorname

    outimgname = imgname[0:-4]+'_gc_rect.png'
   # if os.path.exists(outpath+outimgname):
   #     continue

    imgorig = cv2.imread(imgcolorname)
    h, w = imgorig.shape[:2]
    print 'image size='+ str(h)+ ' ' + str(w)
    resize_factor = 1
    gc_bg_rect = 3  # for resize_factor 0.5 I used 20

    while (h*w>3000000):
        resize_factor = resize_factor*0.5
        gc_bg_rect = gc_bg_rect/2
        h = h * resize_factor
        w = w * resize_factor
        print 'resize image '+str(resize_factor)+' '+str(gc_bg_rect)

    imgscaled = cv2.resize(imgorig, None, fx=resize_factor, fy=resize_factor, interpolation=cv2.INTER_CUBIC)
    #raise SystemExit(0)


    imggray = cv2.cvtColor(imgscaled, cv2.COLOR_BGR2GRAY)
    if DEBUG:
        outimgname = imgname[0:-4] + '_gc_img_gray.png'
        cv2.imwrite(outpath + outimgname, imggray)

    # Otsu's thresholding after Gaussian filtering
    blur = cv2.GaussianBlur(imggray, (5, 5), 0)
    ret3, imbinary = cv2.threshold(blur, 70, 255, cv2.THRESH_BINARY)
#    ret3, imbinary = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
  #  ret3, imbinary = cv2.threshold(blur, 0, 255, cv2.THRESH_OTSU)

    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE,(30,30))
    imbinary = cv2.morphologyEx(imbinary,cv2.MORPH_CLOSE,kernel)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (30, 30))
    imbinary = cv2.morphologyEx(imbinary, cv2.MORPH_OPEN, kernel)


# try flood fille
# Copy the thresholded image.
    im_floodfill = imbinary.copy()
    # Mask used to flood filling.
    # Notice the size needs to be 2 pixels than the image.
    h, w = imbinary.shape[:2]
    mask = np.zeros((h+2, w+2), np.uint8)
    # Floodfill from point (0, 0)
    cv2.floodFill(im_floodfill, mask, (0, 0), 255);

    # Invert floodfilled image
    im_floodfill_inv = cv2.bitwise_not(im_floodfill)

    # Combine the two images to get the foreground.
    im_out = imbinary | im_floodfill_inv  #kernel = np.ones((5, 5), np.uint8)

    if DEBUG:
        outimgname = imgname[0:-4] + '_gc_img_bin.png'
        cv2.imwrite(outpath + outimgname, im_out)
    imbinary = im_out

    #---- Connected component
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
    stats = stats[1:,] #remove background label
    # The fourth cell is the centroid matrix, x,y locations (column, row)
    centroids = output[3]
    centroids = centroids[1:,] #remove background label

    #print num_labels
    #print stats
    #print centroids
    #plt.imshow(imggray)
  #  cv2.waitKey(0)

    # find distance of cc centroids to center of image
    d=[]
    dict={}
    minCCArea=0.001*w*h
    imgcenter = np.divide(imgscaled.shape[0:2],2) #row,column
    print 'imgcenter='
    print (imgcenter)
    print 'minCCWidth=', minCCArea
    for k in range(0, centroids.shape[0]):
        print k,'area=', stats[k,cv2.CC_STAT_AREA]
        ccArea=stats[k,cv2.CC_STAT_AREA]
        if ccArea > minCCArea:
            print k, centroids[k]
            dist=np.linalg.norm(np.flip(imgcenter,0) - np.array(centroids[k]))
            print dist
            d.append(dist)
            dict[k]=dist
       # print (stats[k])
#    cc_ind=np.argmin(d) #connected component index
#    print 'cc_ind='+str(cc_ind)
#    print ('cc boundaries=')
#    print (stats[cc_ind])
    mn = min(dict.items(), key=lambda x: x[1])
    print 'mn=',mn
    cc_ind=mn[0]
    print 'cc_ind=' + str(cc_ind)
    print ('cc boundaries=')
    print (stats[cc_ind])

# connected component mask - big image size
    ccmask = np.where((labels == cc_ind+1), 1, 0).astype('uint8')

    if DEBUG:
        # ccmask = np.zeros(labels.shape[:2], np.uint8)
   # ccmask[labels==cc_ind+1]=1
        outccmaskname = imgname[0:-4] + '_gc_ccmask.png'
        cv2.imwrite(outpathfrag + outccmaskname, ccmask)
    #raise SystemExit(0)

        outccmaskname = imgname[0:-4] + '_gc_labels.png'
        cv2.imwrite(outpathfrag + outccmaskname, labels)

    #apply mask on big image
  #  imgscaled = imgscaled * ccmask[:, :, np.newaxis]


# Crop Connected Component
    print 'crop image'
    if (stats[cc_ind][1]-gc_bg_rect < 0) or (stats[cc_ind][0]-gc_bg_rect<0):
        print 'ERROR while cropping '
        continue
    crop_img=imgscaled[stats[cc_ind][1]-gc_bg_rect:stats[cc_ind][1]+stats[cc_ind][3]+gc_bg_rect*2,\
                        stats[cc_ind][0]-gc_bg_rect:stats[cc_ind][0]+stats[cc_ind][2]+gc_bg_rect*2]

    if DEBUG:
        outimgname = imgname[0:-4] + '_gc_img_cc.png'
        cv2.imwrite(outpath + outimgname, crop_img)

    # crop image mask
    ccmask_croped = ccmask[stats[cc_ind][1] - gc_bg_rect:stats[cc_ind][1] + stats[cc_ind][3] + gc_bg_rect * 2, \
               stats[cc_ind][0] - gc_bg_rect:stats[cc_ind][0] + stats[cc_ind][2] + gc_bg_rect * 2]
    if DEBUG:
        outimgname = imgname[0:-4] + '_gc_ccmask_cropped.png'
        cv2.imwrite(outpath + outimgname, ccmask_croped)

    # write crop coordinates row, column
    outcordsname = imgname[0:-4] + '_gc_cords.txt'
    if not os.path.isdir(outcords):
        print('new directry has been created '+ outcords)
        os.system('mkdir '+outcords)
    cords_file = open(outcords + outcordsname, 'w')
    cords_file.write(str(stats[cc_ind][1]-gc_bg_rect)+' '+str(stats[cc_ind][0]-gc_bg_rect)+' '+str(resize_factor))

    #raise SystemExit(0)
    #  ---------- grab cut ----------
    crop_mask = np.zeros(crop_img.shape[:2], np.uint8)
    bgdModel = np.zeros((1,65),np.float64)
    fgdModel = np.zeros((1,65),np.float64)

    cimg_w = crop_img.shape[1]
    cimg_h = crop_img.shape[0]

    print 'grabcut - rect'
  #  if img_w > img_h:
  #      rect = (5*3,5*3,img_w-10*3,img_h-10*3)
  #  else:
  #    #  rect = (120, 50, img_w - 165, img_h - 50)
  #      rect = (5*3, 5*3, img_w - 10*3, img_h - 10*3)

    print 'crop_img.shape'
    print crop_img.shape
    rect = (gc_bg_rect , gc_bg_rect , cimg_w - gc_bg_rect , cimg_h - gc_bg_rect )
    print rect

    #plt.imshow(crop_img),plt.colorbar(),plt.show()

    #raise SystemExit(0)

   # cv2.imshow("cropped",crop_img)
    #cv2.waitKey(0)

    cv2.grabCut(crop_img, crop_mask, rect, bgdModel, fgdModel, 5, cv2.GC_INIT_WITH_RECT)
    mask2 = np.where((crop_mask==2)|(crop_mask==0),0,1).astype('uint8')
    img = crop_img*mask2[:,:,np.newaxis]

# apply CC mask
    #img1 = img * ccmask_croped[:, :, np.newaxis]
    print img.shape
    print ccmask_croped.shape
   # img1 = cv2.bitwise_and(img[:,:,0], ccmask_croped)

    #img1= np.multiply(img,ccmask_croped)

    img1=np.zeros(img.shape)
    img1[:,:,0] = img[:,:,0]*ccmask_croped
    img1[:, :, 1] = img[:, :, 1] * ccmask_croped
    img1[:, :, 2] = img[:, :, 2] * ccmask_croped
    outimgname = imgname[0:-4]+'_gc_rect.png'
    if not os.path.isdir(outpathfrag):
        print('new directry has been created ' + outpathfrag)
        os.system('mkdir ' + outpathfrag)

    cv2.imwrite(outpathfrag+outimgname,img1)

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

