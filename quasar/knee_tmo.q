import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"
import "transfer_functions.q"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Knee Tone Mapper                                                                 %
% Based on:                                                                        %
% https://software.intel.com/sites/default/files/m/e/7/6/0/f/37394-ToneMapping.pdf %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Knee function
function y=knee(x:cube,f:scalar)
    y = log(x*f+1.0)./f;
end

function y=knee(x:scalar,f:scalar)
    y = log(x*f+1.0)./f;end
end

%Find f
function f=findKneeF(x,y)
   f0 = 0.0;
   f1 = 100.0;

   while (knee(x, f1) > y)
     f0 = f1;
     f1 = f1 * 2.0;
   end

   for i=0..23
     f2 = (f0 + f1) * 0.5;
     y2 = knee (x, f2);

     if (y2 < y)
        f1 = f2;
     else
        f0 = f2;
     endif
   end 
   f = (f0 + f1) / 2.0;
end

% TMO function
% x = input signal
% kneeLow, KneeHigh = TMO params between 3.5 and 7
% g = Gamma
function y=tmo(x,tmo_params)
    kl = 2^tmo_params.kneeLow
    kh = 2^tmo_params.kneeHigh
    maxOut = 2^tmo_params.maxStopsImgOut
    f = findKneeF(kh-kl,maxOut-kl)
    print(f)
    y=(x<kl).*x + (x>=kl && x<=kh).*(kl+knee(x-kl,f))+(x>kh).*maxOut;
    y=y.^tmo_params.gamma
end



function [] = main()
    % Min and max values for display
    % SIM2 contrast from 16 to 17.5 f/stops
    % 16 stops fixed
    minEV=-5;
    maxEV=10;    
    
    % Sttutgart files
    % 18 stops
    EV_d_in=-5;
    EV_b_in=12;

    %Window    
    frm = form("TMO")
    frm.width = 600
    frm.height = 800
    frm.center()

    %Tmo Params   
    tmo_params = object()
    % Derfault params
    tmo_params.EV=5;
    tmo_params.gamma=1.0;
    tmo_params.kneeLow=-3;
    tmo_params.kneeHigh=maxEV;
    tmo_params.maxStopsImgIn=EV_b_in;
    tmo_params.maxStopsImgOut=maxEV;
    tmo_params.midGray=1;

 
    %Image to process
    % Color test
    img_file = "F:/Stuttgart/hdr_testimage/hdr_testimage_001033.exr";
    img_raw = exrread(img_file).data;
    
    %Sliders
    slider_EV = frm.add_slider("EV: ",tmo_params.EV,EV_d_in,EV_b_in)
    %slider_midGray = frm.add_slider("Middle Gray:",tmo_params.midGray,0,10)
    slider_kneeLow = frm.add_slider("knee Low:",tmo_params.kneeLow,-10,EV_b_in)
    slider_kneeHigh = frm.add_slider("Knee High:",tmo_params.kneeHigh,1,EV_b_in)
    slider_gamma = frm.add_slider("Gamma:",tmo_params.gamma,0.1,10)
    
    params_display = frm.add_display()
    
    %Sliders events
    slider_EV.onchange.add(()->  (tmo_params.EV = slider_EV.value;)); 
    
    slider_kneeLow.onchange.add(()->  (tmo_params.kneeLow = slider_kneeLow.value;)); 
         
    slider_kneeHigh.onchange.add(()-> (tmo_params.kneeHigh = slider_kneeHigh.value;));                                  
    
    slider_gamma.onchange.add(()->  (tmo_params.gamma = slider_gamma.value;)); 
       
    % To check the curve                            
    x = 0.1..1..2^EV_b_in; %0 and maximun value of Stuttgart files 12stops
    hold("on")  
    while !frm.closed()
       %Get sRGB with EV
       img=Alexa2sRGB(img_raw,tmo_params.EV) %Linear sRGB, middle gray in 0
       y = tmo(x,tmo_params);
       img_tmo=tmo(img,tmo_params);
       hdr_imshow(img_tmo,[2^-maxEV,2^maxEV]); 
       f:qplot= params_display.plot(x,y);
       pause(0.01)
    end

end
