function script_batch_segmentation_01_05_2011(P)

% dbstop if error
% time_str = datestr(now,30);
apply_paths;
if nargin<1
    P = config_params_batch_segmentation_21062012();
end
% logfile
% diary off
% time_str = datestr(now,30);
% diary(['diary_',time_str,'.txt']);

s = load('theta_rho_paper_fragment.mat');
theta_fragment_white_paper = s.theta;
rho_fragment_white_paper = s.rho;
clear s;

%[fnum,ftxt,filenames]= xlsread('G:\adiel\work\ongoingwork\201107_binarization_for_yosef\all_starsburg.xlsx');
%[fnum,ftxt,filenames]= xlsread('F:\adiel\work\ongoingwork\072011_binarization_for_yosef\all_vienna');
%[fnum,ftxt,filenames]= xlsread('G:\adiel\work\ongoingwork\201110_TefilaProject\ImagesForOCR\cambridge.xls');
[fnum,ftxt,filenames]= xlsread('y:\zaci\research\ongoingwork\201301_Process_Manchester_Collection\files_A_series.xls');
%filenames = file_list(P.IMG_PATH);
n_images = length(filenames);
%n_images=1;

if P.FLAG_FIND_RULER
    im_ruler = imread(P.ruler_path_and_filename);
end

results_log = cell(1,2);
results_log(1,1:2) = {'FGPImageName','Error'};
results_image = cell(1,10);
results_image(1,:) = {'FgpImageName','Path','DpiGrid','DpiGridScore','DateProcessed',...
    'DllVersion','ResizeScale','Calibration','LowestLimitFinalScore','Status'};

results_fragment = cell(1,32);
results_fragment(1,:) = {'FragmentId','FGPImageName','Scope','LabelLocX','LabelLocY',...
    'InitialRotationAngle','FinalRotationAngle','LineRotationScore','Line_Width',... %6
    'Line_Height','RotationAngleBoundingBox','BB_Width', 'BB_Height','NumFragment',... %10
    'BifolioLocX1','BifolioLocY1','BifolioLocX2','BifolioLocY2','BifolioStrengthScore',... %15
    'BifolioCompletenessScore','FinalScore','IsNotWhole ','LocationX1','LocationY1',... %20
    'LocationX2','LocationY2','BB_Array','stdRowsHeight','stdTxtPro',...        %25
    'disMedianMeanTxtPro','noiseValue','distMaskBinary'};

results_text = cell(1,15);
results_text(1,:) = {'TextComponentId ','FragmentId','RightMargin','LeftMargin',...
    'TopMargin','BottomMargin','MarginScore','NumTextComponent','NumLines','NumLinesScore',...
    'AvgLineHeight','ArrYCenterLine','ArrHeightLine','ImageName','FragmentNumber'};

cols_detection = zeros(3*n_images,20);
bifolio_scores = zeros(n_images,1);

