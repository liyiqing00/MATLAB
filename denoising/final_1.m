%最小二乗法と自動ピーク探し
%雑音除去-->欠損修復-->雑音除去
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
p = 5; % 画像パッチ。奇数。
bias = (p+1)/2;
Ob = reshape( Om(bias:Ix-bias+1,bias:Iy-bias+1)',[],1 );
% ベクトルbの未知の要素を表現するベクトルOcを生成
Oc = ~Ob; % ベクトルObの０と１を反転させたもの


% データ行列Xとベクトルbを画像から生成し、初期値として保存
[X0 b0] = make_X_b(z_fixed,p);

I_result=z_fixed; % 修復画像の初期値は欠損画像
a = ones(p*p-1,1)/(p*p-1); % 周りの画素値の平均値を計算する係数ベクトル

% データ行列Xとベクトルbを画像I_resultから生成
[X b] = make_X_b(I_result,p); 


% 係数ベクトルaを使ってbを計算
b = X*a;

% ベクトルbの未知の要素の値はそのままで、既知の要素の値を代入
b = b.*Oc + b0.*Ob; 

% ベクトルbから画像I_msを生成
I_result(bias:Ix-bias+1,bias:Iy-bias+1) = reshape(b, Iy-(bias-1)*2,Ix-(bias-1)*2)';

for i=0:300
    [X b] = make_X_b(I_result,p); 
    b = X*a;
    b = b.*Oc + b0.*Ob; 
    I_result(bias:Ix-bias+1,bias:Iy-bias+1) = reshape(b, Iy-(bias-1)*2,Ix-(bias-1)*2)'; 
end
figure
imshow(uint8(I_result))
title('修復結果')


%-------------------------------------------------------------------------
z=fftshift(fft2(I_result));
zlog=log(abs(z));
figure
mesh(zlog)
firstPeakX=floor(Iy/2)+1;
PeakY=floor(Ix/2)+1;

A=ones(Ix,Iy);
%A(:,firstPeakX)=0;
A(PeakY,:)=0;
A(PeakY,firstPeakX)=1;
z_fixed=abs(ifft2(fftshift(z.*A)));
figure
imshow(uint8(z_fixed))
title('ノイズ軽減後2')