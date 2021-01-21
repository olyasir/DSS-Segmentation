

import mysql.connector as mariadb

mariadb_connection = mariadb.connect(user='root', password='', database='DIP_TAU')
cursor = mariadb_connection.cursor()

img_name='a'
img_path='b'
out_path='c'
success=0;


exstring = "INSERT INTO dip_segmentation_process (img_name,img_path,out_path,process_date,success) VALUES ('%s' ,'%s','%s',NULL,'%d')" % (img_name,img_path,out_path,success)

print exstring

cursor.execute(exstring)

mariadb_connection.commit()


#cursor.execute("INSERT INTO dip_segmentation_process (img_name,img_path,out_path,success) VALUES (%s,%s,%s,%d)", (img_name,img_path,out_path,success))


