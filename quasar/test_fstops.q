import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "Quasar.UI.dll"


function [] = main()
    testFStops(0.18); %middle gray
end


%Test fstops with the middle gray like input parameter
function [] = testFStops(middle_gray)
    middle_gray=1
    w=1920
    h=1080
    im_test = zeros(h,w);
    fstops=16  %SIM 2 better results experiments
    s=ceil(w/fstops)
    EV_b=ceil(fstops*0.55) %60% on high
    EV_d=fstops-EV_b-1 %Dark
    hq=floor(h/10);
    
    %Middle gray
    im_test[0..2*hq,:]=middle_gray;
    
    %Gray bars
    i=0;
    for e=-EV_d..EV_b
        im_test[2*hq..8*hq,i*s..(i+1)*s-1]=middle_gray*2^e; % middle gray
        i=i+1;
    end
    
    %Black and white
    im_test[8*hq..h,floor(w/2)..w]=middle_gray*2^EV_b;
    
    repeat
        hdr_imshow(im_test,[middle_gray*2^-EV_b,middle_gray*2^EV_b]) % to put de middle gray in the center of screen brigthess
        %hdr_imshow(1+0*im_test,[0,1]) % to put de middle gray in the center of screen brigthess
        %pause(10*1000/60)
        %hdr_imshow(0*im_test,[0,1]) % to put de middle gray in the center of screen brigthess
        %pause(1000-10*1000/60)
    until !hold("on")
    print(sprintf("Number of fstops: %d",fstops))
    print(sprintf("Showing image from -%d (Dark zone) to %d(Bright zone))",EV_d,EV_b))
end
