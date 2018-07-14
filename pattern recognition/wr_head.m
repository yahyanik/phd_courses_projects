 function wr_head(fil_nam, fil_typ, fil_hd, flag)

 % Program to write the header for the TypeA1 and TypeB1 and HTK
 % file for the Tfrontm
 % Programmer : Jaishree. V.
 % Date       : 10\24\99
 %            : 11-23-99 Montri K. -- add HTK file type
 %            : 02-14-00 Montri K. -- add flag, to allow updating file header only
 % Version    : 0.3
 % 
 %  function wr_head(fil_nam, fil_typ, fil_hd, flag)
 % 
 % Inputs are 
 % fil_nam     - Name  of the output file
 % fil_typ     - Type of the file(TYPEA1 or TYPEB1)
 % fil_hd(1)   - rec_len ( for TYPEB1 files )
 % fil_hd(2)   - Ncat - number of categories
 % fil_hd(3)   - Nvar ( Number of variables )
 % fil_hd(4)   - Number of tokens 
 % fil_hd(5)   - Frame rate (in ms) for HTK type
 % flag        - 0: create new file (default)
 %               otherwise: update header only
 %
 % The header format for the TYPEA1 and  TYPEB1 files are
 % 
 %  TYPEA1  |  TYPEB1  -  specifies the type of the file                
 %      12  |      21  -  Rec_len(12 - TYPEA1, >= Nvar +11 - TYPEB1) 
 %       1  |       1  -  Number of records
 %       1  |       1  -  Number of categories
 %      10  |      10  -  Number of variables
 %       4  |       4  -  Number of tokens
 %
 %
 % Header for HTK:  
 %  int32: number of frames
 %  int32: frame rate in 100ns unit
 %  int16: number of features in each frame
 %  int32: parameter kind (9 for USER, pg. 75 HTK book)
 %
 %
 % In this version (11-23-99) it does nothing if file type = HKT
 
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
   disp 'Usage: wr_head(fil_nam, fil_typ, fil_hd, flag)'
   return
end

% set flag to 0 ( overwritten mode) if flag is not specified
if nargin == 3
   flag = 0;
end

% select appropriate open mode
if flag == 0
   open_mode = 'w';
else
   open_mode = 'r+';
end

 
 %  Code to check the file type
 
 if strcmp(fil_typ,'TYPEB1') 
    
   if fil_hd(1) < fil_hd(3)+11
      Rec_len=fil_hd(3)+11;
      fil_hd(1)=Rec_len;
   else
      Rec_len=fil_hd(1);
   end
 
   Nrec=(9 + 2 * fil_hd(2) + Rec_len ) / Rec_len;
 
% Code to open the file and write the file header 
 
   fid=fopen(fil_nam, open_mode);
   fprintf(fid,'%6s\r\n%6d\r\n%6d\r\n%6d\r\n%6d\r\n%6d\r\n','TYPEB1',...
   Rec_len,floor(Nrec),fil_hd(2),fil_hd(3),fil_hd(4));

% Code to pad the header with spaces

   hd_len=floor(Nrec) * Rec_len * 4 ;
   filled = 40 + fil_hd(2) * 8;
   skip=hd_len-filled;
   a=' ';
   a(1:skip)=a;
   fwrite(fid,a);
   fclose(fid);
 
elseif strcmp(fil_typ, 'TYPEA1')
      
      
% Code to write the header for TYPEA1 file
      
   Rec_len=12;
   Nrec=(9 + 2 * fil_hd(2) + Rec_len ) / Rec_len;
   
% Code to open the file and write the file header 

   fid=fopen(fil_nam, open_mode);
  
   fprintf(fid,'%6s\r\n%6d\r\n%6d\r\n%6d\r\n%6d\r\n%6d\r\n','TYPEA1',Rec_len,...
   floor(Nrec),fil_hd(2),fil_hd(3),fil_hd(4));
   fclose(fid);
   
elseif strcmp(fil_typ, 'HTK')
      
   % do nothing for HTK      
      
end; 
     
