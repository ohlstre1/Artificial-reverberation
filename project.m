% ELEC-C5341 Äänen- ja puheenkäsittely
% Projekti
% Keinotekoinen kaiku

clear all; close all;

[wav, fs] = audioread('testTrack.wav');
[y,b,a] = schroeder2(wav,[0.1,0.2,0.3,0.4],[1,20,300,4000],0.8, [0.5,0.5],1);


% soundsc(wav, fs)
soundsc(y,fs)
