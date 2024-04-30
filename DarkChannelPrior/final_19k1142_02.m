clear;

%I=imread('wolves-1341881_640.jpg');
I=imread('mountains-1899264_640.jpg');
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

count=1;
for y=1:h
    for x=1:w
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
N=size(P,1);
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
for i=1:h
    for  j=1:w
        if output(i,j,1)==0 && output(i,j,2)==0 && output(i,j,3)==0
            output(i,j,1)=255;
            output(i,j,2)=255;
            output(i,j,3)=255;
        end
    end
end
figure; imshow(output);
