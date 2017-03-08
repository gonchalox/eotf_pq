import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"

img:cube 

%Fix negative
function [y:cube] = fix_negative(x:cube,m:scalar)
    function []= __kernel__ fix_negative_kernel(x:cube'unchecked,y:cube'unchecked,m:scalar,pos:ivec2)
        {!kernel target="gpu"}
        if(x[pos[0],pos[1],0]<=0.0)
            y[pos[0],pos[1],0]=m
        endif
        if(x[pos[0],pos[1],1]<=0.0)
            y[pos[0],pos[1],1]=m
        endif
        if(x[pos[0],pos[1],2]<=0.0)
            y[pos[0],pos[1],2]=m
        endif   
        syncthreads 
    end
    y=uninit(size(x))
    parallel_do(size(x,0..1),x,y,m,fix_negative_kernel)
end


%Event
function [] = mouse_handler(pos)
    str=sprintf("R:%f G:%f B%f",img[pos[0],pos[1],0],img[pos[0],pos[1],1],img[pos[0],pos[1],2])
    print(str) 
end

%10stops
minEV=-4;
maxEV=6;    
    
i=158
repeat
    i=i+1
    exr_file_path = sprintf("F:/tearsofsteel/01_2a/out/itm_01_2a_000%03d.exr",i); %158
    %exr_file_path="C:/Users/ipi/Documents/gluzardo/eotf_pq/linear_tears_of_steal.exr"
    img = exrread(exr_file_path).data;
    
    
    %img=(img<0).*(0.18*2^minEV)+(img>=0).*img;
    %img=fix_negative(img,0.18*2^minEV);
    
    fig=hdr_imshow(img,[0.18*2^minEV,0.18*2^maxEV])
    fig.onSelectPoint.add(mouse_handler)
until !hold("on")




