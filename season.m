function [s,varargout] = season(t)
%SEASON Summary of this function goes here
%   Detailed explanation goes here

% Define seasons
JuneSolstice2015     = datetime(2015,  6, 21, 12, 38, 0, 'TimeZone', 'America/New_York');
SeptemberEquinox2015 = datetime(2015,  9, 23,  4, 20, 0, 'TimeZone', 'America/New_York');
DecemberSolstice2015 = datetime(2015, 12, 21, 23, 48, 0, 'TimeZone', 'America/New_York');
MarchEquinox2016     = datetime(2016,  3, 20,  0, 30, 0, 'TimeZone', 'America/New_York');
JuneSolstice2016     = datetime(2016,  6, 20, 18, 34, 0, 'TimeZone', 'America/New_York');
SeptemberEquinox2016 = datetime(2016,  9, 22, 10, 21, 0, 'TimeZone', 'America/New_York');
DecemberSolstice2016 = datetime(2016, 12, 21,  5, 44, 0, 'TimeZone', 'America/New_York');

% Spring
idxSpring = t >= MarchEquinox2016 & t < JuneSolstice2016;

% Summer
idxSummer2015 = t >= JuneSolstice2015 & t < SeptemberEquinox2015;
idxSummer2016 = t >= JuneSolstice2016 & t < SeptemberEquinox2016;
idxSummer = idxSummer2015 | idxSummer2016;

% Autumn
idxAutumn2015 = t >= SeptemberEquinox2015 & t < DecemberSolstice2015;
idxAutumn2016 = t >= SeptemberEquinox2016 & t < DecemberSolstice2016;
idxAutumn = idxAutumn2015 | idxAutumn2016;

% Winter
idxWinter = t >= DecemberSolstice2015 & t < MarchEquinox2016;

% Combine into output
s = cell(size(t));
s(idxSpring) = {'spring'};
s(idxSummer) = {'summer'};
s(idxAutumn) = {'autumn'};
s(idxWinter) = {'winter'};

varargout = {idxSpring,idxSummer,idxAutumn,idxWinter};

end

