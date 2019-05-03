import "Quasar.Video.dll"
import "inttypes.q"

%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%
% Alexa to sRGB                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexa color space
function img_rgb = Alexa2sRGB(img_alexa,EV)
   %Absolute H
   H = [[1.617523436306807,-0.070572740897816,-0.021101728042793],[-0.537286622188294,1.334613062330328,-0.226953875218266],[-0.080236814118512,-0.264040321432512,1.248055603261060]];
   % log2(middle_gray)=log2(0.18)=2.47393118833241
   c=log2(0.18);
   img_rgb = reshape(reshape(img_alexa*(2^(EV-c)),[1080*1920,3])*H,[1080,1920,3]);
end

function img_rgb = Alexa2sRGB(img_alexa)
   %Absolute H
   H = [[1.617523436306807,-0.070572740897816,-0.021101728042793],[-0.537286622188294,1.334613062330328,-0.226953875218266],[-0.080236814118512,-0.264040321432512,1.248055603261060]];
   img_rgb = reshape(reshape(img_alexa,[1080*1920,3])*H,[1080,1920,3]);
end

%P3 color space
function y = P3ToXYZ(x,w,h) 
    p3xyx = [[0.4451698,  0.2094917,  0.0000000],
            [0.2771344,  0.7215953,  0.0470606],
            [0.1722827,  0.0689131,  0.9073554]] 
    y = reshape(reshape(x,[h*w,3])*p3xyx,[h,w,3]);
end

function y = XYZToP3(x) 
    xyzp3=[[2.7253940,  -0.7951680, 0.0412419],
           [-1.0180030, 1.6897321,  -0.0876390],
           [-0.4401632, 0.0226472,  1.1009294]]
    y = xyzp3*x
end


%Rec2020 color space
function y = Rec2020TosRGB(x)
    %Rec2020_2_sRGB=rec2020xyz*xyz2srgb
    Rec2020_2_sRGB = [[1.660491002108435, -0.124550474521591, -0.018150763354905],
                      [-0.587641138788550,  1.132899897125960, -0.100578898008007],
                      [-0.072849863319885, -0.008349422604369,  1.118729661362913]]

    [h,w,c] = size(x)
    assert(c==3)
    y = reshape(reshape(x*2^4,[h*w,c])*Rec2020_2_sRGB,[h,w,c]);
     
   
    
end

function y = Rec2020ToXYZ(x) 
    rec2020xyz = [[0.6369580, 0.2627002, 0.0000000],
                  [0.1446169, 0.6779981, 0.0280727],
                  [0.1688810, 0.0593017, 1.0609851]]
    y = reshape(reshape(x,[1080*1920,3])*rec2020xyz,[1080,1920,3]);
end

function y = XYZToRec2020(x) 
    xyzrec2020 = [[1.7166512, -0.6666844, 0.0176399],
                  [-0.3556708, 1.6164812, 0.0157685],
                  [0.0176399, -0.0427706, 0.9421031]]
    y = reshape(reshape(x,[1080*1920,3])*xyzrec2020,[1080,1920,3]);
end


function y = XYZTosRGB(x,w,h) 
    xyzsrgb = [[3.2404542, -0.9692660, 0.0556434],
               [-1.5371385, 1.8760108, -0.2040259],
               [-0.4985314, 0.0415560, 1.0572252]]
    y = reshape(reshape(x,[h*w,3])*xyzsrgb,[h,w,3]);
end




function y = sRGBToXYZ(x,w,h) 
    srgb2xyz=[[ 0.412456452846527, 0.212672874331474, 0.0193339046090841],
             [ 0.357576102018356, 0.715152263641357, 0.119192034006119],
             [ 0.180437475442886, 0.0721750035881996, 0.95030403137207]]
    y = reshape(reshape(x,[h*w,3])*srgb2xyz,[h,w,3]);
end

