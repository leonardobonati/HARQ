% Initializes and runs HARQ receiver
%
%  Authors:
%  - Leonardo Bonati
%  - Fabio Brea
%
%  Date: Feb. 2016
%

% suppress warning
warning('off','all');

% Configuration and connection
disp ('Receiver started');
send=tcpip('127.0.0.1',4014);
receive=tcpip('127.0.0.1', 4013,'NetworkRole','server','Timeout',0.5);

% send=tcpip('172.21.234.242',4014);
% receive=tcpip('172.21.234.242', 4013,'NetworkRole','server');

% Open socket and wait before sending data
fopen(send);
pause(0.2);

k=64;
n=254;

error_correction_capability=floor((n-k)/2);

% set channel loss probability
loss_p=0.1;

% set channel error probability
error_p=0.001;

pkts_to_require=512;

%% initialization
cr=0;

tic;

received_file=-1*ones(pkts_to_require, n);

%% request time
f=1;

% received pkts counter
rx_no=0;

txSec=10;
received_pkts_no=zeros(pkts_to_require,1);
channel_losses=0;
channel_errors=0;
dec=1;

while f<=pkts_to_require
    DataToSend=[f, cr];
    fwrite(send,DataToSend,'int32');
    
    sprintf('%4.1f', str2double([num2str(f),'.',num2str(dec)]))
    

    
    % receive S[f, l, cs, i, pi]
    fopen(receive);

    flag=1;
    first_round=1;
    while flag
            
        try
            DataReceived=fread(receive,5,'int32');
            f1=DataReceived(1,1);
            l=DataReceived(2,1);
            cs=DataReceived(3,1);
            i=DataReceived(4,1);
            pi=DataReceived(5,1);
        catch
            break;
        end
        
        % compute D
        if first_round
            D=cs/l;
            first_round=0;
        end
        
        if cr >= l*D
            flag=0;
        end
        
                    
            % introduce losses in the channel
            if rand(1)>loss_p
                % introduce errors in the channel
                if rand(1)>error_p
                    received_file(f1,i)=pi;
                else
                    received_file(f1,i)=randi(n+1)-1;
                    channel_errors=channel_errors+1;
                end
                cr=cr+1;
            else
                channel_losses=channel_losses+1;
            end
            
    end
    fclose(receive);

    not_rx_no=0;
    for i=1:size(received_file,2)
        if received_file(f,i)==-1
            not_rx_no=not_rx_no+1;
        end
    end
    
    % ask for pi
    if not_rx_no <= error_correction_capability
        for i=1:size(received_file,2)
            if received_file(f,i)>-1
                received_pkts_no(f)=received_pkts_no(f)+1;
            end
        end
        
        % ask for another file
        f=f+1;
        dec=1;
    else
        dec=dec+1;
    end
    
    cr=0;
    
end

fclose(send);

% measure time elapsed
time=toc;

% emit sound
beep;