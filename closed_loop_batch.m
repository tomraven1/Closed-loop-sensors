clear
load('samp1_lstm.mat')



net = resetState(net);
for i=1:10
    x{i}=x{1, 1}(:,1);
end



des=1.60;

Robot_IP = '169.254.129.12';
Socket_conn = tcpip(Robot_IP,30010,'NetworkRole','server');


d = daq('ni');
d.Rate=100;


ch1 = addinput(d,'Dev1','ai5','Voltage');
ch1.TerminalConfig = 'SingleEnded';

ch2 = addinput(d,'Dev1','ai6','Voltage');
ch2.TerminalConfig = 'SingleEnded';
%ch8 = addinput(d,'Dev1','ai7','Voltage');
%ch8.TerminalConfig = 'SingleEnded';
ch3 = addinput(d,'Dev1','ai8','Voltage');
ch3.TerminalConfig = 'SingleEnded';
ch4 = addinput(d,'Dev1','ai9','Voltage');
ch4.TerminalConfig = 'SingleEnded';
ch5 = addinput(d,'Dev1','ai10','Voltage');
ch5.TerminalConfig = 'SingleEnded';
ch6 = addinput(d,'Dev1','ai11','Voltage');
ch6.TerminalConfig = 'SingleEnded';
ch7 = addinput(d,'Dev1','ai12','Voltage');
ch7.TerminalConfig = 'SingleEnded';

ch8 = addinput(d,'Dev1','ai13','Voltage');
ch8.TerminalConfig = 'SingleEnded';



%start(d, "continuous");

fclose(Socket_conn);
disp('Press Play on Robot...')
fopen(Socket_conn);
disp('Connected!');
Orientation=[pi,0,0];
%Orientation=[2.84,1.25,0];

Translation=[-450,-550,130];
moverobot_Ki(Socket_conn,Translation,Orientation);
Translation_inner=Translation;
pause(5)

bounds=[-450,-550,130; -450,-550,86];
%bounds=[-450,-550,380; -450,-550,310];
Trans(1,:)=Translation;


new=bounds(1,:)+rand(1,3).*(bounds(2,:)-bounds(1,:));
dis=rssq(Trans(1,:)-new);

[data(1,:)] = read(d, "OutputFormat", "Matrix");

tic

tim1(1)=0;
tim2(1)=0;

pred(1,1)=des(1);

for i=1:4000

    err=pred(i,1)-des(i);
    K=round(err*25);
    if err>0.01
        Trans(i+1,:)=Trans(i,:)-K*[0,0,0.1];
    elseif  err<0.01
        Trans(i+1,:)=Trans(i,:)-K*[0,0,0.1];
    else
        Trans(i+1,:)=Trans(i,:);
    end
    
    if Trans(i+1,3)>bounds(1,3)||Trans(i+1,3)<bounds(2,3)%%%%IMP
        Trans(i+1,:)=Trans(i,:);
        
    end
    
    moverobot_Ki(Socket_conn,Trans(i+1,:),Orientation);
    tim1(i+1)=toc;
    
    
%     if rem(floor(i/50),2)==0
%        des(i+1)=1.6;%des(i)-0.003;
%     else
%        des(i+1)=1.1;%des(i)+0.003;
%     end
    %des(i+1) = des(i);%1.3-0.2*sin(i/50);
    
    des(i+1)=1.55-0.4*abs(sin(i/50));
    % des(i+1)=1.41+0.2*(sin(i/(400-(380/4000)*(i-1))));
     
   % des(i+1)=1.61-0.25*abs(sin(i/100))-0.25*abs(sin(i/70));
   % des(i+1)=1.61-0.4*floor(abs(2*sin(i/100))-0.00001);
    %des(i+1)=1.25;
    
   
    [data(i+1,:)] = read(d, "OutputFormat", "Matrix");
    tim2(i+1)=toc;
    data2(i,:)=data(i,:)+(data(i+1,:)-data(i,:))*(1/25)/(tim2(i+1)-tim2(i));%freq=25
    x{1}=(data2(i,2:end-1)'-mu)./sig;
    
   % [YPred_o]= predict(net,x,'MiniBatchSize',10);
    [net,YPred_o]= predictAndUpdateState(net,x{1},'MiniBatchSize',1);
    
    
    
    pred(i+1,1)=YPred_o*sig2+mu2;
    
    del=tim2(i+1)-tim2(i);
    if del<0.04
        pause (0.04-del-0.001)
    end
    %freq=freq-22/20000;
    %i
end



time=toc;
save motion.mat

%moverobot(Socket_conn,Translation,Orientation);
moverobot_fast(Socket_conn,Translation,Orientation);



plot(data(:,1))
hold on
plot(des)
hold on
plot(pred)

