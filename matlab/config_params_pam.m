function P = config_params_pam()

P.IMG_PATH='../../images/';
P.PREPROCESSED_PATH='../results/PAM/Preprocessed/';

P.FRAGMENTS_PATH='../results/PAM/Fragments/';
P.MASK_PATH='../results/PAM/Mask/';


% resize images before processing
P.resize_scale=1;
P.plot_debug=1;

% used in biggest_con_comps
P.min_area_thresh=0.001;

% crop fragment padding
P.crop_pad=10;

return;