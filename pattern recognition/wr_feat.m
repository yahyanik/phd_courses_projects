function [] = wr_feat(feat, filename, filetype, frame_space)
% WR_FEAT Write feature file
%   [] = wr_feat(feat, filename, filetype) Writes ECE Speech Lab's
%   feature file (TYPEBA1 and TYPEB1).
%
% INPUTS:
%   filename: The name of feature file
%   feat:     feature array
%   filetype: The file type of feature file
%
% OUTPUTS:
%   None

%   Creation date:  July 12, 2007
%   Programmer   :  Hongbing Hu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     This file is a part of the YAAPT program, designed for a fundamental 
%   frequency tracking algorithm that is extermely robust for both high quality 
%   and telephone speech.  
%     The YAAPT program was created by the Speech Communication Laboratory of
%   the state university of New York at Binghamton. The program is available 
%   at http://www.ws.binghamton.edu/zahorian as free software. Further 
%   information about the program could be found at "A spectral/temporal 
%   method for robust fundamental frequency tracking," J.Acosut.Soc.Am. 123(6), 
%   June 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    filetype = 'TYPEA1';
end
if nargin < 4
    frame_space = 0;
end

Num_features  =  size(feat, 2);
% Num_features = 1;
iTok          =  1;
Num_frames    = size(feat, 1);
FileHdr       = [12; 1;  Num_features; 1; frame_space];

% create a new output file with header ready
wr_head(filename, filetype, FileHdr, 0);

% prepare to write features to file, we need only last 32 characters
TokenID = ['                                  ', filename];
TokenID = TokenID(length(TokenID)-31:length(TokenID)); 

% write feature into file
wr_token(filename, filetype, FileHdr, [iTok;Num_frames], TokenID, feat);
