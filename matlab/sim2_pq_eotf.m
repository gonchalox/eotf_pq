function [y] = sim2_pq_eotf(x)
   y=(x>0).*(((25.^x-1)/(25-1)).^2.4)+(x<=0).*0;
end

