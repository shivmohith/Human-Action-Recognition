clc;
clear all;

%% Load the yoloml mat file which contains the yolo network
if exist('yoloml') ~= 1
    disp('loading modified network')
    s = load('yoloml.mat');
end

nei_len = 31; % Neighbourhood size
video_dataset_path = 'KTH_dataset_2'; % Path for the dataset
video_dataset = dir(fullfile(video_dataset_path,'*')); 
sub_folders = setdiff({video_dataset([video_dataset.isdir]).name},{'.','..'});
video_feature_count =[];
%% Loop through the folders
for sf = 1:numel(sub_folders)
    sub_folder = dir(fullfile(video_dataset_path,sub_folders{sf},'*')); % improve by specifying the file extension.
    all_files_in_subfolder = {sub_folder(~[sub_folder.isdir]).name}; % files in subfolder
    
    %% Loop through the files(Videos) in each folder
    for f = 1:numel(all_files_in_subfolder)
        frame_no = 0; % To keep track of the number of frames
        disp(f);
        video_path = fullfile(video_dataset_path,sub_folders{sf},all_files_in_subfolder{f});
        v = VideoReader(video_path); % Read the video
        duration = v.Duration;
        total_frames = (duration * v.FrameRate);
        cnt = 0;
        disp('whole video');
        tic
        while (total_frames - frame_no) >= 15
                %cnt = cnt + 1;
                cuboids = zeros(32,32,1,1); % To store the 32x32x15 cuboid 
                prev_frame = readFrame(v); % First frame of a 15-frame set
                frame_no = frame_no + 1; 
                bbox =  yolo_fun(prev_frame,s.yoloml);
                %% Read frame until a bounding box is avaialable
                while(isempty(bbox))
                     if((total_frames - frame_no) < 15)
                        disp('break');
                        break;
                     end
                     prev_frame = readFrame(v);
                     frame_no = frame_no+1;
                     bbox =  yolo_fun(prev_frame,s.yoloml);
                end
                if((total_frames - frame_no) < 15)
                    disp('break');
                    break;
                end 
                bbox(bbox < 1) = 1;
                bbox = abs(bbox);
                if (bbox(3) + bbox(1)) > 448
                      bbox(3) = 448 - bbox(1);
                end
                if (bbox(4) + bbox(2)) > 448
                      bbox(4) = 448 - bbox(2);
                end
                prev_features = detectHarrisFeatures(imresize(rgb2gray(prev_frame),[448 448]),'ROI',bbox(1,:));
                
                %% Read frames until you get descriptor points
                while(prev_features.Count == 0)
                    prev_frame = readFrame(v); % First frame of a 15-frame set
                    frame_no = frame_no + 1;
                    bbox =  yolo_fun(prev_frame,s.yoloml);
                    while(isempty(bbox))
                         if((total_frames - frame_no) < 15)
                            disp('break1');
                            break;
                         end
                         prev_frame = readFrame(v);
                         frame_no = frame_no+1;
                         bbox =  yolo_fun(prev_frame,s.yoloml);
                    end
                    if((total_frames - frame_no) < 15)
                        disp('break');
                        break;
                    else
                        bbox(bbox < 1) = 1;
                        bbox = abs(bbox);
                        if (bbox(3) + bbox(1)) > 448
                            bbox(3) = 448 - bbox(1);
                        end
                        if (bbox(4) + bbox(2)) > 448
                            bbox(4) = 448 - bbox(2);
                        end
                        prev_features = detectHarrisFeatures(imresize(rgb2gray(prev_frame),[448 448]),'ROI',bbox(1,:));
                    end
                end
                if((total_frames - frame_no) < 15)
                        disp('break');
                        break;
                end
                cnt = cnt + prev_features.Count;
                tracker = vision.PointTracker(); 
                initialize(tracker,prev_features.Location,imresize(rgb2gray(prev_frame),[448 448])); % Initializing KLT Tracker
                prev_points = prev_features.Location; % Storing the locations
                prev_points = abs(round(prev_points));
                prev_points(prev_points==0) = 1;
                
                prev_frame_padded = padarray(imresize(rgb2gray(prev_frame), [448 448]),[16 16],0,'both');  % Padding zeros
                [num_of_xy,xy] = size(prev_features.Location);
                xy_points = zeros(num_of_xy,2);
                xy_points(:,:,1) = prev_features.Location; % xy_points stores the location of the feature points of each frame of a 15-frame set
                t = 1;
                for k = 1:size(prev_points,1)
                     x = prev_points(k,1);
                     y = prev_points(k,2);
                     cuboids(:,:,t,k) = prev_frame_padded(x : x+nei_len , y : y+nei_len);
                end 
                t = t + 1;
                frame_len = 14;
                
                %% Now track the points using KLT tracker
                while frame_len > 0
                    curr_frame = readFrame(v); % Reading the consecutive frame
                    frame_no = frame_no + 1;
                    curr_frame = imresize(rgb2gray(curr_frame),[448 448]);
                    [curr_points,validity] = tracker(curr_frame);
                    prev_points = curr_points; % Current points become the previous points for the next iteration 
                    %prev_frame = curr_frame; % Current frame becomes the previous frame for the next iteration
                    frame_len = frame_len - 1;
                    xy_points(:,:,t) = curr_points;

                    %% Cubes 32x32
                    curr_frame_padded = padarray(curr_frame,[16 16],0,'both');  % Padding zeros
                    curr_points = abs(round(curr_points));
                    curr_points(curr_points==0) = 1;
                    
                    %% The following is done to make sure all the tracked points are within the frame size and extracting the 32x32 neighbourhood of a feature point
                    for k = 1:size(curr_points,1)
                        x = curr_points(k,2);
                        if(x > size(curr_frame,1))
                            x = size(curr_frame,1);
                        end
                        y = curr_points(k,1);
                        if(y > size(curr_frame,2))
                            y = size(curr_frame,2);
                        end
                        cuboids(:,:,t,k) = curr_frame_padded(x : x+nei_len , y : y+nei_len);
                    end
                    %%
                    t = t + 1;   
                end
                xy_points_displacement = displacement(xy_points);
                
                %% Parallel computing - To get the descriptors
                parfor i = 1:num_of_xy
                    temp = [];
                    temp = cat(2,temp,normalize(reshape(xy_points_displacement(i,:,:),[1 28]),'norm',2));
                    temp = cat(2,temp,normalize(hof_descriptor(cuboids(:,:,:,i)),'norm',2));
                    %temp = cat(2,temp,normalize(hog_descriptor(cuboids(:,:,:,i)),'norm',2));
                    temp = cat(2,temp,normalize(cslbp_descriptor(cuboids(:,:,:,i)),'norm',2));
                    %temp = cat(2,temp,normalize(xcslbp_descriptor(cuboids(:,:,:,i)),'norm',2));
                    temp = cat(2,temp,normalize(mbhx_descriptor(cuboids(:,:,:,i)),'norm',2));
                    temp = cat(2,temp,normalize(mbhy_descriptor(cuboids(:,:,:,i)),'norm',2));
                    %temp = cat(2,temp,sf);
                    dlmwrite('descriptors_harris_t_hof_cslbp_mbh_yolo.csv',temp,'-append','delimiter',',','precision',4); % Storing the descriptors in a csv file
                end
        %disp(total_frames - frame_no);
        end
        video_feature_count =[];
        video_feature_count = cat(2,video_feature_count,cnt);
        video_feature_count = cat(2,video_feature_count,f);
        video_feature_count = cat(2,video_feature_count,sf);
        
        dlmwrite('video_feature_count_harris_t_hof_cslbp_mbh_yolo.csv',video_feature_count,'-append','delimiter',',','precision',4);
        toc
    end
    