pegasus_binarize_success=0;
fragment_id =  P.init_fragment_id;
% for n = [1957:1982,33:48] %:n_images
for n = 1:1%n_images%[1964:1982,33:48] %:n_images
    try
        close all;
        filename = filenames{n};
        % if (~isempty(strfind(filename,'COLOUR')) | ~isempty(strfind(filename,'RULER') ))
        %     continue;
        % end
        
        filepath = 'Y:\Zaci\Research\ongoingwork\201510_Russia_Segmentation_Arabic\';
        fname = '2015-09-23-00001_frag';
        filename = 'Y:\Zaci\Research\ongoingwork\201510_Russia_Segmentation_Arabic\2015-09-23-00001_frag.jpg';
        
        %filename = 'Y:\Zaci\Research\ongoingwork\201302_Process_Columbia_Collection\BJ_X893_J757_fol_21_recto.jpg';
        
        %filename = 'Y:\Cambridge\SingleConvertProcess\BJ\ToGnuzot\BJ_TS-NS-331-008-B.jpg';
        
        %filename = 'Y:\Zaci\Research\ongoingwork\201412_JTS_MultiFragment_Segmentation\Genizah_JTS_test_007.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201301_Process_Manchester_Collection\sample_images\L_205__L1F0B0S1.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201301_Process_Manchester_Collection\sample_images\B_7484__L1F0B0S1.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201301_Process_Manchester_Collection\sample_images\L_205__L1F0B0S1.jpg'
        %filename = 'Y:\Zaci\Research\ongoingwork\201301_Process_Manchester_Collection\sample_images\A_122__L2F0B0S1.jpg'
        %filename = 'Z:\SiteFiles\VImages\Manchester\A_series\A_1002__L1F0B0S2.jpg';
        %filename = 'y:\Cambridge\20121030_Disk_Jts_FinalProcess\BJ\JTS\bj_MS_5172_009.jpg'
        %filename = 'y:\Cambridge\20121030_Disk_Jts_FinalProcess\BJ\JTS\bj_MS_5172_004.jpg';
        %filename = 'y:\Cambridge\20121030_Disk_Jts_FinalProcess\BJ\JTS\BJ_MS_R215_014r.jpg'
        %filename = 'Y:\Cambridge\20100602Process\BJ\TS-A-001\VOL1\BJ_TS-A-001-011-P2-B.JPG'
        
        %filename = 'Y:\Zaci\Research\ongoingwork\20121212_ImageProcessing_leeds\MS_Roth_723_18__L1F0B0S1.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201112_FragmentRotationProblem\sample1\MS_L607__fol__2__L1F0B0S1.jpg'
        
        %filename = 'Y:\jnul\20120919_Disk_JNULProcess\BJ\JNUL\BJ_NLI 28o8199.31b.jpg';
        %filename = 'Y:\Brimingham\20120905_Disk_brimingamProcess\BJ\BRIMINGAM\Mingana\BJ_(10) Mingana Hebrew 17 fol 3.v.jpg';
        %filename = 'Y:\Brimingham\20120905_Disk_brimingamProcess\BJ\BRIMINGAM\Mittwoch\BJ_(6) Mittwoch 8 fol 1.v.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201209_EngishImagesForLior\329r-bkt0273-Xjpeg.jpg';
        %filename = 'Y:\Zaci\Research\ongoingwork\201209_EngishImagesForLior\105v-bkt0452-X_small.jpg';
        
        %filename = 'Y:\BritishLibrary\20101220_Disk_1Process\BJ\OR_MS_8660_8663\BJ_or_ms_8663_f001r.JPG';
        %filename = 'Y:\BritishLibrary\20101220_Disk_1Process\BJ\OR_MS_8660_8663\BJ_or_ms_8663_f001v.JPG';
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\foldout pages\or_ms_8663BJ_or_ms_8663_f001v.JPG'
        %filename = 'X:\AIU\IA\AIN__I_A_1__L1F0B0S1_1.jpg';
        
       % y:\zaci\ContentRotate\JTS\MS_L\MS_L607__fol__2__L1F0B0S1_1.jpg
        % gray ruler white strips. not complete ruler. 
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\or_ms_6356\BJ_or_ms_6356_f002r.jpg';
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\or_ms_5557L\BJ_or_ms_5557L_f008v.jpg';
        % gray ruler white strips. not complete ruler. 
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\or_ms_6356\BJ_or_ms_6356_f011v.jpg';
        
        % gray ruler white strips. long scroll. complete ruler. 
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\foldout pages\or_ms_5557B\BJ_or_ms_5557B_f011r.jpg';
        %filename = 'y:\BritishLibrary\20120326_Disk_6Process\BJ\foldout pages\or_ms_5557B\bj_or_ms_5557B_f011v.jpg';
        %filename = 'Y:\BritishLibrary\20120326_Disk_6Process\BJ\foldout pages\or_ms_5557B\bj_or_ms_5557B_f011v.jpg';
        % gray ruler with black strips
        %filename = 'Y:\BritishLibrary\20110804_Disk_cd_testProcess\BJ\or_5473\BJ_or_ms_5473_f001r.JPG';
        
        %P.IMG_PATH = '';
        disp([num2str(n),': ',P.IMG_PATH,filename]);
        [~, name, ~, versn] = fileparts(filename) ;
        results_image{end+1,1} = name;
        results_image{end,2} = P.IMG_PATH;
        try
            im = imread([P.IMG_PATH,filename]);
            flag_gray = 0;
            if size(im,3) < 3
                im = gray_image_to_3D(im);
                flag_gray = 1;
                %error('Image is grayscale, can''t be processed normally.');
            end
        catch ME
            disp(['Can''t open image file or image is grayscale "',filename,'", skipping file.']);
            results_image{end,10} = 'Y';
            results_log {end+1,:}= {name,'cant open file'};
            continue
        end
        
        % keep original image (true size)
        im_original = im;
        resize_scale = 1;
        if 1
        if (size(im,1)*size(im,2) > 3000000)
            resize_scale = uint32(sqrt((size(im,1)*size(im,2))/3000000));
            % resize_scale = floor(sqrt((size(im,1)*size(im,2))/3000000));
            % resize_scale = 2;
            if ( (size(im,1)/resize_scale)*(size(im,2)/resize_scale) > 3000000)
                resize_scale = resize_scale + 1;
            end
            im = imresize(im,[size(im,1)/resize_scale,size(im,2)/resize_scale]);
            
            %             [dpmm,score] = measure_cm_grid_paper(im, 2);
            %             dpi = dpmm*25.4
            
            %             im_ruler = imresize(im_ruler,[size(im_ruler,1)/resize_scale,size(im_ruler,2)/resize_scale]);
        end
        end
        results_image{end,7} = resize_scale;
        
        
        pixels_taken_from_left = 0;
        pixels_taken_from_right = 0;
        if P.FLAG_DELETE_WHITE_STRIPE
            [im  pixels_taken_from_left pixels_taken_from_right] = delete_white_stripe_2(im);
        end
        
        if P.FLAG_DELETE_BLACK_STRIPE
            im = delete_black_stripe_3(im,1);%round(resize_scale));
        end
        
        % Here we separate the background from the fragments
        
        % theta and rho of the fragment and white paper against the background.:
        theta_fragment_rest = [-0.2312,-0.1811,0.4493];
        rho_fragment_rest = 9.2371;
        % segmentation of paper and background:
        %         flag_gray = true;
        if flag_gray
            im_binary = segment_gray_scale(im,0.3);
        else
            if P.FLAG_HSV_BIN %JTS,Viena
                im_hsv = rgb_to_hsv(im);
                % regular 
                %thresh1 = employ_threshold(im_hsv,true,[0 1 0],25);
                %thresh2 = employ_threshold(im_hsv,false,[1 0 0],77);
                %thresh3 = employ_threshold(im_hsv,false,[0 0 1],64);
                %im_binary = matrix_or(matrix_and(thresh1,thresh2),thresh3);
                
                %Manchester
                thresh1 = employ_threshold(im_hsv,true,[0 1 0],10);
                thresh2 = employ_threshold(im_hsv,true,[1 0 0],10);
                thresh3 = employ_threshold(im_hsv,false,[1 0 0],250);
                thresh4 = employ_threshold(im_hsv,false,[0 0 1],95);
                im_binary = matrix_or(thresh1,thresh4);
                
                
                
                % Leeds with blue background                
                %thresh1 = employ_threshold(im_hsv,true,[0 0 1],100);
                %im_binary = thresh1;
                
                % JTS with blue background
                %thresh1 = employ_threshold(im_hsv,true,[0 1 0],50);
                %thresh2 = employ_threshold(im_hsv,true,[1 0 0],200);
                %thresh3 = employ_threshold(im_hsv,false,[0 0 1],64);                               
                %im_binary = matrix_and(matrix_and(thresh1,thresh2),thresh3);
                im_binary = clear_small_parts(im_binary);
            else % AIU,Cambridge
                im_binary = segment_by_rgb_trained(im,theta_fragment_rest,rho_fragment_rest);
            end
            %im_binary = rgb2gray(im);
        end
        [im_labels,last_label,bounding_rects,areas] = biggest_con_comps(im_binary,P.min_comp_size,P.flag_use_filled_area);
          full_im_labels = im_labels;
          
        if ~all(im_labels(:)==0) % if the image is not empty
            
            if P.FLAG_FIND_RULER
                [coordinates, ruler_success, scale, ruler_H, n_ruler_points, n_match_points] = ...
                    find_ruler_by_sift(im,im_ruler,P.ANALYZE_MODE,[],[],0,2,0.005,0.005,0.01);
              
              %[coordinates] = find_comp_on_margin(im_binary, bounding_rects)
              
              if ~isempty(coordinates)
                  ruler_success=true;
                  n_match_points=20;
              end
              
                % adiel 5/1/2013
                if (ruler_success)
                ruler_angle =  atan( abs((coordinates(2,2) - coordinates(1,2))/  (coordinates(2,1) - coordinates(1,1))));
                ruler_angle = ruler_angle*180/pi();
                
                
                % in Flags document flg.ANGLE is the maximum angle of the
                % ruler. (20 default here. TODO: move to settings)
                rulerRotation = P.RULER_ANGLE;
                if (abs(ruler_angle) >rulerRotation &&( abs(ruler_angle) >90+rulerRotation ||abs(ruler_angle) < 90-rulerRotation))
                    ruler_success = false;
                end
                end
                if ruler_success
                    [ruler_label ruler_area] = find_ruler_label(im_labels,coordinates,n_match_points);
                end
                
                %%%
                % in Flags documentflg.MIN_MATCH_POINTS is numebr of
                % matching points between ruler and the example ruler image.
                if (ruler_success && n_match_points>P.MIN_MATCH_POINTS && mean(ruler_label)>-1)
                    [im_labels im_binary] = remove_ruler(im_labels,ruler_label,ruler_area,coordinates,im,P.GRAY_RULER);
                end
                [im_labels,last_label,bounding_rects,areas] = biggest_con_comps(im_binary,P.min_comp_size,P.flag_use_filled_area);
                
                is_black_ruler=false;
                is_white_lines=false;
                analyze_mode=true;
                
                 if ruler_success
                    if (strcmp(P.GRID_MEASURE_PAPER , 'ruler'))
                             [dpmm score] = analyze_dpi_from_ruler(im,full_im_labels ,im_labels,ruler_angle,is_black_ruler, is_white_lines,analyze_mode);
                             disp (['DPI by ruler=' , num2str(dpmm*25.4*resize_scale)]);
                    end
                 end
                
            end
            %%%
            for m=1:max(im_labels(:)) % iterates the components
                
                if P.TAKE_CONVEX_HULL % use convex hull of components
                    comp_mask = (im_labels==m);
                    stats = regionprops(double(comp_mask), 'ConvexHull');
                    convex_hull = stats.ConvexHull;
                    comp_mask = roipoly(comp_mask,convex_hull(:,1),convex_hull(:,2));
                    im_comp = extract_colored_component_by_label(im,comp_mask,true,P.comp_bndry);
                    comp_mask = extract_binary_component_by_label(comp_mask,true,P.comp_bndry);
                else % use precise components
                    comp_mask_all = (im_labels==m);
                    im_comp = extract_colored_component_by_label(im,comp_mask_all,true,P.comp_bndry);
                    comp_mask = extract_binary_component_by_label(comp_mask_all,true,P.comp_bndry);
                end
                if P.REMOVE_PAPER_THUMB
                    [im_comp comp_mask bb] = remove_paper_thumb(im,im_labels,m,pixels_taken_from_left,pixels_taken_from_right);
                end
                if P.REMOVE_PILLOWS
                    [im_comp comp_mask bb] = remove_pillows(im_comp);
                end
                if P.ANALYZE_WHITE_PAPER
                    im_binary_paper1 = segment_by_rgb_trained(im_comp,theta_fragment_white_paper,rho_fragment_white_paper);
                    im_binary_paper = comp_mask & im_binary_paper1;
                    size_thresh = 20000;
                    holes_percent_thresh = 0.01;
                    [im_labels_paper,paper_sizes,holes_percentages,bounding_rects_paper] = analyze_white_paper(im_binary_paper, size_thresh, ...
                        holes_percent_thresh);
                    min_side_rate_thresh = 0.1;
                    boundary_idxs = filter_paper_at_boundary(comp_mask,im_labels_paper,min_side_rate_thresh);
                    has_paper = double(~isempty(boundary_idxs) > 0);
                    im_boundary_paper = mark_components_by_labels(im_labels_paper,boundary_idxs);
                    im_binary_fragment = delete_im_binary2_from_im_binary1(comp_mask,im_boundary_paper);
                    [im_labels_comp,last_label, bounding_rects2] = biggest_con_comps(im_binary_fragment,0.03);
                    % update original bounding box
                    bounding_rects_original = bounding_rects;
                    bounding_rects(m,:) = [bounding_rects(m,1)+bounding_rects2(1),
                        bounding_rects(m,2)+bounding_rects2(2),
                        bounding_rects(m,1)+bounding_rects2(3),
                        bounding_rects(m,2)+bounding_rects2(4)];
                    if last_label>0
                        comp_mask = extract_binary_component_by_label(im_labels_comp,1,P.comp_bndry);
                        im_comp = extract_colored_component_by_label(im_comp,im_labels_comp,1,P.comp_bndry);
                    end
                end
                
                
                
                
                %                 if P.FLAG_FIND_RULER
                %                     %                 [coordinates, ruler_success, scale, ruler_H, n_ruler_points, n_match_points] = ...
                %                     %                     find_ruler_by_sift(im,im_ruler,P.ANALYZE_MODE,[],[],0,2,0.005,0.005,0.01);
                %                     %                 if ruler_success
                %                     %                     [ruler_label ruler_area] = find_ruler_label(im_labels,coordinates);
                %                     %                 end
                %                     if (ruler_success && n_match_points>3 && mean(ruler_label)>-1)
                %                         [im_labels2 comp_mask_without_ruler] = remove_cambridge_ruler(im_labels,ruler_label,ruler_area,coordinates,im,P.GRAY_RULER);
                %                         if isempty(comp_mask_without_ruler) % if the ruler took the whole component
                %                             if (ruler_label == m)
                % %                                 imwrite(im_comp,[P.OUTPUT_PATH_RULER,name,'.jpg']);
                % %                                 [dpi score] = measure_dpi_cambridge(im_comp);
                % % %                                  [dpi score] =
                % % %                                  measure_dpi_cambridge(imresize(im_comp,[size(im_comp,1)*resize_scale,size(im_comp,2)*resize_scale]),resize_scale);
                % %                                 results_image{end,3} = round(dpi);
                % %                                 results_image{end,4} = score;
                %                                 continue; % means this label includes is the ruler
                %                             end
                %                         else % the ruler is a part of the component
                %                             [im_comp,coor] = extract_colored_component_by_label(im,comp_mask_without_ruler,true,P.comp_bndry);
                %                             comp_mask = extract_binary_component_by_label(comp_mask_without_ruler,true,P.comp_bndry);
                %                         end
                %                     else
                %                         if (~ruler_success)
                %                             results_image{end,3} = -1; %couldn't find ruler
                %                         end
                %                     end
                % %                 else
                % %                     if (~ruler_success)
                % %                         results_image{end,3} = -1; %couldn't find ruler
                % %                     end
                %                 end
                % calculate best fit  bounding box.
                precision = 0.1;
                [bounding_box,angle_deg,width_bb,height_bb]  = best_fit_bounding_box(comp_mask,precision,P.ANALYZE_MODE);
                short_side = min(norm(bounding_box(:,1)-bounding_box(:,2)),norm(bounding_box(:,2)-bounding_box(:,3)));
                long_side = max(norm(bounding_box(:,1)-bounding_box(:,2)),norm(bounding_box(:,2)-bounding_box(:,3)));
                
                
                
                if (P.USE_PEGASUS)
                    try
                        [comp_binary1,pegasus_binarize_success] = binarize_by_pegasus(P,im_comp,'input1.bmp','output1.bmp');
                        comp_binary1 = erode_binary_im_by_mask(comp_binary1, comp_mask,floor(13));
                        
                    catch ME
                        getReport(ME)
                        disp('binarization failed once, trying again.');
                        [comp_binary1,binarize_success] = binarize_by_pegasus(P,im_comp,'input2.bmp','output2.bmp');
                    end
                end
                comp_binary2 = binarize_sauvola(im_comp,P.binarize_window_size,P.sauvola_k,P.sauvola_R,P.sauvola_C);
                comp_binary2 = erode_binary_im_by_mask(comp_binary2, comp_mask,floor(13));
                binarize_success=true;
                
                               
                if binarize_success
                    if (pegasus_binarize_success)
                        comp_binary = comp_binary1 | comp_binary2;
                    else
                        comp_binary = comp_binary2;
                    end
                    
                    if (P.BINARIZE_BIG)
                        %comp_binary1_big = erode_binary_im_by_mask(comp_binary1_big, comp_mask,13*P.RESIZE_SCALE);
                        comp_binary2_big = binarize_sauvola(im_comp_big,P.binarize_window_size,P.sauvola_k,P.sauvola_R,P.sauvola_C);
                        %comp_binary2_big = erode_binary_im_by_mask(comp_binary2_big, comp_mask,13*P.RESIZE_SCALE);
                        comp_binary_big = comp_binary1_big | comp_binary2_big;
                        %comp_binary_big = comp_binary1_big;
                    end
                    
                    
                    [lines_angle,num_lines,lines_heights,lines_centers,lines_score,skew_score,hough_struct, statistics] = ...
                        align_component2 (comp_binary,comp_mask,P.ANALYZE_MODE);%P.ANALYZE_MODE);
                    fprintf('Rotation Angle=%f\n',lines_angle);
                    % fixing rotation problem of 180 deg (Shahar's
                    % algorithm)
                    final_rot_angle = lines_angle;
                    if P.RUN_FLIP_DETECTION
                        descision = detect_rotation (imrotate(comp_binary,-lines_angle));
    
                        if (descision  < 0.3 & descision >-1)
                            final_rot_angle = lines_angle + 180;
                        else
                            final_rot_angle = lines_angle;
                        end
                    end
                    
                    fprintf('Final Rotation Angle=%f\n',final_rot_angle);
                    
                    lines_spaces = abs(diff(lines_centers));
                    
                    results_fragment{end+1,1} = fragment_id;
                    results_fragment{end,2} = name;
                    results_fragment{end,3} = areas(m);
                    results_fragment{end,6} = -lines_angle;
                    results_fragment{end,7} =  abs(final_rot_angle);
                    results_fragment{end,8} = lines_score;
                    results_fragment{end,11} = angle_deg;
                    results_fragment{end,12} = width_bb;
                    results_fragment{end,13} = height_bb;
                    results_fragment{end,14} = m;
                    
                    lines_angle = final_rot_angle;
                    [aligned_height, aligned_width] = calc_aligned_paper_length_axis(comp_mask,lines_angle);
                    
                    results_fragment{end,9} = aligned_width;
                    results_fragment{end,10} = aligned_height;
                end
                
                if P.FLAG_ANALYZE_BIFOLIO  % Here is text component
                    
                    local_analyze_mode = true;
                    
                    if local_analyze_mode
                        figure;
                        imshow(im_comp);
                    end
                    
                    results_fragment{end,23} = bounding_rects(m,2);
                    results_fragment{end,24} = bounding_rects(m,1);
                    results_fragment{end,25} = bounding_rects(m,4);
                    results_fragment{end,26} = bounding_rects(m,3);
                    
                    
                    [std_rows_height,std_text_profile,dist_median_mean_text_profile, noise_value,dist_mask_binary]= ...
                        analyze_image_full(comp_binary,comp_mask);
                    
                    results_fragment{end,28} = std_rows_height;
                    results_fragment{end,29} = std_text_profile;
                    results_fragment{end,30} = dist_median_mean_text_profile;
                    results_fragment{end,31} = noise_value;
                    results_fragment{end,32} = dist_mask_binary;
                    
                    % detect columns
                    if  (length(lines_heights) > 1)
                        [col_coor, columns_scores,crop_borders,col_hor_coor,binary_rot,mask_rot,fig_h1] = ...
                            analyze_columns_margins(comp_binary,comp_mask,lines_angle,lines_heights,local_analyze_mode);
                        crop_borders_str = [];
                        for t_i = 1:4
                            crop_borders_str = [crop_borders_str , int2str(crop_borders(t_i)) , ';'];
                        end
                        results_fragment{end,27} =crop_borders_str;
                    else
                        col_coor = [];
                        columns_scores = 0;
                        crop_borders = [];
                        col_hor_coor = [];
                        binary_rot = 1.-comp_binary;
                        mask_rot = comp_mask;
                    end
                    %saving image results
                    rot_comp_bb = imrotate(im_comp,-angle_deg,'crop');
                    
                    % To use white padding
                    min_val = min(im_comp(:));
                    im_comp_or = im_comp;
                    im_comp = im_comp - min_val+1;%sets the minimal value to +1 and not 0
                    
                    rot_comp = imrotate(im_comp,-lines_angle);
                    temp_mask = rot_comp ~= 0;
                    rot_comp(temp_mask) = rot_comp(temp_mask) + m;
                    rot_comp(~temp_mask)  = 255;
                    rot_comp(rot_comp>240) = 255;
                    
                    if (lines_angle > 0)
                        rot_comp = rot_comp(crop_borders(1):crop_borders(3),crop_borders(2):crop_borders(4),:);
                    end
                    
                    rot_comp_bb = imrotate(im_comp,-angle_deg,'crop');
                    temp_mask = rot_comp_bb ~= 0;
                    rot_comp_bb(temp_mask) = rot_comp_bb(temp_mask) + m;
                    rot_comp_bb(~temp_mask)  = 255;
                    rot_comp_bb(rot_comp_bb>240) = 255;
                    
                    imwrite(rot_comp_bb,[P.OUTPUT_PATH_BB_COMP,name,'_',int2str(m),'.jpg']);
                    imwrite(rot_comp,[P.OUTPUT_PATH_COMP,name,'_',int2str(m),'.jpg']);
                    %         imwrite(1.-binary_rot,[P.OUTPUT_PATH_BIN,name,'_',int2str(m),'.jpg']);
                    imwrite(1.-binary_rot,[P.OUTPUT_PATH_BIN,name,'_',int2str(m),'.bmp']);
                    imwrite(mask_rot,[P.OUTPUT_PATH_MASK,name,'_',int2str(m),'.bmp']);
                    if (P.BINARIZE_BIG)
                        comp_binary_big = imrotate(comp_binary_big,-final_rot_angle,'crop');
                        imwrite(comp_binary_big,[P.OUTPUT_PATH_BIN_ORIGINAL_SIZE ,name,'_',int2str(m),'.bmp']);
                    end
                    
                    
                    
                    %                 in_points = [col_coor(1,1),col_hor_coor(1,1);col_coor(1,1),col_hor_coor(2,1);col_coor(2,1),col_hor_coor(2,1);col_coor(2,1),col_hor_coor(1,1);col_coor(1,1),col_hor_coor(1,1)]';
                    %                 out_points = tform_comp_points(size(comp_binary),lines_angle,crop_borders,in_points);
                    
                    % recalc lines and plot them
                    im_comp = im_comp_or;
                    clear im_comp_or;
                    for col_num = 1:size(col_coor,2)
                        [lines_heights,lines_centers,lines_score,skew_score] = ...
                            analyze_aligned_lines(binary_rot,mask_rot,col_coor,col_hor_coor,col_num,150,local_analyze_mode);
                        
                        results_text{end+1,2} = fragment_id;
                        results_text{end,14} = filename;
                        results_text{end,15} = m;
                        results_text{end,3} = col_coor(2,col_num);
                        results_text{end,4} = col_coor(1,col_num);
                        results_text{end,5} = col_hor_coor(2,col_num);
                        results_text{end,6} = col_hor_coor(1,col_num);
                        results_text{end,7} = columns_scores(col_num);
                        results_text{end,8} = col_num;
                        results_text{end,9} = length(lines_centers);
                        results_text{end,10} = lines_score;
                        results_text{end,11} = mean(lines_heights);
                        lines_centers_str = [];
                        lines_heights_str = [];
                        for l_i = 1:length(lines_heights)
                            lines_centers_str  = [lines_centers_str , int2str(lines_centers(l_i)) , ';'];
                            lines_heights_str  = [lines_heights_str , int2str(lines_heights(l_i)) , ';'];
                        end
                        results_text{end,12} = lines_centers_str;
                        results_text{end,13} = lines_heights_str;
                    end
                    
                    % analyse Bfolio  only for 2 columns
                    % we might need to change this
                    if size(col_coor,2) == 2
                        try
                            [hough_score,length_score,separator_line,fig_handle]  = analyze_bifolio_midzone(im_comp,lines_angle,crop_borders,col_coor,[],[],local_analyze_mode);
                            figure(fig_h1)
                            plot(separator_line(1,:),separator_line(2,:),'g','LineWidth',2)
                            bifolio_scores(n,1) = hough_score;
                            bifolio_scores(n,2) = length_score;
                            
                            results_fragment{end,15} = separator_line(1.1);
                            results_fragment{end,16} = separator_line(2,1);
                            results_fragment{end,17} = separator_line(1,2);
                            results_fragment{end,18} = separator_line(2,2);
                            results_fragment{end,19} = hough_score;
                            results_fragment{end,20} = length_score;
                        catch ME
                            hough_score = -inf;
                            length_score = -inf;
                        end
                    end
                    cols_detection((n-1)*3+(1:2),1:size(col_coor,2)) = col_coor;
                    cols_detection((n-1)*3+3,1:size(col_coor,2)) = columns_scores;
                    if local_analyze_mode
                        if (exist('fig_h1','var'))
                            figure(fig_h1)
                            xlabel(num2str(columns_scores));
                            F = getframe(gcf);
                            [temp,filename_no_path] = fileparts(filename);
                        end
                        %                     imwrite(F.cdata,[P.OUTPUT_IMG_PATH,num2str(n,'%03.0f'),'_',filename_no_path,'_cols.bmp'],'bmp');
                        %                     save(['results_summary_',time_str,'.mat'],'results_summary');
                    end
                end
                %close all
                fragment_id = fragment_id + 1;
            end % iterates fragments
        end
        if (~strcmp(results_image{end,10},'Y'))
            results_image{end,10} = 'Done';
        end
        save('results_image.mat','results_image');
        save('results_fragment.mat','results_fragment');
        save('results_text.mat','results_text');
        save('results_log.mat','results_log');
        
        xlswrite(fullfile(filepath,[fname,'_resuls_image.xlsx']),results_image);
        xlswrite(fullfile(filepath,[fname,'_results_fragment.xlsx']),results_fragment);
        xlswrite(fullfile(filepath,[fname,'_results_text.xlsx']),results_text);
        xlswrite(fullfile(filepath,[fname,'_results_log.xlsx']),results_log);
        
    catch exception
        results_image{end,10} = 'Y';
        results_log (end+1,1:2) = {filename,[exception.identifier ,'  line:',int2str(exception.stack(max(1,end),1).line)]};
        disp('ERROR batch segmentation FAILED.');
         xlswrite('resuls_image.xlsx',results_image);
        xlswrite('results_fragment.xlsx',results_fragment);
        xlswrite('results_text.xlsx',results_text);
        xlswrite('results_log.xlsx',results_log);
        continue;
    end
