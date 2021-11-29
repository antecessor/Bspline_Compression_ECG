function [z,sol]=MyCost(x,x_axis,y_axis,d,kn)

global NFE;
if isempty(NFE)
    NFE=0;
end
NFE=NFE+1;

% [~,knots(round(kn/2))]=max(y_axis);
knots= round(x(1:kn));
c=x(kn+1:end)';
y_fit = (spline_eval( x_axis, c, d, knots ));

y_fit=y_fit/max(y_fit);

y_fitd=diff(y_fit);
y_fitd=y_fitd/max(y_fitd);

y_axisd=diff(y_axis);
y_axisd=y_axisd/max(y_axisd);

PRDd=100*sqrt(sum((y_fitd-y_axisd).^2)/(sum(y_axisd.^2)));
rmsed=sqrt(mean((y_fitd-y_axisd).^2));

PRD=100*sqrt(sum((y_fit-y_axis).^2)/(sum(y_axis.^2)));
rmse=sqrt(mean((y_fit-y_axis).^2));
z=PRD;


sol.pos=x;



end