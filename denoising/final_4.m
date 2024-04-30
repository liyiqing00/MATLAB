%最小二乗法とフィルタの修復効果の確認
%このプログラムでは、周期性ノイズを付加しなかった
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

figure
imshow(Ig)
title('元のグレースケール画像')
figure
imshow(uint8(Ims))
title('欠損画像')

%-----------------------修復開始--------------------------------------


%欠損修復
p = 5; % 画像パッチ。奇数。
bias = (p+1)/2;
Ob = reshape( Om(bias:Ix-bias+1,bias:Iy-bias+1)',[],1 );
% ベクトルbの未知の要素を表現するベクトルOcを生成
Oc = ~Ob; % ベクトルObの０と１を反転させたもの


% データ行列Xとベクトルbを画像から生成し、初期値として保存
[X0 b0] = make_X_b(Ims,p);

I_result=Ims; % 修復画像の初期値は欠損画像
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

x=3;
I_result1=filter2(fspecial('average',x),Ims)/255;
figure
imshow(double(I_result1))
title('test1')

I_result2=medfilt2(Ims,[3 3]);
figure
imshow(uint8(I_result2))
title('test2')

I_result3=medfilt2(Ims,[5 5]);
figure
imshow(uint8(I_result3))
title('test3')

I_result4=medfilt2(Ims,[7 7]);
figure
imshow(uint8(I_result4))
title('test4')
