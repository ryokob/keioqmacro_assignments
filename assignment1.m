clc
clear all
close all

% load the data
startdate = '01/01/1994';
enddate = '01/01/2019';

% south korea
f = fred
Yk = fetch(f, 'NGDPRSAXDCKRQ', startdate, enddate)
yk = log(Yk.Data(:,2));
qk = Yk.Data(:,1)

% japan
Yj = fetch(f, 'JPNRGDPEXP', startdate, enddate)
yj = log(Yj.Data(:,2));
qj = Yj.Data(:,1)

T = size(yk,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauGDPk = A\yk;
tauGDPj = A\yj;

% detrended GDP
yktilde = yk-tauGDPk;
yjtilde = yj-tauGDPj;

% plot detrended GDP
dates = 1994:1/4:2019.1/4;
figure
plot(qk, yktilde,'b', qj, yjtilde,'r')
title('SKorea(blue) and Japan(red) Detrended log(real GDP) 1994Q1-2019Q1')
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
yksd = std(yktilde)*100;
ykrho = corrcoef(yktilde(2:T),yktilde(1:T-1)); ykrho = ykrho(1,2);

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
yjsd = std(yjtilde)*100;
yjrho = corrcoef(yjtilde(2:T),yjtilde(1:T-1)); yjrho = yjrho(1,2);

corrkj = corrcoef(yktilde(1:T),yjtilde(1:T)); corrkj = corrkj(1,2);

disp(['SKorea Percent standard deviation of detrended log real GDP: ', num2str(yksd),'.']); disp(' ')
disp(['SKorea Serial correlation of detrended log real GDP: ', num2str(ykrho),'.']); disp(' ')

disp(['Japan Percent standard deviation of detrended log real GDP: ', num2str(yjsd),'.']); disp(' ')
disp(['Japan Serial correlation of detrended log real GDP: ', num2str(yjrho),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP of SKorea and Japan: ', num2str(corrkj),'.']);

