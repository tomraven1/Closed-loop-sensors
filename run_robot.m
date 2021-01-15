function time=run_robot()
clear all

addpath('C:\Users\thoma\OneDrive - University of Cambridge\Desktop\sensor-dyna\UR5RobotControlV3.2')
rng(100)


%
% channel7 = addAnalogInputChannel(s,'Dev1','ai6','Voltage');
% channel7.TerminalConfig = 'Differential';
%
% channel8 = addAnalogInputChannel(s,'Dev1','ai7','Voltage');
% channel8.TerminalConfig = 'Differential';

freq=25;

Robot_IP = '169.254.53.142';
Socket_conn = tcpip(Robot_IP,30000,'NetworkRole','server');

%Robot_IP = '192.168.1.10';
%Socket_conn = tcpip(Robot_IP,30010,'NetworkRole','server');
fclose(Socket_conn);
disp('Press Play on Robot...')
fopen(Socket_conn);
disp('Connected!');
Orientation=[pi,0,0];
%Orientation=[2.84,1.25,0];

Translation=[-500,-80,160];
moverobot_Ki(Socket_conn,Translation,Orientation);
Translation_inner=Translation;
pause(5)

bounds=[-550, -50, 150; -600, -90,170];
Trans(1,:)=Translation;

new=bounds(1,:)+rand(1,3).*(bounds(2,:)-bounds(1,:));
dis=rssq(Trans(1,:)-new);
tic
tim(1)=0;


for i=1:20000

    %Trans(i+1,:)=[-113,-581-12*cos(i/freq),-27];
%     if mod(i,500)==0
%         freq=10+rand*20;
%     end

    moverobot_Ki(Socket_conn,Trans(i+1,:),Orientation);
    
    tim(i+1)=toc;
    freq=freq-22/20000;
end



time=toc;
save motion.mat

%moverobot(Socket_conn,Translation,Orientation);
moverobot_Ki(Socket_conn,Translation,Orientation);
end