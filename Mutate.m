function y=Mutate(x,mu,etha,VarMin,VarMax)

    nVar=numel(x);
    
    nMu=ceil(mu*nVar);
    
    j=randsample(nVar,nMu);
    
    y=x;
    
    sigma=etha*(VarMax-VarMin);
    
    y(j)=x(j)+sigma(j)*randn;
    
    y=max(y,VarMin);
    y=min(y,VarMax);

end