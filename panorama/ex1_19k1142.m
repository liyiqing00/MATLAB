clear;
%resampling処理まで終わった
%次はチャレンジ課題

%画像の読み込みと中心位置
I = imread('PICT0016.jpg');
[h,w,~]=size(I);
%imtool(I)
Ox=w/2; %横
Oy=h/2; %縦
center=[Ox Oy];

Ig=rgb2gray(I);

%画像を二値化する
BW=imbinarize(Ig);
BW2=~BW;
%imtool(BW)

%ラプラシアンフィルタをかける(絶対値を取る)
H=fspecial('laplacian');
Ih=imfilter(BW,H);
%imtool(Ih)

%グレースケール画像とのANDをとる
img=Ig & Ih;
imtool(img) 

%imgで円周を計算
[col row]=find(img); %colは上から下、rowは左から右
%<1632,>1224
j=1;
pos=zeros(1,3);
for i=1:length(col)
    cal_norm=norm(center-[col(i),row(i)]);
    if cal_norm<=785 && cal_norm>=100 %実験を繰り返して迫った結果
    %if 880<=col(i) && col(i)<=2400 && 2000>=row(i) && row(i)>=1224 && cal_norm<=1000
        pos(j,1)=col(i);
        pos(j,2)=row(i);
        pos(j,3)=cal_norm;
        j=j+1;
    end
end
positions=sortrows(pos,-3);

start=3500;
n=500; %n個を取り出して計算
X=ones(n,3);
X(:,2)=2*positions(start:start+n-1,1);
X(:,3)=2*positions(start:start+n-1,2);
Y=ones(n,1);
for i=1:n
    Y(i,1)=(X(i,2)/2)^2+(X(i,3)/2)^2;
end
A=(inv(X'*X))*X'*Y;

%円心座標と大きい円周の半径
x0=round(A(2))+10; %10と15は円の位置のチェックによる修正
y0=round(A(3))+15;
r2=round(sqrt(A(1)+A(2)^2+A(3)^2));

%円心座標を既知とし、小さい円の半径を推測する
r1=170;

%円チェック
I_circle=insertShape(I,'filledcircle',[x0 y0 r2],'Color', {'red'},'Opacity',0.7);
imtool(I_circle)

I_circle2=insertShape(I,'filledcircle',[x0 y0 r1],'Color', {'blue'},'Opacity',0.7);
imtool(I_circle2)

%PhとPwは最後のパノラマ画像の高さと幅
Ph=r2-r1; 
Pw=4*Ph;
a=Pw/(2*pi);

%Resampling処理
P=zeros(Ph,Pw,3);
for v=1:Ph
    for u=1:Pw
        theta=u/a;
        r=v+r1;
        x=x0-r*sin(theta-45);
        y=y0+r*cos(theta-45);
        A=I(floor(y),floor(x),:);
        B=I(ceil(y),floor(x),:);
        C=I(ceil(y),ceil(x),:);
        D=I(floor(y),ceil(x),:);
        uu=x-floor(x);
        vv=y-floor(y);
        P(v,u,:)=(A*(1-uu)+B*uu)*(1-vv)+(D*(1-uu)+C*uu)*vv;
    end
end
P_output=flipud(P); %上下転置
imshow(uint8(P_output));
