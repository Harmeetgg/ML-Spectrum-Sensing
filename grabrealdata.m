clear all 
close all
addpath('../../../ModSim Analysis/Cyclostationary Tools/Time Dilation');
import fam.*
import plotters.*
IPAddr = strcat('ip:','192.168.1.102');
Channel_Select = 0;



%% AXI4 Stream IIO Write registers
% NOTE: This is a place holder based on auto-generated templates. Please modify these values according to your FPGA design
AXI4SReadObj = pspshared.libiio.axistream.read(...
                  'IPAddress',IPAddr,...
                  'SamplesPerFrame',32*1024,...
                  'DataType','ufix64',...
                  'Timeout',0.1);
setup(AXI4SReadObj);

AXI4SWriteObj = pspshared.libiio.axistream.write(...
                  'IPAddress',IPAddr,...
                  'SamplesPerFrame',1024,...                  
                  'Timeout',0.1);
setup(AXI4SWriteObj,fi(zeros(1024,1),numerictype('ufix64')));


%% AXI4 MM IIO Write registers
xLoopback =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('104')); 
xADC_Select =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('108')); 
xBER_Ctrl =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('114')); 
zTD_Ctrl =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('10C')); 
xTxAWGN =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('110')); 
xSyncThresh =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('100')); 
xPulsePhase =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('118')); 
xTxdBAtten =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('11C')); 
xStreamSelect =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('120')); 
xStreamTrigger =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('124')); 
xStreamNumber =  pspshared.libiio.aximm.write(...
                   'IPAddress',IPAddr,...
                   'AddressOffset',hex2dec('128')); 


%% AXI4 MM IIO Read registers
sCtr64Hi = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('12C'),...
                 'DataType','uint32');
sCtr64Lo = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('130'),...
                 'DataType','uint32');
sLostSamples = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('134'),...
                 'DataType','uint32');
sInSync = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('138'),...
                 'DataType','boolean');
sBitErrors = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('13C'),...
                 'DataType','uint32');
sTestWord = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('140'),...
                 'DataType','uint32');
sNumFrames = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('144'),...
                 'DataType','uint32');
sRxPwr = pspshared.libiio.aximm.read(...
                 'IPAddress',IPAddr,...
                 'AddressOffset',hex2dec('148'),...
                 'DataType','Fixed-Point',...
                 'FixedPointDataType',numerictype('ufix32_En28'));


%% Setup() AXI4 MM IIO Objects
% NOTE: These are placeholder values. Please update this section according to your design

% Setup AXI4MM Read IIO objects
setup(sCtr64Hi); 
setup(sCtr64Lo); 
setup(sLostSamples); 
setup(sInSync);               %InSync
setup(sBitErrors); 
setup(sTestWord); 
setup(sNumFrames); 
setup(sRxPwr); 
setup(xStreamSelect, uint32(0));
setup(xStreamTrigger, boolean(0));
setup(xStreamNumber, uint32(32*1024));

%----------------------------- initialize cfg (ctrlReg)
% These parameters are set in the FX_ain program
cfg = [];

cfg.NoTDTX = 1; % 0 to have Time Dilation on TX, 1 to skip it
cfg.NoTDRX = 1; % 0 to have Time Dilation on RX, 1 to skip it
cfg.Loopback = uint32(0);        % MFD Loopback turned off with 0


cfg.TxDelayAlign = 203; % how much delay on TD Delay generator to match TX Waveform
cfg.RxDelayAlign = 19; % how much delay on TD Delay generator to match RX Waveform
TDControl = cfg.NoTDTX + cfg.NoTDRX*2 + cfg.TxDelayAlign*2^8 + cfg.RxDelayAlign*2^16;

cfg.ADC_Select = uint32(Channel_Select);      % default channel 0 for receiver
cfg.BER_Ctrl = uint32(0);        % BER COntrol, 0 to run 1 to reset 2 to freeze
cfg.TD_Ctrl = uint32(TDControl);
cfg.TxAWGN = boolean(0);    % 0 for no AWGN added to TX, 1 to turn on AWGN, was originally uint32()
cfg.SyncThresh = uint32(30);    % Sync threshold for frame detect sugget 30
cfg.PulsePhase = uint32(0);    % rise from 0 to finite will kick Rx phase 90degrees
cfg.TxdBAtten = uint32(0);        % Tx Signal Atten in dB 0-63 dB, 64 or higher turns off Tx Signal

% Setup AXI4MM Write IIO objects
setup(xLoopback,cfg.Loopback); % MFD Loopback turned off with 0
setup(xADC_Select,cfg.ADC_Select); % default channel 0 for receiver
setup(xBER_Ctrl,cfg.BER_Ctrl); % BER COntrol, 0 to run 1 to reset 2 to freeze
setup(zTD_Ctrl,uint32(TDControl));
setup(xTxAWGN,cfg.TxAWGN); % 0 for no AWGN added to TX, 1 to turn on AWGN, was originally uint32()
setup(xSyncThresh,cfg.SyncThresh); % Sync threshold for frame detect sugget 30 
setup(xPulsePhase,cfg.PulsePhase); % rise from 0 to finite will kick Rx phase 90degrees
setup(xTxdBAtten,cfg.TxdBAtten); % Tx Signal Atten in dB 0-63 dB, 64 or higher turns off Tx Signal