end
save('results_image.mat','results_image');
save('results_fragment.mat','results_fragment');
save('results_text.mat','results_text');
save('results_log.mat','results_log');
disp('batch segmentation DONE.');

% process the filename to the format of the bi-folio excel file.
    function   filename_to_search = process_filename_to_bi_folio_excel_format(filename)
        filename_to_search = filename(1:end-4);
        underline_idx = find(filename_to_search == '_');
        filename_to_search = [filename_to_search(1:underline_idx-1),'_',filename_to_search(underline_idx:end)];
        dots_idxs = filename_to_search=='.';
        filename_to_search(dots_idxs) = '_';
        
        function current_bifolio_flags = read_bifolio_flags_by_filenames ...
                (filenames_file,bi_folio_xls_filename,bi_folio_xls_sheet)
            
            s = load(filenames_file);
            filenames = s.filenames;
            n_images = length(filenames);
            
            [num,txt] = xlsread(bi_folio_xls_filename,bi_folio_xls_sheet);
            bi_folio_filenames = txt(2:end,3);
            bi_folio_flags = num(1:end,1);
            current_bifolio_flags = zeros(n_images,1); % to hold the documentation and predictions of bifolio or folio
            % 0 is unknown or both bifolio and folio
            % 1 is folio
            % 2 is bi-folio
            
            for n = 1:n_images
                filename = filenames{n};
                bifolio_list_idx = find(strcmp(bi_folio_filenames,filename(1:end-4)));
                if length(bifolio_list_idx) ~= 1
                    filename_to_search = process_filename_to_bi_folio_excel_format(filename);
                    bifolio_list_idx = find(strcmp(bi_folio_filenames,filename_to_search));
                    if length(bifolio_list_idx) ~= 1
                        current_bifolio_flags(n) = -1; %meaning no documentation
                    else
                        current_bifolio_flags(n) = bi_folio_flags(bifolio_list_idx);
                    end
                else
                end
            end
            current_bifolio_flags(n) = bi_folio_flags(bifolio_list_idx);
        end
    end
end
function rotate_angle = limit_rotation(lines_angle,rotation_limit_angle)
% assumes the image is at about the correct rotation and limits the
% rotation to less than 45 degrees. otherwise doesn't rotate at all.
if abs(lines_angle) < rotation_limit_angle
    rotate_angle = -lines_angle;
elseif (180-abs(lines_angle)) < rotation_limit_angle
    rotate_angle = 180-lines_angle;
else
    rotate_angle = 0;
end
end
