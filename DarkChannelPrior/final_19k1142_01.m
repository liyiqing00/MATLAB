%final_19k1142_01と03で、違う計算方法で同じ画像に対して処理した。
%02で、コードを少し修正し、他の画像を処理した。
clear;

I=imread('the-fog-3738777_640.jpg');
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

N_imagesize=h*w;
N=floor(N_imagesize/1000);
P=zeros(N,2);
count=1;
for y=1:h
    for x=1:w
        if count==N+1
            break
        end
        if dark(y,x)==max(max(dark)) 
            P(count,1)=y;
            P(count,2)=x;
            count=count+1;
        end
    end
end

sum_r=sum(I(P(:,1),P(:,2),1),'all');
sum_g=sum(I(P(:,1),P(:,2),2),'all');
sum_b=sum(I(P(:,1),P(:,2),3),'all');
Ac=[sum_r,sum_g,sum_b]/(N*N);

Ic(:,:,1)=double(I(:,:,1))/Ac(1);
Ic(:,:,2)=double(I(:,:,2))/Ac(2);
Ic(:,:,3)=double(I(:,:,3))/Ac(3);
c=1;
for i=1:h
    for j=1:w
        test(c)=w0*min(min(Ic(i,j,:)));
        t(i,j)=1-w0*min(min(Ic(i,j,:)));
        c=c+1;
    end
end

T=uint8(t*255);
figure;imshow(T);

I1=double(I);
output(:,:,1)=uint8((I1(:,:,1)-(1-t)*mean(Ac))./t);
output(:,:,2)=uint8((I1(:,:,2)-(1-t)*mean(Ac))./t);
output(:,:,3)=uint8((I1(:,:,3)-(1-t)*mean(Ac))./t);
figure; imshow(output);
