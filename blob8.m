clc
close all
clear all
%% Initialization

% video object to grab frame from live video
vidobj = imaq.VideoDevice('winvideo', 1);

% Blob object
H = vision.BlobAnalysis('MinimumBlobArea',1000,...
'MaximumCount',5);

% for inserting rectangle on the detected blob
shapeInserter = vision.ShapeInserter('BorderColor','Custom',...
'CustomBorderColor',[1 1 0] );

%for inserting tet on to the blob
textInserter = vision.TextInserter('Text', '* X:%6.2f, Y:%6.2f', ... 
'LocationSource', 'Input port', ...
'Color', [0 0 0],... 
'FontSize', 12);

cent = zeros(1,2);
thresh = 0.9;

% to display output video
thresholdvideo = vision.VideoPlayer;
rgbvideo = vision.VideoPlayer;
%% Image acquisition and image processing


for n=1:1500
rgbFrame = step(vidobj); % store one frame

rgbFrame = flipdim(rgbFrame,2); % mirror image of frame

I_threshold = (rgbFrame(:,:,1)>thresh); % thresholded image
imhist(double(rgbFrame(:,:,1)));
h = fspecial('average');

I_threshold = imfilter(I_threshold,h,'same');

[area,centroid, bbox] = step(H, I_threshold); % obtain area, centroid, blob parameters(x,y,w,h --(x,y)co-ordinate upper left corner w- width h- height)


rgb1 = step(shapeInserter, rgbFrame, bbox); % insert rectangle on detected blob on frame rgb1
       if(~isempty(centroid))               % there can be instances where there is no blob
       cent = centroid(1,:);
       end

rgb2 = step(textInserter, rgb1,cent,centroid ); % insert centroid of blob on frame rgb2, the frame included is rgb1, so the frame with blob rectangle is updated with text

step(thresholdvideo, I_threshold); % threshold video
step( rgbvideo,rgb2);% rgb video



end
%% Memroy releasing

% clearing memories
release(rgbvideo); 
release(thresholdvideo); 
release(vidobj);