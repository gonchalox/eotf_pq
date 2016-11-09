%
%%Constants
%midIn=0.18;
%midOut=0.18;
%hdrMax=64.0;
%
%%Anchor curves to middle gray
%b=(-midIn^a + hdrMax^a*midOut)/(((hdrMax^a)^d-(midIn^a)^d) * midOut);
%c=((hdrMax^a)^d*midIn^a-hdrMax^a *(midIn^a)^d*midOut)/(((hdrMax^a)^d-(midIn^a)^d)*midOut)
%
%x=[0.1..0.01..1];
%
%tonemap = (x.^a)./(((x.^a).^d).*b+c);
%
%
%log_plot(x,tonemap);
import "Sim2HDR.dll"
import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "transfer_functions.q"


%Test SIM@ Monitor
function [] = main()
    max_val = 1; %6000 nits
    width=1920;
    height=1080;
    steps = 500;
    delta_nits=max_val/(steps-1)
    delta=width/steps
    im_gs = zeros(height,width);
    gamma=3.48;
 
    current_nits=0.0;
%    %Create gray gradient pattern
%    for i=0..steps-1
%        im_gs[:,floor(i*delta)..floor((i+1)*delta)-1]=current_nits;
%        current_nits+=delta_nits;
%    end
%    %LDR
%    imshow(im_gs*max_val,[0,max_val]); %LDR display decode to a linear space
%    %HDR
%    %HDR display needs a linearized space
%    hdr_imshow((im_gs.^2.61)*max_val, [0,max_val])
                        
    %Read image files
    %try: big_3_gray_scale_1.jpg  sunrise_flanker_by_billym12345-d8q0gc5.png
    im_file=float(imread("../gray_scale.png"));
    im_file=im_file./max(im_file)
    %LDR
    %imshow((im_file)*max_val,[0,max_val]); %LDR display decode to a linear space
    %HDR display needs a linearized space
    hdr_imshow((im_file.^gamma)*max_val,[0,1]);    
    
    
end

