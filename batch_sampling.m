
freq=35;

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



tic

tim1(1)=0;
tim2(1)=0;

vel=1;
for k=1:20
    %rng(100)
    Trans(1,:)=Translation;
    new=bounds(1,:)+rand(1,3).*(bounds(2,:)-bounds(1,:));
    dis=rssq(Trans(1,:)-new);
    thres=rand/2+0.55;
    for i=1:10000
        
        vel= round(abs(randn)/1,1)-round(abs(randn)/1.4,1);
        if rand >thres
            vel=0;
        end
        
        if dis >2
            Trans(i+1,:)=Trans(i,:)+vel*double(abs(new-Trans(i,:))>1).*sign((new-Trans(i,:)));
        else
            new=bounds(1,:)+rand(1,3).*(bounds(2,:)-bounds(1,:));
            Trans(i+1,:)=Trans(i,:);
        end
        dis=rssq(Trans(i+1,:)-new);
        
        if Trans(i+1,3)>bounds(1,3)||Trans(i+1,3)<bounds(2,3)
            Trans(i+1,:)=Trans(i,:);
            
        end
        
        moverobot_Ki(Socket_conn,Trans(i+1,:),Orientation);
        tim1(i+1)=toc;
        %  [data, timestamps, starttime] = startForeground(s);
        % asd=read(d);
        [data(i,:,k), t(i)] = read(d, "OutputFormat", "Matrix");
        tim2(i+1,k)=toc;
        %freq=freq-22/20000;
        %i
    end
    k
    moverobot_fast(Socket_conn,Translation,Orientation);

    pause(300)
end

time=toc;
save motion.mat

%moverobot(Socket_conn,Translation,Orientation);
moverobot_Ki(Socket_conn,Translation,Orientation);