function y = rec709Torec2020(x,w,h)
    trans=transpose([[ 0.6274, 0.3293, 0.0433],
             [ 0.0691, 0.9195, 0.0114],
             [ 0.0164, 0.0880, 0.8956]])
             y = reshape(reshape(x,[h*w,3])*trans,[h,w,3]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transfer functions                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%  sRGB Transfer functions %%%%%%%%%%
%% Similar to use gamma encoding with a gamma value of 2.2
%x: RGB value no linear
function l = sRGB_decode(x) 
    l = (x<=0.04045).*x./12.92 + (((x>0.04045).*x+0.055)/1.055).^2.4;
end  

%Delinearize
%x: RGB value linear
function v = sRGB_encode(x)
    v = ((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055)+(x<=0.0031308).*12.92.*x);
end


%%%%%%%%%%% Gamma transfer function %%%%%%%%%%%%
%% Common values are gamma=2.2 and gamma=2.4
%Linearize
function l = gamma_decode(v,gamma)
    l= v.^gamma;
end

%Delinearize 
function v = gamma_encode(l,gamma) 
    v = (l.^(1.0 / gamma));
end

%%%%%%%%% Rec.709 transfer function %%%%%%%%%%%%
%% Similar to use a gamma encoding with a gamma value of 2.4
%% (Wikipedia) Rec. 709 is written as if it specifies the capture and transfer characteristics of HDTV encoding - 
%% that is, as if it were scene-referred. However, in practice it is output (display) referred with 
%% the convention of a 2.4-power function display 
%Linearize
function l=rec709_decode(v) 
    %l=(((v < 0.081).*v / 4.5)+ (v >= 0.081).*(((v + ac) / (1.0 + ac)).^(1 / 0.45)))
    l=(((v < 0.081).*v / 4.5)+ (v >= 0.081).*(((v + 0.099) / (1.099)).^(1 / 0.45)))
end

%Delinearize
function v=rec709_encode(l) 
    %v = ((l < 0.018).*(l*4.5) + (l>=0.018).* (1.099 * (l.^0.45)-0.099));
    v = ((l < 0.018).*(l*4.5) + (l>=0.018).* (1.099 * (l.^0.45)-0.099));
end

%%%%%%%%% LogC transfer function %%%%%%%%%%%%%%%
cut = 0.004201;
a = 200.0;
b = -0.729169;
c = 0.247190;
d = 0.385537;
e = 193.235573;
f = -0.662201;
g = e * cut + f;
%Linearize
function x = logcdecode(z) 
    x = (z > g).*((10.0.^(((z - d) / c) - b)) / a) + (z <= g).*((z - f) / e);
end

%Decode HLG (Linearize)
%x between 0 and 1
function y = PQ_EOTF_BT2100(x)    
    m1 = 0.1593017578125
    m2 = 78.84375
    c1 = 0.8359375 
    c2 = 18.8515625
    c3 = 18.6875 
    
    d = c2-c3*x.^(1/m2)
    ma = x.^(1./m2)-c1
    ma = (ma < 0)*0 + (ma>=0).*ma
    y = (ma./d).^(1/m1) 
end

% %%%%%%%%%%% PQ Transfer functions %%%%%%%%%%%%
m1=(2610/4096)*1/4
m2=(2523/4096)*128
c1=3424/4096
c2=(2413/4096)*32
c3=(2392/4096)*32
oneoverm1= 1/m1;
oneoverm2= 1/m2;
pqL=1.0

%Decoding PQ
% PQ 2 Linear
function y = PQ_EOTF(x)
   y = ((x.^(1./m2)-c1)./(c2-c3*x.^(oneoverm2))).^(oneoverm1)
end

function y = PQK_EOTF(x,k)
   y = k*((x.^(1./m2)-c1)./(c2-c3*x.^(1/m2))).^(1/m1)
end

%Coding 
function y = C(x)
   t = x.^m1
   y = ((c2 *t + c1)./(1.0 + c3 *t)).^m2;
end


%HLG PG
%Encode to HLG (Delinearize)
%x between 0 and 1
function y = PQ_OETF_HLG(x)    
    f=12
    E=x*12 %ARIB STD-B67 has a nominal range of 0 to 12.
    r=0.5
    a = 0.17883277
    b = 0.28466892
    c = 0.55991073
    y= (E<=1).*(r*sqrt(E)) + (E>1).*(a*log(E-b)+c)
end
     



%Decode HLG (Linearize)
%x between 0 and 1
function y = HLGdecode(x)    
    r=0.5
    a = 0.17883277
    b = 0.28466892
    c = 0.55991073
    
    y = ((x/r).^2).*(x<r)  +  (exp(x/2)+b).*(x>r)
    
end

%function [] = main()
%    x=linspace(0,1,65000)
%    y1 = rec709_decode(x)
%    y2=gamma_decode(x,2)
%    
%    plot(x, y1, "r") 
%    hold("on") 
%    plot(x, y2, "g") 
%    
%    
%end

