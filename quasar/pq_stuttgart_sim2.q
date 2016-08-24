import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"
import "transfer_functions.q"


function [] = main()

    %%%%%%%%%%% Color test %%%%%%%%%%%%%%%%%
    folder_path = "F:/Stuttgart/hdr_testimage/";
    image_name_format="hdr_testimage_00%4d.exr";
    start_frame = 1033;


    %%%%% Wide gamut and moving lights %%%%%
    %    %Lightshow
    %    folder_path = "F:/Stuttgart/beerfest_lightshow/beerfest_lightshow_01/";
    %    image_name_format="beerfest_lightshow_01_00%4d.exr";
    %    start_frame = 1591;

    %    %Carousel
    %    folder_path = "F:/Stuttgart/carousel_fireworks/carousel_fireworks_03/";
    %    image_name_format="carousel_fireworks_03_000%3d.exr";
    %    start_frame = 348;    

    %%%%%%%%% High constrast skins %%%%%%%%%
    %    %Bistro
    %    folder_path = "F:/Stuttgart/bistro/bistro_02/";
    %    image_name_format="bistro_02_000%3d.exr";
    %    start_frame = 319;
    %
    %    %Poker full shot
    %    folder_path = "F:/Stuttgart/poker_fullshot/";
    %    image_name_format="poker_fullshot_000%3d.exr";
    %    start_frame = 370; 
    %    
  
    % Min and max values for display
    % SIM2 contrast from 16 to 17.5 f/stops
    % 16 stops fixed
    minEV=-5;
    maxEV=10;    
    EV=0; %Exposure value to display
 
    i=start_frame;
    repeat
        %Conver from Alexa to sRGB
        img_file_path = sprintf(folder_path+image_name_format,i);
        img = exrread(img_file_path); 
        % Converto to color space sRGG and EV, now 0.18 middle gray is 1.0
        y=Alexa2sRGB(img.data,EV) %Linear sRGB center in 1
        hdr_imshow(y,[2^-maxEV,2^maxEV]) %Center display 0.18 mid gray level
        i=i+1;0
    until !hold("on")

 
end