end



function single_bbox = yolo_fun(image,yoloml)


probThresh = 0.08;
iouThresh = 0.1;   
        
image = single(imresize(image,[448 448]))/255;
classLabels = ["aeroplane",	"bicycle",	"bird"	,"boat",	"bottle"	,"bus"	,"car",...
    "cat",	"chair"	,"cow"	,"diningtable"	,"dog"	,"horse",	"motorbike",	"person",	"pottedplant",...
    "sheep",	"sofa",	"train",	"tvmonitor"];

out = predict(yoloml,image,'ExecutionEnvironment','gpu');

probThresh = 0.10;


class = out(1:980);
boxProbs = out(981:1078);
boxDims = out(1079:1470);

outArray = zeros(7,7,30);
for j = 0:6
    for i = 0:6
        outArray(i+1,j+1,1:20) = class(i*20*7+j*20+1:i*20*7+j*20+20);
        outArray(i+1,j+1,21:22) = boxProbs(i*2*7+j*2+1:i*2*7+j*2+2);
        outArray(i+1,j+1,23:30) = boxDims(i*8*7+j*8+1:i*8*7+j*8+8);
    end
end

[cellProb, cellIndex] = max(outArray(:,:,21:22),[],3);
contain = max(outArray(:,:,21:22),[],3)>probThresh;


[classMax,classMaxIndex] = max(outArray(:,:,1:20),[],3);

counter = 0;
for i = 1:7
    for j = 1:7
        if contain(i,j) == 1
            counter = counter+1;
            
            x = outArray(i,j,22+1+(cellIndex(i,j)-1)*4);
            y = outArray(i,j,22+2+(cellIndex(i,j)-1)*4);
            
            w = (outArray(i,j,22+3+(cellIndex(i,j)-1)*4))^2;
            h = (outArray(i,j,22+4+(cellIndex(i,j)-1)*4))^2;
            
            %absolute values scaled to image size
            %                     wS = w*448;
            %                     hS = h*448;
            %                     xS = (j-1)*448/7+x*448/7-wS/2;
            %                     yS = (i-1)*448/7+y*448/7-hS/2;
            
            wS = w*448*1.5;
            hS = h*448*1.3;
            xS = ((j-1)*448/7+x*448/7-wS/2);
            yS = ((i-1)*448/7+y*448/7-hS/2);
            
            
            
            
            % this array will be used for drawing bounding boxes in Matlab
            boxes(counter).coords = [xS yS wS hS];
            
            %save cell indices in the structure
            boxes(counter).cellIndex = [i,j];
            
            %save classIndex to structure
            boxes(counter).classIndex = classMaxIndex(i,j);
            
            % save cell proability to structure
            boxes(counter).cellProb = cellProb(i,j);
            
            % put in a switch for non max which we will use later
            boxes(counter).nonMax = 1;
        end
    end
end

if exist('boxes')
    nonIntersectBoxes = yoloIntersect(classLabels, boxes,image);
    l = zeros(5,20);
    for i =1:length(nonIntersectBoxes)
        l(1:4,i) = nonIntersectBoxes(i).coords ;
        l(5,i) = i;
    end
    l = l(:,1:i);
    max_width = max(l(3,:));
    max_height = max(l(4,:));
    min_x = min(l(1,:));
    min_y = min(l(2,:));
%     image = insertObjectAnnotation(image,'rectangle',[min_x min_y max_width max_height],"single bounding box");
%     imshow(image)
    single_bbox = [min_x min_y max_width max_height];
else
    single_bbox = [];
end

clear boxes

end