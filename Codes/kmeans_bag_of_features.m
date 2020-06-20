clc;
clear;

%% Selecting 300000 descriptors at random
desc = readmatrix('descriptors_harris_t_hof_cslbp_mbh_yolo.csv');
desc = desc(:,1:520); % while saving the descriptors, extra columns are created. To remove those extra columns, this step is performed.
random_numbers = randsample((size(desc,1), 300000));
desc_random = desc(random_numbers,:);

%% Kmeans
[idx,clusters] = kmeans(desc_random,1000,'MaxIter',1000,'Display','iter'); % second parameter can be varied to experiment with different number of clusters 

%% Forming the Bag of Features
desc = readmatrix('descriptors_harris_t_hof_cslbp_mbh_yolo.csv');
features_count = readmatrix('video_feature_count_harris_t_hof_cslbp_mbh_yolo.csv');
[row,column] = size(features_count);
p = 1;
for q = 1:(row)
    tic
    disp(q)
    cnt = features_count(q,1);
    try
        video_descriptor = desc(p:p+cnt-1,:);
    catch
        disp('Index in position 1 exceeds array bounds');
    end
    video_descriptor = rmmissing(video_descriptor);
    disp(size(video_descriptor));
    hist_gram = zeros(1,1000);
    for i = 1:size(video_descriptor,1)
         min = 99999999;
         min_index = 1;
         for j = 1:size(clusters,1)
             dist = norm(video_descriptor(i,:) - clusters(j,:));
             if dist<min
                 min = dist;
                 min_index = j;
             end
         end
         hist_gram(min_index) = hist_gram(min_index) + 1;
     end
     hist_gram = cat(2,hist_gram,features_count(q,3));
     dlmwrite('bof_dataset.csv',hist_gram,'-append','delimiter',',');
     p = p + cnt;
     toc
end

