x=0.01:0.01:1;
y=dolby_pq_eotf(x);
yq=sim2_pq_eotf(x);

figure;
plot(x,y);
hold on;
plot(x,yq);


yn=log2(y);
mi=min(yn);
ma=max(yn);
mami=ma-mi;
yn=(yn-mi)/mami;
figure;
plot(x,yn);


