function [y] = rd_feat(filename)
% RD_FEAT Read feature file
%   [y] = rd_feat(filename) Reads ECE Speech Lab's feature file
%   (TYPEBA1 and TYPEB1).
%
% INPUTS:
%   filename -- feature file
% OUTPUTS:
%   y  -- output data, an NFRAME x NVAR matrix possible future outputs
%
%  NOTES:
%     *** This version works with one-token files only. ***
% 	   *** If the file contains more than 1 token, only  ***
%     *** first token will be read.                     ***  

%   Creation date: 10-19-99 
%   Revision date: July 1, 2007
%   Programmer: Montri Karnjanadecha, Hongbing Hu

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

if nargout ~= 1
   error('Only 1 output argument is supports in this version');
end

fp = fopen(filename, 'rt');
if (fp == -1)
    error('Cannot open %s!\n', filename);
end

filetype = fgetl(fp);
switch upper(filetype)
 case {'TYPEA1'} % TYPEA1 for ascii file
  reclen= fscanf(fp, '%f',1);	% skip reclen
  nrec  = fscanf(fp, '%f',1);	% skip # of rec
  ncat  = fscanf(fp, '%f',1);	% skip # of cat
  nvar  = fscanf(fp, '%f',1);	% read NVAR
  ntok  = fscanf(fp, '%f',1);  % read # of tok 
  
  if ncat > 1
      fclose(fp);
      error('Does not support multi-category!');
  end
  if ntok > 1
      warning('There are more than 1 token in this file');
      warning('Only the first token will be read');
  end
  
  dummy = fscanf(fp,'%f',1);	      % ignore token counter
  nfrm  = fscanf(fp,'%f',1);	      % read nfrm
  dummy = fgets(fp);	              % skip the rest 
  
  % now read data;
  y = zeros(nfrm, nvar);
  onerow = zeros(1,nvar);
  for i=1:nfrm
      [onerow count] = fscanf(fp,'%f',nvar);
      if (count ~= nvar)
          fclose(fp);
          error('Error reading data');
      end
      y(i,:) = onerow';
  end
  % end TYPEA1, ascii case
     
 case {'TYPEB1'} % TYPEA1 for binary file
  reclen= fscanf(fp, '%f',1);	% skip reclen
  nrec  = fscanf(fp, '%f',1);	% skip # of rec
  ncat  = fscanf(fp, '%f',1);	% skip # of cat
  nvar  = fscanf(fp, '%f',1);	% read NVAR
  ntok  = fscanf(fp, '%f',1);  % read # of tok 
  
  if ncat > 1
      fclose(fp);
      error('Does not support multi-category!');
  end
  if ntok > 1
      warning('There are more than 1 token in this file');
      warning('Only the first token will be read');
  end
  
  fclose(fp);
  fp = fopen(filename, 'rb');
  fseek(fp, nrec*reclen*4 + 4, 'bof'); % skip file header + token counter
  
  % read token header
  [nfrm, count] = fread(fp, 1, 'int32', 4+32); 
  % read nfrm and skip nvar & token id
  
  % initialized data array, y
  y = zeros(nfrm, nvar);
  onerow = zeros(1,nvar);
  
  % now read data
  for i=1:nfrm
      [onerow,count] = fread(fp, nvar, 'float32');
      if (count ~= nvar)
          fclose(fp);
          error('Error reading data');
      end
      y(i,:) = onerow';
  end
  %End TYPEB1 binary case
  
 case {'XAO1'} % XAO1 type for CSTR FDA evalution database pitch
  % Some parameters
  interval = 10;  % 10 ms 
  uvspace  = 0.5;  % the space between the vocied and unvoiced region  
  
  % Skip the header
  while(~feof(fp)) 
      ldata = fgetl(fp);
      if (strcmp(ldata, char(12)))  % 12(Ctrl-L), the end character of header
          break;
      end;
  end;
  
  % Read the data
  yy(:,1) = [0, 0];
  uvflag = 1;
  cnt = 2;
  while(~feof(fp))
      ldata = fgetl(fp);
      % interpret '=' to the [time 0] format
      if( ldata == '=')
          yy(:,cnt) = [ytmp(1)+uvspace, 0];
          cnt = cnt + 1;
          uvflag = 1;
      elseif (~strcmp(ldata,''))
          ytmp = sscanf(ldata, '%f', 2);
          if uvflag
              yy(:,cnt) = [ytmp(1)-uvspace, 0];
              cnt = cnt + 1;
              uvflag = 0;
          end;
          yy(:,cnt)= ytmp;
          cnt = cnt + 1;
      end;
  end;
  % zero pad the last data
  yy(:,cnt) = [ytmp(1)+uvspace, 0];
  
  % interpolation to the specified interval and length
  % yi = 0:interval:tlength;
  yi = 0:interval:yy(1,length(yy));
  y = interp1(yy(1,:), yy(2,:), yi, 'nearest');
  
 otherwise
  fclose(fp);
  error('Unknown file type: %s!\n', filetype);
end

fclose(fp);
