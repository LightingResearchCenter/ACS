function [useTime_days,nonuseTime_days,usePrcnt,nonusePrcnt,useBouts,nonuseBouts] = deviceUse(masks,epoch)
%DEVICEUSE Summary of this function goes here
%   Detailed explanation goes here


use = masks.compliance(masks.observation);
nUse = sum(use);
nNonuse = sum(~use);
nTotal = nUse + nNonuse;

useTime_days = nUse*epoch.days;
nonuseTime_days = nNonuse*epoch.days;

usePrcnt = nUse/nTotal;
nonusePrcnt = nNonuse/nTotal;

useBouts = [];
nonuseBouts = [];


end

