function pop = uti_updateBiasedFitnesses(pop,par)
%uti_updateBiasedFitnesses 为pop增加Fitness

if any(isinf([pop.Cost]))
    error('isinf([pop.Cost])');
    pop(isinf([pop.Cost]))=[];
end

% 初始化个体求解质量和多样性的评估向量
popSize = numel(pop);
Quality=zeros(popSize,1);
Diversity=zeros(popSize,1);

% a.求解rank_quality：个体质量：VRP距离加Penalty 差值越大 解越差 即适应度越小
maxCost = max([pop.Cost]);    
if isinf(maxCost), error('maxCost'); end
for ii=1:numel(pop)
    Quality(ii) = 1 - pop(ii).Cost / (maxCost+1);
end
% 个体质量rank：quality越高 rank值越大
[~,sortIdx] = sort(Quality,'ascend');
[~,rank_quality] = sort(sortIdx);

% b.求解rank_diversity：个体多样性：个体距离最近nClosest个体相似性度量 距离越小 多样性越大 适应度越大
% 改为计算AverageBrokenPairDistance
if numel(pop)>1
    for ii=1:numel(pop)
        maxSize = min(par.nClosest,popSize-1);
        Diversity(ii)  = mean(mink(pop(ii).brokenDist,maxSize));
    end
end
% 个体多样性rank：diversity越高 rank值越大
[~,sortIdx] = sort(Diversity,'ascend');
[~,rank_diversity] = sort(sortIdx);

% 记录个体的求解质量和多样性
Quality=num2cell(Quality');
[pop.Quality] = deal(Quality{:});
Diversity=num2cell(Diversity');
[pop.Diversity] = deal(Diversity{:});

% for ii=1:numel(pop)
%     pop(ii).Quality= Quality(ii);
%     pop(ii).Diversity= Diversity(ii);
% end

% Fitness适应度赋值 基于目标值+多样性 （基于rank排名：有统一量纲作用）
% 权重：（1-par.eliteNum/popSize)
% 适应度与解的质量和解的多样性相关
if numel(pop)==1
    pop(ii).Fitness = 0;
else
    pop(ii).Fitness = rank_quality(ii) + (1-par.eliteNum/popSize) * rank_diversity(ii);
end


end