% Clear variables


%%% PARAMETERS %%
% Read from CSV file
exr_dir = '/media/gluzardo/Data/Stuttgart/carousel_fireworks/carousel_fireworks_01/';
out_dir = '/media/gluzardo/Data/SIM2_6000nits/carousel_fireworks/carousel_fireworks_01/';
ft=1;
lt=10;
fj=5;
border=11;
%%%%%%%%%%%%%%%%%
AlexaWideGamut2sRGB = [1.617523436306807  -0.070572740897816  -0.021101728042793;...
  -0.537286622188294   1.334613062330328  -0.226953875218266;...
  -0.080236814118512  -0.264040321432512   1.248055603261060];

% Add open-exr library 
addpath('/u/gluzardo/Documents/phd/openexr-matlab-master');
exr_files = dir(strcat(exr_dir,'*.exr'));

% Compute minimum and maximum over the whole EXR secuence
mi = 2^16-1;
ma = 0; 

disp('Get min and max from EXR files..');
for i=ft:lt %All files to normalize% Add open-exr library 
    im = exrread(strcat(exr_dir,exr_files(i).name));
    im = reshape(reshape(im,[],3)*AlexaWideGamut2sRGB,1080,1920,3);
    mi = min(mi,min(im(:)));
    ma = max(ma,max(im(:)));
end
mi=double(mi);
ma=double(ma);
mami= ma - mi;

disp('Creating joint histogram...');
for i=ft:fj:lt
      disp(strcat(strcat('Loading EXR:.. ',exr_files(i).name(1:end-4))));
      exr_image = double(exrread(strcat(exr_dir,exr_files(i).name)));
      
      exr_image = reshape(reshape(exr_image,[],3)*AlexaWideGamut2sRGB,1080,1920,3);
%       disp('EOTF PQ applying...');
%       
%       %exr_data=exr_image;
%       exr_data = (exr_image - mi)./mami;
%       %exr_pq = exr_data;
%       exr_pq= dolby_pq_eotf(exr_data);
% 
%       mapq=max(exr_pq(:));
%       mipq=min(exr_pq(:));
%       mamipq=mapq-mipq;
%       
%       %exr_pq = ((exr_pq-mipq)./mamipq)*6000;
     
      exrwrite(exr_image,strcat(strcat(out_dir,'pq_6000nits_'),exr_files(i).name)); 
end



