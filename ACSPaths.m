function [projectDir,originalDir,preflightDir,croppedDir,daysigramDir,compositeDir] = ACSPaths
%ACSPATHS Summary of this function goes here
%   Detailed explanation goes here

projectDir = '\\root\projects\AmericanCancerSociety\DaysimeterData';
originalDir = fullfile(projectDir,'originalData');
preflightDir = fullfile(projectDir,'preflightReports');
croppedDir = fullfile(projectDir,'croppedData');
daysigramDir = fullfile(projectDir,'daysigramReports');
compositeDir = fullfile(projectDir,'compositeReports');

end

