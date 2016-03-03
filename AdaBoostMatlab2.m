%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple demo of Gentle Boost with stumps and 2D data
% Implementation of gentleBoost. The algorithm is described in:
% Jeong-Hyun, Kim 
% V.I.S. Lab.
% 

%%
clear all
% Define plot style parameters
plotstyle.colors = {'gs', 'ro'};  % color for each class
plotstyle.range = [-50 50 -50 50]; % data range


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create data: use the mouse to build the training dataset.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
figure(1); 
clf %clear current figure window
axis(plotstyle.range); hold on
axis('square')
title('Left button = class +1, right button = class -1. Press any key to finish.')
i  = 0; clear X Y

while 1
    [x,y,c] = ginput(1);
    if ismember(c, [1 3])
        i = i + 1;
        X(1,i) = x;
        X(2,i) = y;
        Y(i) = (c==1) - (c==3); % class = {-1, +1}
        plot(x, y, plotstyle.colors{(Y(i)+3)/2}, 'MarkerFaceColor', plotstyle.colors{(Y(i)+3)/2}(1), 'MarkerSize', 2);
    else
        break
    end
end
[Nfeatures, Nsamples] = size(X); 
%%% ����Ʈ �����
D = ones(1,Nsamples) / Nsamples;

%%
%%%���� �з� Feature ����� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% x�࿡ ���ؼ� ������ ����
sortX = sort(X(1,:));
WeakData = ones(1,3); %��������(1) ��������(2), ��ǥ, ���� Ȥ�� ���� +1�ΰ� -1 �����ΰ�?
WeakCount = 1;
for j=1:Nsamples-1
    %���� x�� 1, ���� y�� 2  
    WeakData(WeakCount,:) = [1, ( sortX(j)+sortX(j+1) )/2, +1];
    WeakCount = WeakCount + 1;
    WeakData(WeakCount,:) = [1, ( sortX(j)+sortX(j+1) )/2, -1];
    WeakCount = WeakCount + 1;
end

%%% y�࿡ ���ؼ� ������ ����
sortY = sort(X(2,:));
for j=1:Nsamples-1
    %���� x�� 1, ���� y�� 2  
    WeakData(WeakCount,:) = [2, ( sortY(j)+sortY(j+1) )/2, +1];
    WeakCount = WeakCount + 1;
    WeakData(WeakCount,:) = [2, ( sortY(j)+sortY(j+1) )/2, -1];
    WeakCount = WeakCount + 1;
end
WeakCount = WeakCount - 1;
disp( sprintf('Feature ������ : %d', WeakCount) );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%�ݺ�Ƚ��
T = 500;

%T���� Ư¡�� ����
TrainWeak = ones(1,2);

%%
for tIndex=1:T

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Weak Classifier�� �̿��Ͽ� �ְ� ���� ������ ã�´�.
tTError=[0];
%%% Ư¡�� ���� ��� ������ ���ϰ� �� �� ���� ���� �������� ã�´�. �� ������ ���� Ư¡��ҵ鵵 �����ϰ� �־�� ��.
for j=1:WeakCount
    Error=0;
    %%j��° Ư¡�� ���ؼ� error���� ���Ѵ�.
    for k=1:Nsamples
        %%X�����Ͱ� ���� +1 Ŭ���� �ΰ�?
        if(WeakData(j,2) >  X(WeakData(j,1),k))
            if(WeakData(j,3) ~= Y(k) ) 
                %�߸� �����Ǿ� ����Ʈ�� ����
                Error = Error + D(1,k);
            end
        else
            if( WeakData(j,3)*-1 ~= Y(k) )
                %�߸� �����Ǿ� ����Ʈ�� ����
                Error = Error + D(1,k);
            end
        end
    end
    tTError(j)=[ Error];
end

% tTError�� feature�� ���� error���� ����ִ�. ���߿� �ְ� ���� Error���� ã�� �� Weak�� ����
[sortTError,sortIndex]=sort(tTError);

%�ְ� ���� ���������� ���İ��� ���Ѵ�.
alpha = 0.5 * log( (1-sortTError(1,1)) / sortTError(1,1) ) ;

%���İ��� ��з��⸦ ����(feature=�з����)
TrainWeak(tIndex, :) = [sortIndex(1,1),alpha];

%weight ������Ʈ
for j=1:Nsamples
    %%X�����Ͱ� ���� +1 Ŭ���� �ΰ�?
    if(WeakData(sortIndex(1,1),2) >  X(WeakData(sortIndex(1,1),1),j))
        if(WeakData(sortIndex(1,1),3) ~= Y(j) ) 
            %�߸� ������
            D(1,j) = D(1,j) * exp(alpha);
        else
            %�� ������
            D(1,j) = D(1,j) * exp(-alpha);
        end
    else
        if( WeakData(sortIndex(1,1),3)*-1 ~= Y(j) )
            %�߸� �����Ǿ� ����Ʈ�� ����
            D(1,j) = D(1,j) * exp(alpha);
        else
            %�� ������
            D(1,j) = D(1,j) * exp(-alpha);
        end
    end
end

disp( sprintf('%d ��°', tIndex));
disp( sprintf('error %f', sortTError(1,1) ));
disp( sprintf('alpha %f' ,alpha));
disp( sprintf('z %f' , sum(D) ));

D = D / sum(D);

disp(D);

disp('============================ next round ==========================================')


end


%% �Էµ����Ϳ� ���� �з� ����
%������ �����
inData = [-50:50 ; ones(1,101)*50 ];
for i=-49:50
    temp = [-50:50 ; ones(1,101)*i ];
    inData = [inData , temp];
end

[c,s] = size(inData);
inDataResult = ones(1,s); %+1 ���� -1 ���� ����� ���� ��Ʈ����


%�Է� �����Ϳ� ���� j ��° �˻� 
for j=1:s
H=0;
A=0;
Sigma=0;

for i=1:T
    %�Է� �����Ϳ� ���� ��з��� T���� �˻�
  
    %Alpha�� ����
    A = TrainWeak(i,2);
    %H(x)�� ����
    if(WeakData( TrainWeak(i,1) , 2 ) >  inData( WeakData( TrainWeak(i,1),1) , j  )) 
        %���� ������ ����
        H=WeakData( TrainWeak(i,1) , 3 );
    else
        %���� ������ ������
        H=WeakData( TrainWeak(i,1) , 3 ) * -1;
    end
    
    Sigma = Sigma + (A*H);

end

inDataResult(1,j) = sign(Sigma);
end

figure(2);
clf %clear current figure window
axis(plotstyle.range); hold on
axis('square')
title('Strong Classifier -> H(x)')

color={'g','r'};

for i=1:s
    plot( inData(1,i), inData(2,i), color{(inDataResult(1,i)+3)/2}  );
end


for i=1:Nsamples
    x = X(1,i);
    y = X(2,i);    
    plot(x, y, plotstyle.colors{(Y(i)+3)/2}, 'MarkerFaceColor', plotstyle.colors{(Y(i)+3)/2}(1), 'MarkerSize', 2);    
end







