img=imread('lena.jpg');
img1= imnoise(img,'salt & pepper',0.50);
%%
[Y,M]=nafsm(img1,20,60);
subplot(221);
imshow(img);
title('ԭʼͼ��');

subplot(222);
imshow(img1);
title('80%��������ͼ��');

subplot(234);
imshow(Y);
title('NAFSM�˲����');
imwrite(Y,'NAFSM�˲����.tiff')

subplot(235);
imshow(M);
title('NAFSM�˲����������ȥ����Ȩ��ͣ�������ѡ������ֵ�˲�');
imwrite(M,'NAFSM�˲����������ȥ����Ȩ��ͣ�������ѡ������ֵ�˲�.tiff')

subplot(236);
Z=mdfil(img1,3);
imshow(Z);
title('��ֵ�˲�');
imwrite(Z,'��ֵ�˲�.tiff')


function [output,M]=nafsm(input,t1,t2)%nafsm�˲�����input������ͼ��t1��t2�Ǽ����˲���ͼ������Ȩ�صĲ���
%output����ȫ���ͼ��M��ֻ������ѡ������ֵ�˲���ͼ��
input=double(input);
windowsize=3;
%�õ������ֲ�
output = input;
[m,n]= size(output);
N=ones(m,n);%�����ֲ�ͼ
a1=(input==min(input));
a2=(input==max(input));
N(a1)=0;
N(a2)=0;

%���
padsize = floor(windowsize/2);
padimg=cell(1,3);
N1=cell(1,3);
for i=padsize:3

padimg{i} = padarray(input, [i i], 'replicate');
N1{i} = padarray(N, [i i], 'replicate');
end
%������
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
            window3= padimg1(i:i+2, j:j+2) ; %ȡ4��pix
            output(i,j)=median(window3(1:4)); 
            end
        end  
    end                 
end
M=output;
%f fuction ���ڲþ�ԭͼ������ͼ��ȡֵ����
ffunction=zeros(1,256);
temp=(t1:1:t2);
ffunction(t1-1:t2-1)=(temp-(t1))./(t2-t1);
ffunction(t2:end)=1;
F=zeros(m,n);
%D�����غ���Χ���صĲ�,���Ȩֵ
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
function output=mdfil(input,windowsize)%������ͼ������ֵ�˲�
%%���� ����ͼ�񣬺˴�С��
%%��� �˲�ͼ��
img=input;
%���
padsize = floor(windowsize/2);
img1 = padarray(img, [padsize padsize], 'replicate');
img2 = zeros(size(img));

[x,y]=size(img);
for i=1:x%Ӧ����ֵ�˲�
    for j=1:y
        window = img1(i:i+2*padsize, j:j+2*padsize);
        img2(i,j) = median(window(:));  
    end
end    
img2=uint8(img2);%ת��Ϊin8��ʽ
output=img2;
end