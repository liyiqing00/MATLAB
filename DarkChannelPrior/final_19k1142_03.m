clear;

I=imread('the-fog-3738777_640.jpg');
%I=imread('fog-1535201_640.jpg');
figure;
imshow(I);
[h,w,~]=size(I);

w0=0.95;

%ダークチャンネル
for i=1:h
    for j=1:w
        dark(i,j)=min(I(i,j,:));
    end
end
figure;
imshow(dark);

%グレースケール画像とは違った
%gray=rgb2gray(I);
%figure; imshow(gray);

max_dark_channel=double(max(max(dark))); %空の輝度
dark_channel=double(dark);
t=1-w0*(dark_channel/max_dark_channel);
T=uint8(t*255);
figure; imshow(T);

I1=double(I);
output(:,:,1)=uint8((I1(:,:,1)-(1-t)*max_dark_channel)./t);
output(:,:,2)=uint8((I1(:,:,2)-(1-t)*max_dark_channel)./t);
output(:,:,3)=uint8((I1(:,:,3)-(1-t)*max_dark_channel)./t);
figure; imshow(output);