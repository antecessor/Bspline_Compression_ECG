%% Load Data
i=2;
Name={'a01','a02','a04','a05','a06','a07','a08','a09'};
load(['dataset\' Name{i} 'm']);
Annotation= table2cell(readtable(['dataset\' Name{i} 'A.csv']));
xMin=1;
xMax=150;
x=xMin:xMax;
val = resample(val,2,1);
ECG=val(x)';
% ECG=sgolayfilt(ECG,5,11);
ECG=ECG/max(ECG);
x=x';
%%
degree=4;
knots=10;
BestSol=GA(x,ECG,degree,knots);
pos=BestSol.Position;
knotsPos= pos(1:knots);
c=pos(knots+1:end)';
y_fit  = spline_eval( x, c, degree, knotsPos);


y_fit=y_fit/max(y_fit);

% bspline_show(x, degree, knotsPos);
% figure; plot(x, ECG, x, y_fit);
% figure; plot(x, ECG - y_fit);