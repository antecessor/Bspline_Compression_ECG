%% Load Data
Fs=150;
i=1;
Name={'a01','a02','a04','a05','a06','a07','a08','a09'};
load(['dataset\' Name{i} 'm']);
Annotation= table2cell(readtable(['dataset\' Name{i} 'A.csv']));
xMin=1;
xMax=300;
x=xMin:xMax;
val = resample(val,2,1);
ECG=val(x)';
[b,a] = butter(5,100/150/2,'low');
ECG=filtfilt(b,a,ECG);
ECG=ECG/max(ECG);
x=x';
%%
filted=sgolayfilt(ECG,5,11);
filted=filted/max(filted);
plot(ECG)
hold on
plot(filted)
legend('Original signal','Approximated')
xlabel('sample')

PRD=100*sqrt(sum((ECG-filted).^2)/(sum(ECG.^2)))
sqrt(mean((filted-ECG).^2))