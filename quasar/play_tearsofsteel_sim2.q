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

function [] = main() 
    i=158
    repeat
        i=i+1
        exr_file_path = sprintf("F:/tearsofsteel/01_2a/out/itm_01_2a_000%03d.exr",i); %158
        img = exrread(exr_file_path);
        imshow(img.data,[0,1])
    until !hold("on")
end

