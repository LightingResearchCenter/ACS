fclose all
close all
clear
clc

addpath('C:\Users\jonesg5\Documents\GitHub\d12pack')

filePath = '\\root\projects\AmericanCancerSociety\DaysimeterData\Q4\A18845\best_download\A18845_SEP16_198.cdf';

[log_info,data_log] = cdf2raw(filePath);

