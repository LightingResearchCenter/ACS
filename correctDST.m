function [ absTimeCorrected ] = correctDST( absTime, downloadDate )
%CORRECTDST Summary of this function goes here
%   Detailed explanation goes here

dstStart2016 = datenum(2016,3,13,2,0,0);

if (absTime.localDateNum(1) < dstStart2016) && (downloadDate > dstStart2016)
    absTimeCorrected = absolutetime(absTime.localCdfEpoch,'cdfepoch',false,(absTime.offset.hours - 1),'hours');
else
    absTimeCorrected = absTime;
end

end

