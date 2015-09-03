function subjectId = subjectIdCheck(subjectId)
%SUBJECTIDCHECK Summary of this function goes here
%   Detailed explanation goes here

subjectId = upper(subjectId);
subjectId = regexprep(subjectId,'.*(A\d\d\d\d\d).*','$1');

end

