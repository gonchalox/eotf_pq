import "Quasar.Video.dll"
import "inttypes.q"
import "Quasar.UI.dll"
import "Quasar.Runtime.dll"
import "Sim2HDR.dll"
import "exr_lib.dll"
import "Quasar.UI.dll"

function [] = main()
    path_exr="../05_4f_001269.exr"
    img = exrread(path_exr);
    hdr_imshow(img.data);
end

