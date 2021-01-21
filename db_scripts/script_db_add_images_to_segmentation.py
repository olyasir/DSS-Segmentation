import mysql.connector as mariadb
import os.path

mariadb_connection = mariadb.connect(user='root', password='', database='DIP_TAU')
cursor = mariadb_connection.cursor()

out_path = '/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/results/Mask_gc/'
text_file = open('/Users/adiel/Projects/TAU/DeadSeatScrolls/Segmentation/Haifa_priority3_images.txt', 'r')
imgs = text_file.readlines()

for j in range(0,len(imgs)):
#for j in range(0, 1):
    print 'process image ' + str(j) + 'outof' + str(len(imgs))
    (fpath, ffile) = os.path.split(imgs[j])
    img_name = ffile
    img_path = fpath
    print img_name

    outimgname = img_name[0:-4] + '_gc_rect.png'
    if os.path.exists(out_path + outimgname):
        success=1
    else:
        success=0;



    exstring = "INSERT INTO dip_segmentation_process (img_name,img_path,out_path,process_date,success) VALUES ('%s' ,'%s','%s',NULL,'%d')" % (img_name,img_path,out_path,success)

#    print exstring
    try:
        cursor.execute(exstring)
    except mariadb.Error as err:
        print("Something went wrong: {}".format(err))


mariadb_connection.commit()
mariadb_connection.close()

