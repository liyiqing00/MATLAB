%分類器
%カラー画像の修復
clear;

Ic=imread('branch-789619_640.jpg');
I_g=rgb2gray(Ic);
Ir=Ic(:,:,1);
Ig=Ic(:,:,2);
Ib=Ic(:,:,3);
[Ix,Iy]=size(I_g);

%既知の画素の割合
r=0.7;

% 既知の画素の位置を表す行列Omの生成（ランダムに生成）
Om = make_Om(Ix,Iy,r);

% 欠損画像の生成
Icms=double(Ic).*Om; %欠損の色画像

figure
imshow(I_g)
title('元のグレースケール画像')
figure
imshow(uint8(Icms))
title('欠損画像')

%-----------------------分類器--------------------------------------

%欠損修復
[h,w,~]=size(Icms);
%imtool(Icms)
bla=zeros(3,3,3); %欠損成分
leaf=Icms(202:211,288:300,:); %葉
br=Icms(282:285,383:386,:); %枝
sk=Icms(20:130,20:100,:); %空
wa=Icms(50:90,480:580,:); %壁
sz_bla=size(bla);
sz_leaf=size(leaf);
sz_br=size(br);
sz_sk=size(sk);
sz_wa=size(wa);
X_bla=reshape(double(bla),sz_bla(1)*sz_bla(2),sz_bla(3));
X_leaf=reshape(double(leaf),sz_leaf(1)*sz_leaf(2),sz_leaf(3));
X_br=reshape(double(br),sz_br(1)*sz_br(2),sz_br(3));
X_sk=reshape(double(sk),sz_sk(1)*sz_sk(2),sz_sk(3));
X_wa=reshape(double(wa),sz_wa(1)*sz_wa(2),sz_wa(3));
c_bla=cell(length(X_bla),1);
c_bla(:)=cellstr('black');
c_ice=cell(length(X_leaf),1);
c_ice(:)=cellstr('leaf');
c_mn=cell(length(X_br),1);
c_mn(:)=cellstr('branch');
c_sa=cell(length(X_sk),1);
c_sa(:)=cellstr('sky');
c_sk=cell(length(X_wa),1);
c_sk(:)=cellstr('wall');
Mdl=fitcknn([X_bla;X_leaf;X_br;X_sk;X_wa],[c_bla;c_ice;c_mn;c_sa;c_sk],'NumNeighbors',5);
X=reshape(double(Icms),h*w,3);
pr=predict(Mdl,X);
R=zeros(h,w);
R(strcmp(pr,'black'))=0;
R(strcmp(pr,'leaf'))=40;
R(strcmp(pr,'branch'))=80;
R(strcmp(pr,'sky'))=120;
R(strcmp(pr,'wall'))=160;
figure
imshow(uint8(R))
title('分類器')

%-------------------------------------修復-----------------------------------
around=zeros(3,3);
around_color=zeros(3,3,3);
cpR=R;
M=0;
n=0;
for x=2:h-1
    for y=2:w-1
        if R(x,y)==0
            while M==0
                n=n+1;
                around=R(x-n:x+n,y-n:y+n); %周囲の類別
                ar=reshape(around,[1 (n+2)^2]); %一行にする
                del_ar=find(ar==0); %類別が欠損成分のところ
                ar(del_ar)=[]; %欠損成分を削除する(しないと欠損成分が残る)
                [M,F]=mode(ar);              
            end
            around_color=Icms(x-n:x+n,y-n:y+n,:); %欠損色画像の周囲の画素
            cpR(x,y)=M; %頻度が一番大きい類別に分類する
            [find_x,find_y,~]=find(around==M);
            Mr=around_color(find_x,find_y,1);
            Mg=around_color(find_x,find_y,2);
            Mb=around_color(find_x,find_y,3);
            del_0=find(Mr==0);
            Mr(del_0)=[]; Mg(del_0)=[]; Mb(del_0)=[];
            Icms(x,y,1)=mean(Mr); %平均値を計算する
            Icms(x,y,2)=mean(Mg);
            Icms(x,y,3)=mean(Mb);
        end
    end
end
figure
imshow(uint8(cpR))
title('分類器修復後グレースケール画像')
figure
imshow(uint8(Icms))
title('分類器修復後カラー画像')
            