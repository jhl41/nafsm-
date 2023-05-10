img=imread('lena.jpg');
img1= imnoise(img,'salt & pepper',0.50);
%%
[Y,M]=nafsm(img1,20,60);
subplot(221);
imshow(img);
title('原始图像');

subplot(222);
imshow(img1);
title('80%椒盐噪声图像');

subplot(234);
imshow(Y);
title('NAFSM滤波结果');
imwrite(Y,'NAFSM滤波结果.tiff')

subplot(235);
imshow(M);
title('NAFSM滤波结果，但是去掉加权求和，仅保留选择性中值滤波');
imwrite(M,'NAFSM滤波结果，但是去掉加权求和，仅保留选择性中值滤波.tiff')

subplot(236);
Z=mdfil(img1,3);
imshow(Z);
title('中值滤波');
imwrite(Z,'中值滤波.tiff')


function [output,M]=nafsm(input,t1,t2)%nafsm滤波器，input是输入图像，t1，t2是计算滤波后图像像素权重的参数
%output是完全输出图像，M是只进行了选择性中值滤波的图像
input=double(input);
windowsize=3;
%得到噪声分布
output = input;
[m,n]= size(output);
N=ones(m,n);%噪声分布图
a1=(input==min(input));
a2=(input==max(input));
N(a1)=0;
N(a2)=0;

%填充
padsize = floor(windowsize/2);
padimg=cell(1,3);
N1=cell(1,3);
for i=padsize:3

padimg{i} = padarray(input, [i i], 'replicate');
N1{i} = padarray(N, [i i], 'replicate');
end
%窗处理
for i=1:m
    for j=1:n
        for ps=padsize:3
            window1 = padimg{ps}(i:i+2*ps, j:j+2*ps);
            window2= N1{ps}(i:i+2*ps, j:j+2*ps);
            if sum(sum(window2))~=0
                output(i,j)=median(window1(window2==1));
                break
            end
            if ps==3
            padimg1 = padarray(output, [1 1], 'replicate');
            window3= padimg1(i:i+2, j:j+2) ; %取4个pix
            output(i,j)=median(window3(1:4)); 
            end
        end  
    end                 
end
M=output;
%f fuction 用于裁决原图和现在图的取值比例
ffunction=zeros(1,256);
temp=(t1:1:t2);
ffunction(t1-1:t2-1)=(temp-(t1))./(t2-t1);
ffunction(t2:end)=1;
F=zeros(m,n);
%D求像素和周围像素的差,算出权值
D=ones(m,n);
for i=1:m
    for j=1:n
       window1=padimg{1}(i:i+2, j:j+2);
       window2=abs(window1-input(i,j));
       windows3=window2(:);
       windows3(5)=[];
       D(i,j)=max(windows3);
       F(i,j)=ffunction(D(i,j)+1);
    end                 
end

input1=double(input);
m1=double(M);
Y=(1-F).*input1+F.*m1;
Y=uint8(Y);
output=Y;
M=uint8(M);
end
function output=mdfil(input,windowsize)%对输入图像做中值滤波
%%输入 噪声图像，核大小，
%%输出 滤波图像
img=input;
%填充
padsize = floor(windowsize/2);
img1 = padarray(img, [padsize padsize], 'replicate');
img2 = zeros(size(img));

[x,y]=size(img);
for i=1:x%应用中值滤波
    for j=1:y
        window = img1(i:i+2*padsize, j:j+2*padsize);
        img2(i,j) = median(window(:));  
    end
end    
img2=uint8(img2);%转换为in8格式
output=img2;
end