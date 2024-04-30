function [X b] = make_X_b(I,p)

[I_x I_y] = size(I);

% �f�[�^�s��D�̐���
D = zeros( (I_x-p+1)*(I_y-p+1) , p*p );
k = 0;
for i=1:I_x-p+1
    for j=1:I_y-p+1
        k = k+1;
        D(k,:) = reshape(I(i:i+p-1,j:j+p-1),1,[]);
    end
end

% �f�[�^�s��D�̐^�񒆂̗񂪃x�N�g��b�A�^�񒆂̗����菜�������̂��s��X�ɂȂ�
center = (p*p+1)/2;
b = D(:,center);
X = [ D(:,1:center-1) D(:,center+1:p*p) ];
