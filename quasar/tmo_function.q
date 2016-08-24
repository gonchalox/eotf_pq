import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"
import "transfer_functions.q"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Toe, shoulder Tonemapper                                             %
% http://gpuopen.com/wp-content/uploads/2016/03/GdcVdrLottes.pdf       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = main()
    frm = form("TMO")
    frm.width = 600
    frm.height = 800
    frm.center()

   
    tmo_params = object()
    % Derfault params
    tmo_params.a= 1.3 % Contrast
    tmo_params.d = 0.995  % Shoulder
    tmo_params.midIn=0.18;
    tmo_params.midOut=0.18;
    tmo_params.hdrMax=0.18*2^14;
    updateBC(tmo_params);
     
    slider_a = frm.add_slider("a",tmo_params.a,0.0,10.0)
    slider_d = frm.add_slider("d",tmo_params.d,0.0,10.0)
    params_display = frm.add_display()
    
  
    slider_a.onchange.add(()-> (tmo_params.a = slider_a.value;)
                                updateBC(tmo_params));      
    
    slider_d.onchange.add(()-> (tmo_params.d = slider_d.value;)
                                updateBC(tmo_params));      
    
        
%%%%%%%%%%% Color test %%%%%%%%%%%%%%%%%
img_file = "F:/Stuttgart/hdr_testimage/hdr_testimage_001033.exr";
img = exrread(img_file).data;
img=Alexa2sRGB(img,EV) %Linear sRGB
img=(img>=0).*img;

x = [0.18*2^-7.5..2^-8..0.18*2^7.5];

    hold("on")  
    while !frm.closed()

        y = tmo(x,tmo_params);
        img_tmo=tmo(img,tmo_params);
        hdr_imshow(img_tmo,[0.18*2^-7.5,0.18*2^7.5]); %16 fstops
        f:qplot= params_display.plot(log2(x),log2(y));
        pause(0.01)
    end

end

% 0.18 middle gray
function [] = updateBC(t:object)
    t.b= (-t.midIn^t.a + t.hdrMax^t.a*t.midOut)/(((t.hdrMax^t.a)^t.d-(t.midIn^t.a)^t.d) * t.midOut);
    t.c= ((t.hdrMax^t.a)^t.d*t.midIn^t.a-t.hdrMax^t.a *(t.midIn^t.a)^t.d*t.midOut)/(((t.hdrMax^t.a)^t.d-(t.midIn^t.a)^t.d)*t.midOut)
end

function y=tmo(x,tmo_params)
    y = (x.^tmo_params.a)./(((x.^tmo_params.a).^tmo_params.d).*tmo_params.b+tmo_params.c);
end