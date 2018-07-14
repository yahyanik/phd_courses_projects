                                                                     
                                                                     
                                                                     
                                             
function[] = wr_token(fil_nam,fil_typ,fil_hd,tok_hd,Tagnam,X)
% WR_TOKEN Write the tokens for the TypeA1, TypeB1 and HTK
%
% function[]=wr_token(fil_nam,fil_typ,fil_hd,tok_hd,Tagnam(id,:),X)
% Program to write the tokens for the TypeA1, TypeB1 and HTK
% 
% Inputs are 
% fil_nam      -  Name  of the output file
% fil_typ      -  Type of the file(TYPEA1 or TYPEB1, or HTK)
% fil_hd(1)    -  rec_len ( record length for binary files )
% fil_hd(2)    -  Ncat ( Number of categories )
% fil_hd(3)    -  Nvar ( Number of variables )
% fil_hd(4)    -  Number of tokens 
% fil_hd(5)    -  Frame rate (in ms) for HTK type
% tok_hd(1)    -  Index
% tok_hd(2)    -  Number of frames for each token
% Tagnam(id,:) -  32 character ASCII label for one token(stimulus)
% X            -  Data matrix of parameter values for one token (nVar x nFrm)
% 
% The token format for the TYPEA1 and TYPEB1 files are
%    1    4    10 j:\temp\files\sx123 vowel de     - Token header
% Index(4) Nframes(4) Nvar(4) Tagnam(32) size are given in braces  
%   Data is written in floating point 32 numbers
%
%   In TYPEA1 the data is displayed as 5 columns for ease of use
% file for the Tfrontm
%
%
%  HTK type: We need to swap data bytes for HTK file format. There is 
%            no Matlab functions to do this. A trick is to write the feature
%            file normally. Then read in the data in the file in 'char' format
%            (byte-by-byte reading) in to a 4xN matrix. Next swap rows then write
%            the data back to file.
%          : As of 1-5-00, no byte swaping is perform with HTK file format. This will
%            make code run faster. However, NATURALREADORDER and NATURALWRITEORDER 
%            parameters must be set to TRUE in HTK tools' command file. See HTK manual
%            for more detail.

% Programmer : Jaishree. V.
% Date       : 10\24\99
% Revision   : 11-15-99  Montri K.
%            : 11-23-99  Montri K. -- add HTK file type
%            : 1-5-00    Montri K. -- no byte swapng for HTK file type
% Version    : 0.4

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

% The file is opened with append permission to append the tokens

% Initializing the variables
Nframes=tok_hd(2);
Rec_len=fil_hd(1);
 
% To check the file type 
 
switch upper(fil_typ)
 case 'TYPEB1'
    
  fid=fopen(fil_nam,'a'); % append
                          % Code to write the token header for TYPEB1 file
  Nrec=floor((10 + (Nframes * fil_hd(3)) + Rec_len)/Rec_len);
  fwrite(fid,tok_hd(1),'integer*4');
  fwrite(fid,Nframes,'integer*4');
  fwrite(fid,Nrec,'integer*4');
  
  % Tagnam must have 32 chars
  if length(Tagnam) ~= 32
      Tagnam = ['                                  ', Tagnam]; 
      Tagnam = Tagnam(length(Tagnam)-31:length(Tagnam));
  end
  
  fwrite(fid,Tagnam,'uchar');
  
  % write all frames at one time
  fwrite(fid,X(1:fil_hd(3),1:Nframes),'float32');
  
  % Code to fill the rest of the token(record) with zeros if
  % the data written < rec_len * Nrec
  fwrite(fid, zeros(Rec_len*Nrec - Nframes*fil_hd(3)-11,1) ,'float32');
  fclose(fid);
  
 case 'TYPEA1'
  
  fid=fopen(fil_nam,'a'); % append
                          %  Code to write the token for the TYPEA1 file
  fprintf(fid,'%6d%6d%6d %s\r\n',tok_hd(1),Nframes,fil_hd(3),Tagnam);
  
  %  Code to write and format the data in 5 columns
  %  Each frame starts in a new line          
  for j = 1:tok_hd(2)
      for  k = 1:fil_hd(3)
          if k<4
              fprintf(fid, '%17d', X(j,k));
          elseif k==3
              fprintf(fid, '%17d', X(j,k),0,0);
          else
              fprintf(fid, '%17.4f', X(j,k));
          end
          if ~rem(k+2,5)
              fprintf(fid, '\r\n');
          end
      end
      % add new line if (#var % 5) ~= 0
      if rem(fil_hd(3),5)
          fprintf(fid, '\r\n');
      end
  end
  fclose(fid);
  
 case 'HTK'
  fid = fopen(fil_nam, 'wb');
  fwrite(fid, tok_hd(2), 'int32');  % num frames
  fwrite(fid, fil_hd(5) * 10000, 'int32'); % frame rate in 100 ns unit
  fwrite(fid, fil_hd(3) * 4, 'int16');  % number of features per frame
  fwrite(fid, 9, 'int16');          % parameter kind (USER)
  
  fwrite(fid,X(1:fil_hd(3),1:Nframes),'float32');
  fclose(fid);
  
  % The rest of the code is used to perform byte swaping
  % we don't need it now.
  %   
  %   FileSize = 12 + fil_hd(3)*Nframes*4;
  %   
  %   % re-open the file
  %   fid = fopen(fil_nam, 'rb');
  %   d=fread(fid, FileSize, 'uchar');
  %   fclose(fid);
  %   d = reshape(d,4,FileSize/4);
  %   d = [d(4,:); d(3,:); d(2,:); d(1,:)];
  %   
  %   % Some header infor are 16 bits, make sure that they are properly swapped
  %   tmp = d(1:2,3);
  %   d(1:2,3) = d(3:4,3);
  %   d(3:4,3) = tmp;
  %   
  %   % now write swapped version
  %   fid = fopen(fil_nam, 'wb');
  %   fwrite(fid, d, 'uchar');
  %   fclose(fid);

 otherwise
  error('Unknown output file type "%s"', fil_typ);
end

   

