function BestSol=GA(x_axis,y_axis,degree,knots)
%% Problem Definition
global NFE;
NFE=0;

CostFunction = @(x) MyCost(x,x_axis,y_axis,degree,knots);
ncoeff = knots + degree - 1;
nVar=knots+ncoeff;       % Number of Decision Variables

VarSize=[1 nVar];   % Size of Decision Variables Matrix

VarMin=[ones(1,knots)*min(x_axis) 0*ones(1,ncoeff)] ;        % Lower Bound of Variables
VarMax=[ones(1,knots)*max(x_axis) 5*ones(1,ncoeff)];         % Upper Bound of Unknown Variables
%% GA Parameters

MaxIt=200;          % Maximum Number of Iterations

nPop=20;            % Population Size

pc=0.8;                 % Crossover Percentage
nc=2*round(pc*nPop/2);  % Number of Offsprings (Parents)

pm=0.5;                 % Mutation Percentage
nm=round(pm*nPop);      % Number of Mutants

gamma=0.1;

etha=0.1;

mu=0.05;                % Mutation Rate

ANSWER=questdlg('Select the Parent Selection Method:','GA','Random','RWS','TS','RWS');
UseRandomSelection=strcmpi(ANSWER,'Random');
UseRWS=strcmpi(ANSWER,'RWS');
UseTS=strcmpi(ANSWER,'TS');

if UseRWS
    beta=10;                % Selection Pressure
end

if UseTS
    TournamentSize=3;       % Tournament Size
end

pause(0.1);

%% Initialization

% Create Empty Structure
empty_individual.Position=[];
empty_individual.Cost=[];

% Create Population Matrix (Array)
pop=repmat(empty_individual,nPop,1);

% Initialize Population
for i=1:nPop
    
    % Initialize Position
    pop(i).Position=unifrnd(VarMin,VarMax,VarSize);
    if i==1
        kn=linspace(min(x_axis),max(axis),knots);
        [~,kn(3)]=max(y_axis);
        [~,kn(2)]=min(y_axis);
        c = spline_fit(x_axis,y_axis, degree, kn);
        pop(i).Position(end-size(c)+1:end)=c';
    end
    % Evaluation
    pop(i).Cost=CostFunction(pop(i).Position);
    
end

% Sort Population
Costs=[pop.Cost];
[Costs SortOrder]=sort(Costs);
pop=pop(SortOrder);

% Update Best Solution Ever Found
BestSol=pop(1);

% Update Worst Cost
WorstCost=max(Costs);

% Array to Hold Best Cost Values
BestCost=zeros(MaxIt,1);

% Array to Hold NFEs
nfe=zeros(MaxIt,1);


%% GA Main Loop

for it=1:MaxIt
    
    if UseRWS
        % Calculate Selection Probabilities
        P=exp(-beta*Costs/WorstCost);
        P=P/sum(P);
    end
    
    % Crossover
    popc=repmat(empty_individual,nc/2,2);
    for k=1:nc/2
        
        % Select Parents
        
        if UseRandomSelection
            i1=randi([1 nPop]);
            i2=randi([1 nPop]);
            p1=pop(i1);
            p2=pop(i2);
        end
        
        if UseRWS
            i1=RouletteWheelSelection(P);
            i2=RouletteWheelSelection(P);
            p1=pop(i1);
            p2=pop(i2);
        end
        
        if UseTS
            p1=TournamentSelection(pop,TournamentSize);
            p2=TournamentSelection(pop,TournamentSize);
        end
        
        % Apply Crossover
        [popc(k,1).Position popc(k,2).Position]=ArithmeticCrossover(p1.Position,p2.Position,gamma,VarMin,VarMax);
        
        % Evaluate Offsprings
        popc(k,1).Cost=CostFunction(popc(k,1).Position);
        popc(k,2).Cost=CostFunction(popc(k,2).Position);
        
    end
    popc=popc(:);
    
    % Mutation
    popm=repmat(empty_individual,nm,1);
    for k=1:nm
        
        % Select Parent Index
        i=randi([1 nPop]);
        
        % Select Parent
        p=pop(i);
        
        % Apply Mutation
        popm(k).Position=Mutate(p.Position,mu,etha,VarMin,VarMax);
        
        % Evaluate Mutant
        popm(k).Cost=CostFunction(popm(k).Position);
        
    end
    
    % Merge Population
    pop=[pop
        popc
        popm];
    
    % Sort Population
    Costs=[pop.Cost];
    [Costs, SortOrder]=sort(Costs);
    pop=pop(SortOrder);
    
    % Truancate Extra Memebrs
    pop=pop(1:nPop);
    Costs=Costs(1:nPop);
    
    % Update Best Solution Ever Found
    BestSol=pop(1);
    
    % Update Worst Cost
    WorstCost=max(WorstCost,max(Costs));
    
    % Update Best Cost Ever Found
    BestCost(it)=BestSol.Cost;
    [~,Sol]=CostFunction(pop(1).Position);
    % Update NFE
    nfe(it)=NFE;
    
    % Show Iteration Information
    disp(['Iteration ' num2str(it) ': NFE = ' num2str(nfe(it)) ', Best Cost = ' num2str(BestCost(it))]);
    
    x=BestSol.Position;
    knotsPos= x(1:knots);
    c=x(knots+1:end)';
    y  = spline_eval( x_axis, c, degree, knotsPos );
    y=y/max(y);
    
%      if it<95
%         y=sgolayfilt((y+y_axis)/2,3,5);
%      end
%     if it>50
%         y=sgolayfilt((y+2*y_axis)/3,7,15);
%     end
%      if it>70
%         y=sgolayfilt((y+3*y_axis)/4,7,15);
%     end
%     if it>80
%         y=sgolayfilt(y_axis,7,15);
%     end
    y=y/max(y);
    
    figure(1)
    clf
    plot(y);
    hold on
    plot(y_axis)
    pause(0.001)
    
    
    
    
end

end

