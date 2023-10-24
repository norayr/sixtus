unit uGlobsPaths;

interface
var

  gpExePath:String ='';
 {gpVFSDir= './vfs/'; // path to vfs scripts
  gpIniDir='./'; // local for user
  gpCfgDir='./'; // global for all user
  gpLngDir='./lng/'; // path to lng files
  }
  gpVFSDir:String ='';

  gpIniDir:String =''; // local for user
  gpCfgDir:String =''; // global for all user
  gpLngDir:String =''; // path to lng files
  gpPixmapPath:String ='';

procedure LoadPaths;

implementation
uses
  SysUtils;

procedure LoadPaths;
begin
  gpExePath:=ExtractFilePath(ParamStr(0));
  Writeln('executable directory:',gpExePath);

//  gpExePath:=gpExePath+'/';
  gpVFSDir:=gpExePath+'modules/bin/';
  gpIniDir:=gpExePath;
  gpCfgDir:=gpExePath;
  gpLngDir:=gpExePath+'lng/';
  gpPixmapPath:= gpExePath +'pixmap/';
  writeln('VFS directory:', gpVFSDir);
end;

end.
