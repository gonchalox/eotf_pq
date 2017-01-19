%%%%%%%%%%%%%%%%%%%%%5%%%%%%%%%%%%%%%%%%%%%%%%
% Alexa to sRGB                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexa color gamut to sRGB (lineal)
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

%P3
function y = csdecodeP3(x) 
    p3xyx = [[0.4451698,  0.2094917,  0.0000000],
            [0.2771344,  0.7215953,  0.0470606],
            [0.1722827,  0.0689131,  0.9073554]] 
    y = reshape(reshape(x,[1080*1920,3])*p3xyx,[1080,1920,3]);
end

function y = csencodeP3(x) 
    xyzp3=[[2.7253940,  -0.7951680, 0.0412419],
           [-1.0180030, 1.6897321,  -0.0876390],
           [-0.4401632, 0.0226472,  1.1009294]]
    y = xyzp3*x
end

%SRGB    
function y = csdecodeSRGB(x) 
    srgbxyz = [[0.4124564, 0.2126729, 0.0193339],
               [0.3575761, 0.7151522, 0.1191920],
               [0.1804375, 0.0721750, 0.9503041]]
    y = srgbxyz * x;
end

function y = csencodeSRGB(x) 
    xyzsrgb = [[3.2404542, -0.9692660, 0.0556434],
               [-1.5371385, 1.8760108, -0.2040259],
               [-0.4985314, 0.0415560, 1.0572252]]
    y = reshape(reshape(x,[1080*1920,3])*xyzsrgb,[1080,1920,3]);
end

%Rec2020
function y = csdecodeRec2020(x) 
    rec2020xyz = [[0.6369580, 0.2627002, 0.0000000],
                  [0.1446169, 0.6779981, 0.0280727],
                  [0.1688810, 0.0593017, 1.0609851]]
    y = reshape(reshape(x,[1080*1920,3])*rec2020xyz,[1080,1920,3]);
end

function y = csencodeRec2020(x) 
    xyzrec2020 = [[1.7166512, -0.6666844, 0.0176399],
                  [-0.3556708, 1.6164812, 0.0157685],
                  [0.0176399, -0.0427706, 0.9421031]]
    y = reshape(reshape(x,[1080*1920,3])*xyzrec2020,[1080,1920,3]);
end

%Rec709
function y = csdecodeRec709(x) 
    srgbxyz = [[0.4124564, 0.2126729, 0.0193339],
               [0.3575761, 0.7151522, 0.1191920],
               [0.1804375, 0.0721750, 0.9503041]]
    y = reshape(reshape(x,[1080*1920,3])*srgbxyz,[1080,1920,3]);
end

function y = csencodeRec709(x) 
    xyzsrgb = [[3.2404542, -0.9692660, 0.0556434],
               [-1.5371385, 1.8760108, -0.2040259],
               [-0.4985314, 0.0415560, 1.0572252]]
    y = reshape(reshape(x,[1080*1920,3])*xyzsrgb,[1080,1920,3]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transfer functions                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%  sRGB Transfer functions %%%%%%%%%%
%Linearize
function l = sRGB_decode(x) 
    l = (x<=0.04045).*x./12.92 + (((x>0.04045).*x+0.055)/1.055).^2.4;
end  

%Delinearize
function v = sRGB_encode(x)
    v = ((x>0.0031308).*(1.055.*x.^(1/2.4)-0.055)+(x<=0.0031308).*12.92.*x);
end

%%%%%%%%%%% Gamma transfer function %%%%%%%%%%%%
%Linearize
function l = gamma_decode(v,gamma)
    l= v.^gamma;
end

%Delinearize 
function v = gamma_encode(l,gamma) 
    v = (l.^(1.0 / gamma));
end

%%%%%%%%% Rec.709 transfer function %%%%%%%%%%%%
a = 0.099;
%Linearize
function l=rec709_decode(v) 
    l=(((v < 0.081).*v / 4.5)+ (v >= 0.081).*(((v + a) / (1.0 + a)).^(1 / 0.45)))
end

%Delinearize
function v=rec709_encode(l) 
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

%%%%%%%%%%% PQ Transfer functions %%%%%%%%%%%%
m1=2610/4096*1/4
m2=2523/4096*128
c1=3424/4096
c2=2413/4096*32
c3=2392/4096*32
oneoverm1= 1/m1;
oneoverm2= 1/m2;
pqL=1.0

% Linearize
% PQ 2 Linear
function y = PQ_EOTF(x)
   y = ((x.^(1./m2)-c1)./(c2-c3*x.^(1/m2))).^(1/m1)
end

%Applies the PQ codeword-to-light electro-to-optical transfer function PHILIPS version to input data from EXR
function y = PQ_EOTF_PHILIPS(x)
     y=(x>0).*(((25.^x-1)/(25-1)).^2.4)+(x<=0).*0;
end
    
function y = PQ_OETF_PHILIPS(x)    
    b=0.0001812
    a=1.00622
    r=25
    y=(x<b).*log(35.445*x*(r-1)+1)/log(r)+(x>=b).*log((a*x.^0.508-(a-1))*(r-1)+1)/log(r)
end
    
function [] = main()
    x=0..0.001..1
    y=PQ_OETF_PHILIPS(x)
    plot(x,y)
end

%LMS
     
