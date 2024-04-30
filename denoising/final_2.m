%移動平均フィルタとメディアンフィルタと自動ピーク探し
%雑音除去-->平均移動フィルタ/メディアンフィルタ-->雑音除去

clear;

Ic=imread('branch-789619_640.jpg');
Ig=rgb2gray(Ic);
[Ix,Iy]=size(Ig);

%既知の画素の割合
r=0.8;

% 既知の画素の位置を表す行列Omの生成（ランダムに生成）
Om = make_Om(Ix,Iy,r);

% 欠損画像の生成
Ims = double(Ig).*Om;

%ノイズを付加
fs=640;
y=(0:1/fs:1-1/fs)';
randt=round(rand(1,1)*64);%ランダムに周期を生成する
stripe=repmat(uint8(16*sin(2*pi*(fs/randt)*y)),1,fs);
stripe=stripe';
stripe(Ix+1:Iy,:)=[];
%imtool(stripe)
sG=double(stripe)+double(Ims);
sG=uint8(sG/max(max(sG))*255);

figure
imshow(Ig)
title('元のグレースケール画像')
figure
imshow(uint8(Ims))
title('欠損画像')
figure
imshow(uint8(sG))
title('欠損ノイズ画像')

%-----------------------修復開始--------------------------------------

%ノイズ軽減
z=fftshift(fft2(sG));
zlog=log(abs(z));
firstPeakX=floor(Iy/2)+1;
PeakY=floor(Ix/2)+1;
zlog_Y=zlog(214,:); %zlog_Y=zlog(floor(Ix/2)+1);
[sort_zlogY,sort_ind]=sort(zlog_Y,'descend');
PeaksMap=imregionalmax(zlog); %この図ではY=214のところ

%第二の極値を探す
secondPeak_X1=findSecondPeak(PeaksMap,PeakY,sort_ind,2); %自動的にピークを探す
secondPeak_X2=2*firstPeakX-secondPeak_X1;

%figure
%mesh(zlog)
A=ones(Ix,Iy);
A(PeakY,secondPeak_X1)=0; A(PeakY,secondPeak_X2)=0;
z_fixed=abs(ifft2(fftshift(z.*A)));
figure
imshow(uint8(z_fixed))
title('ノイズ軽減後')

%欠損修復
x=3;
I_result1=filter2(fspecial('average',x),z_fixed)/255;
figure
imshow(double(I_result1))
title('test1')

I_result2=medfilt2(z_fixed,[3 3]);
figure
imshow(uint8(I_result2))
title('test2')

I_result3=medfilt2(z_fixed,[5 5]);
figure
imshow(uint8(I_result3))
title('test3')

I_result4=medfilt2(z_fixed,[7 7]);
figure
imshow(uint8(I_result4))
title('test4')

z=fftshift(fft2(I_result4));
zlog=log(abs(z));
figure
mesh(zlog)
firstPeakX=floor(Iy/2)+1;
PeakY=floor(Ix/2)+1;

%第二の極値を探す
secondPeak_X1=findSecondPeak(PeaksMap,PeakY,sort_ind,4); %自動的にピークを探す
secondPeak_X2=2*firstPeakX-secondPeak_X1;
secondPeak_X3=findSecondPeak(PeaksMap,PeakY,sort_ind,6); %自動的にピークを探す
secondPeak_X4=2*firstPeakX-secondPeak_X3;

A=ones(Ix,Iy);
%A(:,firstPeakX)=0;
A(PeakY,:)=0;
A(PeakY,firstPeakX)=1;
%A(PeakY,secondPeak_X1)=1; A(PeakY,secondPeak_X2)=1;
%A(PeakY,secondPeak_X3)=1; A(PeakY,secondPeak_X4)=1;
z_fixed=abs(ifft2(fftshift(z.*A)));
figure
imshow(uint8(z_fixed))
title('ノイズ軽減後2')