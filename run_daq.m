function data= run_daq()

s = daq.createSession('ni');
s.Rate = 100;
s.DurationInSeconds=100;

channel1 = addAnalogInputChannel(s,'Dev1','ai0','Voltage');
channel1.TerminalConfig = 'SingleEnded'; %Differential %'SingleEndedNonReferenced'

channel2 = addAnalogInputChannel(s,'Dev1','ai1','Voltage');
channel2.TerminalConfig = 'SingleEnded';

channel3 = addAnalogInputChannel(s,'Dev1','ai2','Voltage');
channel3.TerminalConfig = 'SingleEnded';

channel4 = addAnalogInputChannel(s,'Dev1','ai3','Voltage');
channel4.TerminalConfig = 'SingleEnded';

channel5 = addAnalogInputChannel(s,'Dev1','ai4','Voltage');
channel5.TerminalConfig = 'SingleEnded';

channel6 = addAnalogInputChannel(s,'Dev1','ai5','Voltage');
channel6.TerminalConfig = 'SingleEnded';

channel7 = addAnalogInputChannel(s,'Dev1','ai6','Voltage');
channel7.TerminalConfig = 'SingleEnded';

 [data, timestamps, starttime] = startForeground(s);
 save sensor_medium_touch_newday.mat

clear s channel1 channel2 channel3 channel4 channel5 channel6 channel7