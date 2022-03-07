%% This function is used to import the block model file and computation parameter file to framework
%  Option1: Datamine; Option2: GeoviaWhittle; Option3: Computation Parameters; 
%  2021 © C. Zhang

function Value = Import_File(option, type)

% Input
%   option : The type of the imported file
%   type   : The rock types option for the imported file(GeoviaWhittle input argument)

% Output
%	Value : The data of the imported file

  switch option
      
      case ('Datamine')
          
          %Open specific folder location of block model file
          [datamine.filename, pathname] = uigetfile('*.csv','Select the block model file from BM_File\Datamine folder');
          pathname          = string(pathname); %The position of selected file
          datamine.filename = string(datamine.filename); %The selected block model file to be calculated

          if isequal(datamine.filename,0)||isequal(pathname,0)
              return
          else
              datamine.fileText.Value = pathname + datamine.filename;
          end
          
          Value = readtable(datamine.fileText.Value); %read the attributes from block model file and import to the framework
          
      case ('GeoviaWhittle')
          
          switch type
              
              case ('Single')
                  
                  %Open specific folder location of block model file
                  [geoviawhittle.filename, pathname] = uigetfile('*.csv','Select the block model file from BM_File\GeoviaWhittle\Single folder');
                  pathname               = string(pathname); %The position of selected file
                  geoviawhittle.filename = string(geoviawhittle.filename); %The selected block model file to be calculated

                  if isequal(geoviawhittle.filename,0)||isequal(pathname,0)
                      return
                  else
                      geoviawhittle.fileText.Value = pathname+geoviawhittle.filename;
                  end
        
                  Value = readtable(geoviawhittle.fileText.Value); %read the attributes from block model file and import to the framework
                  
              case ('Multiple')
                  
                  %Open specific folder location of block model file
                  [geoviawhittle.filename, pathname] = uigetfile('*.csv','Select the block model file from BM_File\GeoviaWhittle\Multiple folder');
                  pathname               = string(pathname); %The position of selected file
                  geoviawhittle.filename = string(geoviawhittle.filename); %The selected block model file to be calculated

                  if isequal(geoviawhittle.filename,0)||isequal(pathname,0)
                      return
                  else
                      geoviawhittle.fileText.Value = pathname+geoviawhittle.filename;
                  end
        
                  Value = readtable(geoviawhittle.fileText.Value); %read the attributes from block model file and import to the framework
          end
          
      case ('Computation parameter')
          
          %Open specific folder location of computation parameter file
          [para.filename, pathname] = uigetfile('*.xlsx','Select the computation parameter file from CP_File folder');
          pathname          = string(pathname);
          para.filename = string(para.filename);

          if isequal(para.filename,0)||isequal(pathname,0)
              return
          else
              para.fileText.Value = pathname + para.filename;
          end
          
          Value = readtable(para.fileText.Value); %read the parameters from file and import them into the framework
          
      otherwise
          error('Wrong import file type!')
          
  end

end