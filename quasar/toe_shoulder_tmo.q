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
% {a:contrast,d:shoulder} shapes curve                                     %
% {b,c} anchors curve                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%// improved crosstalk –maintaining saturationfloat tonemappedMaximum; // 
%max(color.r, color.g, color.b)float3 ratio;.
%// color / tonemappedMaximumfloat crosstalk; 
%// controls amount of channel crosstalkfloat saturation; 
%// full tonal range saturation controlfloat crossSaturation; 
%// crosstalk saturation
%// wrap crosstalk in transformratio = pow(ratio, saturation / crossSaturation);
%ratio = lerp(ratio, white, pow(tonemappedMaximum, crosstalk));
%ratio = pow(ratio, crossSaturation);// final colorcolor = ratio * tonemappedMaximum;



%Update B and C values
function [] = updateBC(t:object)
    t.b= (-t.midIn^t.a + t.hdrMax^t.a*t.midOut)/(((t.hdrMax^t.a)^t.d-(t.midIn^t.a)^t.d) * t.midOut);
    t.c= ((t.hdrMax^t.a)^t.d*t.midIn^t.a-t.hdrMax^t.a *(t.midIn^t.a)^t.d*t.midOut)/(((t.hdrMax^t.a)^t.d-(t.midIn^t.a)^t.d)*t.midOut)
end

function [y:vec3] = __device__ clamp_values(x:vec3'unchecked,l:scalar,h:scalar)
    y=uninit(size(x))
    for i=0..2
        if x[i]>h
            y[i]=h
        elseif x[i]<l
            y[i]=l  
        else
            y[i]=x[i]
        endif  
    end
end


%Kernel to Apply tmo operator in parallel
function [y:cube] = tmo(x:cube,t:object)
    function []= __kernel__ tmo_kernel(x:cube'unchecked,y:cube'unchecked,a:scalar,b:scalar,c:scalar,d:scalar,pos:ivec2)
        {!kernel target="gpu"}
        input=x[pos[0],pos[1],0..2];
        output = (input.^a)./(((input.^a).^d).*b+c);
        output=clamp_values(output,0.0,1.0) %Clamp values
        syncthreads
        y[pos[0],pos[1],0..2]=output;
    end
    y=uninit(size(x))
    parallel_do(size(x,0..1),x,y,t.a,t.b,t.c,t.d,tmo_kernel)
end

%Kernel to Apply tmo operator to Separation of Max an RGB ratio in parllel
function [y:cube] = tmoRGBratio(x:cube,t:object)
    function []= __kernel__ tmo_kernel(x:cube'unchecked,y:cube'unchecked,a:scalar,b:scalar,c:scalar,d:scalar,pos:ivec2)
        {!kernel target="gpu"}
        input=x[pos[0],pos[1],0..2];
        
        %Aply Separation of Max an RGB ratio
        peak=max(input);
        ratio=input/peak;
        peak=(peak.^a)./(((peak.^a).^d).*b+c);
        output=peak*ratio;
        
        output=clamp_values(output,0.0,1.0) %Clamp values
        syncthreads
        y[pos[0],pos[1],0..2]=output;
    end
    y=uninit(size(x))
    parallel_do(size(x,0..1),x,y,t.a,t.b,t.c,t.d,tmo_kernel)
end

function [] = main()
    frm = form("TMO")
    frm.width = 600
    frm.height = 800
    frm.center()

    tmo_params = object()
    % Derfault params
    tmo_params.a= 1.24 % Contrast
    tmo_params.d = 0.90  % Shoulder
    tmo_params.midIn=1.003;
    tmo_params.midOut=0.18;
    tmo_params.hdrMax=64.0; %HDR Max value default (in image)
    updateBC(tmo_params);
     
    % Sttutgart files
    % 18 stops
    EV_d_in=-5;
    EV_b_in=12;
    
    % Color test
    img_file = "F:/Stuttgart/hdr_testimage/hdr_testimage_001033.exr";
        
    img = exrread(img_file).data;
    img=Alexa2sRGB(img,0) %Linear sRGB middle gray in 0.18
    
    %Remove bad data
    img=(img>=tmo_params.midIn*2^EV_d_in-1).*img;
    img=(img<=tmo_params.midIn*2^EV_b_in).*img;

    %Fix HDR Max from file
    tmo_params.hdrMax = tmo_params.midIn*2^EV_b_in-1;

    %Sliders
    slider_a =       frm.add_slider("Contrast(a):",tmo_params.a,0,10.0)
    slider_d =       frm.add_slider("Shoulder(d):",tmo_params.d,0,10.0)
    slider_midIn =   frm.add_slider("Mid In     :",tmo_params.midIn,0,2.0)
    slider_midOut =  frm.add_slider("Mid Out    :",tmo_params.midOut,0,2.0)
    params_display = frm.add_display()
    
    
    %Conrast and shoulder ajustment
    slider_a.onchange.add(()-> (tmo_params.a = slider_a.value;
                                updateBC(tmo_params)));      
                                
    slider_d.onchange.add(()-> (tmo_params.d = slider_d.value;
                                updateBC(tmo_params)));      

    %Using mid-level mapping to adjust brightness pre-tonemappingkeeps contrast and saturation consistent 
    slider_midIn.onchange.add(()-> (tmo_params.midIn = slider_midIn.value;
                                updateBC(tmo_params)));          

    slider_midOut.onchange.add(()-> (tmo_params.midOut = slider_midOut.value;
                                updateBC(tmo_params)));      

    % To check the curve                            
    x = 0.1..1..0.18*2^12; %0 and maximun value of Stuttgart files 12stops
    y=zeros(size(x));
    hold("on")  
    img_tmo:cube=zeros(size(img))
    % Compute the block size of the filter
    
    while !frm.closed()
       y=tmoRGBratio(x,tmo_params);
       img_tmo=tmoRGBratio(img,tmo_params);
       fig=hdr_imshow(img_tmo,[0,1]); 
       f:qplot= params_display.plot(x,y);
       pause(0.01)
    end

end