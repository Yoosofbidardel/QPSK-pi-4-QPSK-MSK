clc;
clear;
close all;
%% initialization
modulation_type=input('choose (1) for QPSK , (2) for pi/4 QPSK : '); 
len_stream=input('please enter length of stream:');
SNR=input('input SNRs as an array like "[a b c ]":');
bit_stream=randi([0 1], len_stream, 1);  % a collomn of random bit as our signal

if modulation_type==1
    %% QPSK modulator and demodulator objects
    qpsk_modulator = comm.QPSKModulator('BitInput',true);
    qpsk_modulator.PhaseOffset = 0; % creating QPSK object constellation with phase 0
    qpsk_demodulator = comm.QPSKDemodulator('BitOutput',true);
    qpsk_demodulator.PhaseOffset = 0;


    %% modulated signal : ready for transmition 
    qpsk_tx= qpsk_modulator(bit_stream);%modulated signal


    %% passing through channel with different SNRs
    for i=1:length(SNR)+1
        rx_sig=awgn(qpsk_tx,SNR(i));
        %subplot(2,round(length(SNR)/2),i);
        h = scatterplot(rx_sig);
        hold on
        scatterplot(qpsk_tx,[],[],'r*',h)
        grid    
        title(['signal constellation for SNR=',num2str(SNR(i))]);
        hold off
        rx_demod = qpsk_demodulator(rx_sig) ;
        [num(i),BER_rate(i)] = biterr(bit_stream,rx_demod);

    end
    plot(SNR,BER_rate);
    title(' SNR_BER');
%% pi/4 QPSK constellation
elseif modulation_type==2
    qpsk_modulator1 = comm.QPSKModulator('BitInput',true);
    qpsk_modulator1.PhaseOffset = 0; 
    qpsk_modulator2 = comm.QPSKModulator('BitInput',true);
    
    qpsk_demodulator1 = comm.QPSKDemodulator('BitOutput',true);
    qpsk_demodulator1.PhaseOffset = 0;
    qpsk_demodulator2 = comm.QPSKDemodulator('BitOutput',true);
    
%% modulated signal : ready for transmition 

for j=1:(length(bit_stream)/2)
    if mod(j,2) ==1        
        tx(j,1)=qpsk_modulator1(bit_stream(2*j-1:2*j));
    else
        tx(j,1) = qpsk_modulator2(bit_stream(2*j-1:2*j));
    end
   
   
end
%% passing through channel with different SNRs
for i=1:length(SNR)+1
        rx_sig2=awgn(tx,SNR(i));
        %subplot(2,round(length(SNR)/2),i);
        h = scatterplot(rx_sig2);
        hold on
        scatterplot(tx,[],[],'r*',h)
        grid    
        title(['signal constellation for SNR=',num2str(SNR(i))]);
        hold off
        for l=1: length(tx)
            if mod(l,2) ==1        
                rx_demod2(2*l-1:2*l,1)=   qpsk_demodulator1(rx_sig2(l));
            else
                rx_demod2(2*l-1:2*l,1) =  qpsk_demodulator2(rx_sig2(l));
            end
        end
        [num2(i),BER_rate2(i)] = biterr(bit_stream,rx_demod2);
    
       
    
end 
figure;
plot(SNR,BER_rate2);
title(' SNR_BER for pi/4 QPSK');
end



