clear all;  
clc; 
close all

%% read the HSI data being processed

a = dir;   
filename_path = a.folder;     
filename_path = strcat(filename_path,'\');
name_HSI = 'AVIRIS_WTC';     

filename = strcat(filename_path,name_HSI,'.mat');

load(filename);

X_cube = data;
clear('data');
[samples,lines,band_num]=size(X_cube);
pixel_num = samples * lines;

gt = map;
clear('map');

mask = squeeze(gt(:));   



%% Set the key parameters
 
N_topo = 140;   % the number of point sets in each topological space
per_ie = 0.4;   % the percentage used to set the threshold to constrain the information entropy


%% Perform anomaly detection with IEEPST
r_IEEPST = IEEPST(X_cube, N_topo, per_ie); 

%% illustrate detection results
figure;
subplot(121), imagesc(gt); axis image;   title('Ground Truth')     
subplot(122), imagesc(r_IEEPST); axis image;   title('Detection map of IEEPST')    

%% evaluate detection results with ROC
 
r_255 = squeeze(r_IEEPST(:));
figure;
AUC = ROC(mask,r_255,'r')       