% Step functions, used to write to register
step(xTxdBAtten,uint32(0));
step(xADC_Select,uint32(cfg.ADC_Select));       % Select ADC Channel
step(zTD_Ctrl,uint32(TDControl));     % Not used in F2
step(xTxAWGN, uint32(0));              % AWGN use set to False
step(xSyncThresh, uint32(28));              % Set Sync Threshold to 29, 0..32, below about 18 should be garbage
step(xStreamSelect, uint32(0));
step(xStreamTrigger, boolean(1));
step(xStreamNumber, uint32(32*1024*4));
step(xLoopback,uint32(0));                            % MFD Loopback turned off with 0
avg_rx_power = 0;

step(xBER_Ctrl, uint32(1));
pause(0.1);
step(xBER_Ctrl, uint32(0));
pause(0.1);

step(xADC_Select,uint32(2));
pause(0.1);
step(xADC_Select,uint32(0));
pause(0.1);

close all;

M = 100;


stream_delay = 2;
j=i/7980/4*stream_delay;
step(xStreamNumber,uint32(32*1024));
pause(0.1);

atten_arr = [31 30 29 28 27]; %26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 60]; 

for atten=atten_arr
    % Grab noise data
    atten
    Data32_loop = zeros(1,32768);
    Valid32_loop = zeros(1,32768);

    step(xTxdBAtten,uint32(atten)); % Value gets changed
    pause(0.1);
    step(xBER_Ctrl, uint32(1));
    pause(0.1);
    step(xBER_Ctrl, uint32(0));
    pause(0.1);
    nFrames    = sNumFrames();    % frames counted
    BitErrors = sBitErrors();   % bit Errors
    BERbits = nFrames*15808;
    BERRate = cast(BitErrors,'double')/cast(BERbits,'double')

    SNR_val = int2str(5-atten);
    my_dir = strcat('IQ_samples/SNR_',SNR_val);
    if not(isfolder(my_dir))
        mkdir(my_dir);
    end

    d = dir([my_dir, '\*.mat']);
    %file_num = int2str(length(d)/2+1)
    IQcplx_no_td = zeros(32*1024,2,M);
    for a=1:M
        step(xStreamTrigger,false);
        pause(0.1);
        step(xStreamTrigger,true);
        pause(0.1);
        [Data32_loop,~] = AXI4SReadObj();
        pause(0.1);

        I = bitsliceget(Data32_loop,16,1); % bitsliceget works to take the bits out of fixed point numbers.
        II = reinterpretcast(I,numerictype(1,16,14)); % interprets bits in I as 16-bit signed fixed with 14 bit fraction
        Q = bitsliceget(Data32_loop,32,17); % bits 32-17 are the Q values
        QQ = reinterpretcast(Q,numerictype(1,16,14)); % interpret the Q bits as right fixed point
        IQcplx_no_td(:,1,a) = II;
        IQcplx_no_td(:,2,a) = QQ;
        a
    end
    save(strcat(my_dir,'/IQ_no_TD'),'IQcplx_no_td');
end

% cfg.NoTDTX = 0; % 0 to have Time Dilation on TX, 1 to skip it
% cfg.NoTDRX = 0; % 0 to have Time Dilation on RX, 1 to skip it
% cfg.TxDelayAlign = 203; % how much delay on TD Delay generator to match TX Waveform
% cfg.RxDelayAlign = 19; % how much delay on TD Delay generator to match RX Waveform
% TDControl = cfg.NoTDTX + cfg.NoTDRX*2 + cfg.TxDelayAlign*2^8 + cfg.RxDelayAlign*2^16;
% cfg.TD_Ctrl = uint32(TDControl);
% step(zTD_Ctrl,uint32(TDControl));     % Not used in F2
% 
% Data32_loop = zeros(1,32768);
% Valid32_loop = zeros(1,32768);
% 
% IQcplx_td = zeros(32*1024,M);
% for a=1:M
%     step(xStreamTrigger,false);
%     pause(0.1);
%     step(xStreamTrigger,true);
%     pause(0.1);
%     [Data32_loop,~] = AXI4SReadObj();
%     pause(0.1);
% 
%     I = bitsliceget(Data32_loop,16,1); % bitsliceget works to take the bits out of fixed point numbers.
%     II = reinterpretcast(I,numerictype(1,16,14)); % interprets bits in I as 16-bit signed fixed with 14 bit fraction
%     Q = bitsliceget(Data32_loop,32,17); % bits 32-17 are the Q values
%     QQ = reinterpretcast(Q,numerictype(1,16,14)); % interpret the Q bits as right fixed point
%     IQcplx_td(:,a) = complex(II,QQ);
%     a
% end
% 
% save(strcat(my_dir,'/IQ_TD_',file_num),'IQcplx_td');
