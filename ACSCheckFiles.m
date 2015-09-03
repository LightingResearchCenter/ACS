function acsFiles = ACSCheckFiles(dirPath)
%ACSCHECKFILES Summary of this function goes here
%   Detailed explanation goes here

template = struct('exists',     false,...
                  'nMatches',   0,    ...
                  'path',       '',   ...
                  'name',       '',   ...
                  'subjectID',  '',   ...
                  'deviceSN',   ''    ...
                  );

acsFiles = struct('CDF',        template,...
                  'CSV',        template,...
                  'data_log',   template,...
                  'log_info',   template,...
                  'diary',      template ...
                  );

file = fieldnames(acsFiles);

listing = dir(dirPath);

baseExprsn  = '(A\d{5})_[a-zA-Z]{3}\d{1,2}_(\d{3})';
cdfExprsn   = ['^',baseExprsn,'.*\.cdf$'];
csvExprsn   = ['^',baseExprsn,'.*\.csv$'];
dataExprsn  = ['^',baseExprsn,'.*-DATA\.txt$'];
logExprsn   = ['^',baseExprsn,'.*-LOG\.txt$'];
diaryExprsn = ['^DiaryInfo_',baseExprsn,'.*\.xlsx$'];
expression  = {cdfExprsn;csvExprsn;dataExprsn;logExprsn;diaryExprsn};


nFile = numel(file);

for iFile = 1:nFile
    thisFile = file{iFile};
    
    [TF,n,filePath,fileName,tokens] = detectFile(dirPath,listing,expression{iFile});
    
    acsFiles.(thisFile).exists = TF;
    acsFiles.(thisFile).nMatches = n;
    acsFiles.(thisFile).path = filePath;
    acsFiles.(thisFile).name = fileName;
    if ~isempty(tokens)
        acsFiles.(thisFile).subjectID = tokens{1};
        acsFiles.(thisFile).deviceSN  = tokens{2};
    else
        acsFiles.(thisFile).subjectID = '';
        acsFiles.(thisFile).deviceSN  = '';
    end
    
end

end

