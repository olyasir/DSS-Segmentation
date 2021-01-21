function P = config_params()

P.IMG_PATH='../../images/';
P.FRAGMENTS_PATH='../results/Mask_gc/';
P.FRAGMENTS_ROTATED_PATH='../results/Frag_Rotated/';
P.MASK_PATH='../results/Mask/';
P.MASK_ALIGNED_PATH = '../results/Mask_Aligned/';
P.JSON_PATH='../results/JSON1/';

% resize images before processing
P.resize_scale=2;
P.plot_debug=1;

% used in biggest_con_comps
P.min_area_thresh=0.001;

% show orignal image with gc segmentation 
P.SHOW_ORIGINAL=1;

return;