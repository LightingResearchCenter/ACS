function varargout = binaryComparison
%BINARYCOMPARISON Summary of this function goes here
%   Detailed explanation goes here

defaultDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
selectedDir = uigetdir(defaultDir,'Select folder of files to compare.');
if selectedDir == 0;
    return;
end
listing = dir([selectedDir,filesep,'*DATA.txt']);
fileNameArray = {listing(:).name};
filePathArray = fullfile(selectedDir,fileNameArray);
varNameArray = matlab.lang.makeValidName(regexprep(fileNameArray,'([^a-zA-Z0-9]*)','_'));

T = initTable(varNameArray);

n = numel(listing);

for i1 = 1:n
    for j1 = 1:n
        if j1 == i1
            continue;
        end
        filePath1 = filePathArray{i1};
        filePath2 = filePathArray{j1};
        if isDiff(filePath1,filePath2)
            T.(j1)(i1) = {'diff'};
        else
            T.(j1)(i1) = {'same'};
        end
    end
end

if nargout == 1
    varargout = T;
else
    excelPath = fullfile(selectedDir,'comparison.xlsx');
    writetable(T,excelPath,'WriteRowNames',true);
    winopen(excelPath);
end

end

function T = initTable(varNameArray)

n = numel(varNameArray);
T = cell2table(cell(n,n));
T.Properties.VariableNames = varNameArray;
T.Properties.RowNames = varNameArray;
T.Properties.DimensionNames = {'file1','file2'};

end

function TF = isDiff(filePath1,filePath2)
file_1 = javaObject('java.io.File', filePath1);
file_2 = javaObject('java.io.File', filePath2);
TF = ~javaMethod('contentEquals','org.apache.commons.io.FileUtils',file_1, file_2);
end