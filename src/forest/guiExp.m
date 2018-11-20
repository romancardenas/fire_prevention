%% start
close all ; clear ; clc ;
%% load images

path = 'C:\Users\Mads\Documents\7.semester(E18)\02502 billedanalyse\opgave 8\DTUSignPhotos' ;


dimImages = [3024,4032,3] ;

Image = zeros(dimImages(1),dimImages(2),dimImages(3)) ;

figure()
j = 1 ;
for i=1:4
    totalPath = sprintf('%s/DTUSigns%03d.jpg',path, j);
    Image = imread(totalPath) ;
    subplot(2,2,i)
    imshow(Image) 
    colormap(gca, winter)
    j = j+2 ;
end

pause(2)

subplot(2,2,1)
imshow(Image)