import "Quasar.UI.dll"

function [] = main()

    %Anchor curves
    b=0.18;
    c=0.18;
    %Shapes curves
    contrast=10;
    shoulder=20;

    x=[0.1..0.1..1];
    z=pow(x,contrast);
    y = z./(pow(z,shoulder)*b+c)

    %Draw the curve
    repeat
        plot(x,y);
    until !hold("on")
    
   
end
    