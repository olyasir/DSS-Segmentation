# DSS-Segmentation
# Segmentation for DSS manuscripts
DSS Fragments Segmentation pipeline
The scripts are located in : https://www.dropbox.com/sh/1dc50g802umalg5/AABZ73a6LvgPJZ0kR-Pex21Sa?dl=0 

## Crop
  1.	Run GrabCut->SegmentFragment.py 
  
Configuration:

a.	list_to_process – path to text file with all images to process (example files_from_nli_fourth_batch.txt)

b.	base_path – local path where all outputs will be saved

c.	img_path – path to images from list_to_process

the script will produce 2 outputs for each image that are used in downstream scripts.
1.	in base_path/fragments – the cropped fragments
2.	in base_path/cords – the coordinates of the crop
## Japanese paper removal
	Run matlab->script_remove_jp_by_dirs.m
Configuration:
1.	base_in_dir – the fragments directory that is produced by SegmentFragment.py
2.	 base_out_dir – your local directory for images without japaneese paper
Note that in some of the images the Japanese paper is not removed.
## Boundary creation
	Run matlab->script_segment_with_gc.m
Configuration:
1.	gc_img_dir – fragments folder either from SegmentFragment.py  or base_out_dir after japaneese paper removal.
2.	File path of all images to process – in line 28. 
3.	gc_cords_dir – crop coordinates folder  from SegmentFragment.py  
4.	gc_boundary_dir – output folder for boundaries
5.	json_output_dir – output folder for boundaries in json format (for Bronson)



