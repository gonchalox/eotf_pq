import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"

%Applies the PQ codeword-to-light electro-to-optical transfer function to input data from EXR
function y = PQ_EOTF(x)
   %constants
   m1=2610/4096*1/4
   m2=2523/4096*128
   c1=3424/4096
   c2=2413/4096*32
   c3=2392/4096*32
   y = ((x.^(1./m2)-c1)./(c2-c3*x.^(1/m2))).^(1/m1)
end

% Alexa to sRGB linear convertion
function img_rgb = Alexa2sRGB(img_alexa)
   H = [[1.617523436306807,-0.070572740897816,-0.021101728042793],[-0.537286622188294,1.334613062330328,-0.226953875218266],[-0.080236814118512,-0.264040321432512,1.248055603261060]];
   img_rgb = reshape(reshape(img_alexa,[1080*1920,3])*H,[1080,1920,3]);
end

%Applies the PQ codeword-to-light electro-to-optical transfer function PHILIPS version to input data from EXR
function y =PQ_EOTF_PHILIPS(x)
     y=(x>0).*(((25.^x-1)/(25-1)).^2.4)+(x<=0).*0;
end

%Delinearize. Linear to not linear sRGB
function y = sRGB_delinearize(x)
    y=((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055)+(x<=0.0031308).*12.92.*x);
end

%linearize. Not Linear to linear sRGB
function y = sRGB_linearize(x) 
    y = (x<0).*0 + (x<=0.04045).*x./12.92 + (((x>0.04045).*x+0.055)/1.055).^2.4;
end                                      

%Returns hdr image to see in SIM2 screen from EXR image with Alexa Wide Gamut color encoding
function y = rawToSIM2(x)
%    sRGB_linear_img = Alexa2sRGB(img_raw.data); %Covert to sRGB linear
%    sRGB_nonlinear_img = sRGB_delinearize(sRGB_linear_img);
%    mi=min(sRGB_nonlinear_img);
%    ma=max(sRGB_nonlinear_img);
%    mami=ma-mi;
%    sRGB_nonlinear_img = ((sRGB_nonlinear_img+mi)./mami).^2.4; %REC709 Sim2 gamma correction
%    hdr_imshow(sRGB_nonlinear_img);
    y = sRGB_delinearize(Alexa2sRGB(x)); 
    mi=min(y);
    ma=max(y);
    mami=ma-mi;
    y = ((y+mi)./mami).^2.4; 
end

function [] = main()
    path_raw_exr="../hdr_testimage_001035.exr"
    path_exr="../test_pq_EOTF_5000nits.exr"
    %path_raw_exr =
   
   
    img = exrread(path_exr);
    img_raw = exrread(path_raw_exr);

    %%% SHOW IMAGE HDR PQ 500 NITS
    % Show pq HDR image PQ
    % Image has already correct gamut and OETF
    img_hdr_pq=PQ_EOTF(img.data) %Apply EOTF for inverse OETF 
    %TODO: BT.2020 to REC.709 conversion. This is BT.2020, but the monitor is REC.709.
    hdr_imshow(img_hdr_pq,[0,1]);

    %% SHOW RAW IMAGE
    % Alexa to sRGB (SIM@ monitor is >90% of SRGB color space) 
    sim2img=rawToSIM2(img_raw.data);
    hdr_imshow(sim2img,[0,1]);
end

