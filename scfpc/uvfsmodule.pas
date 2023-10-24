{
 Seksi commander - Virtual File System support
 - class for manage Shared Object

 (C) Radek Cervinka 2003, radek.cervinka@centrum.cz
 released under GNU GPL2

 constributors:

}

unit uVFSmodule;

interface
uses
  uVFSprototypes, uVFStypes, uModuleLoader;

{$H+}
Type
  TVFSModule= Class
  protected
    // module's functions
    FVFSInit:TVFSInit;
    FVFSCaps:TVFSCaps;
    FVFSDestroy:TVFSDestroy;
    FVFSGetExts:TVFSGetExts;
    FVFSOpen: TVFSOpen;
    FVFSClose:TVFSClose;
    FVFSMkDir:TVFSMkDir;
    FVFSRmDir:TVFSRmDir;
    FVFSCopyOut:TVFSCopyOut;
    FVFSCopyIn:TVFSCopyIn;
    FVFSRename:TVFSRename;
    FVFSRun:TVFSRun;
    FVFSDelete:TVFSDelete;
    FVFSList:TVFSList;

    FModuleGlobs:Pointer; // alocated memory for module

    FModuleHandle:TModuleHandle;  // Handle to .DLL or .so

  public
    constructor Create;
    destructor Destroy; override;
    function LoadModule(const sName:String):Boolean;
    procedure UnloadModule;
    function VFSInit:TVFSResult;
    procedure VFSDestroy;
    function VFSCaps(const sExt:String):Integer;

    function VFSGetExts:String;
    function VFSOpen(const sName:String):TVFSResult;
    function VFSClose:TVFSResult;
    function VFSMkDir(const sDirName:String ):TVFSResult;
    function VFSRmDir(const sDirName:String):TVFSResult;
    function VFSCopyOut(const sSrcName, sDstName:String):TVFSResult;
    function VFSCopyIn(const sSrcName, sDstName:String):TVFSResult;
    function VFSRename(const sSrcName, sDstName:String):TVFSResult;
    function VFSRun(const sName:String):TVFSResult;
    function VFSDelete(const sName:String):TVFSResult;
    function VFSList(const sDir:String; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult;
  end;

implementation

constructor TVFSModule.Create;
begin
  FModuleGlobs:=nil;
end;

destructor TVFSModule.Destroy;
begin
  UnloadModule;
  if assigned(FModuleGlobs) then
    FreeMem(FModuleGlobs);
  FModuleGlobs:=nil;  
end;

function TVFSModule.LoadModule(const sName:String):Boolean;
begin
  Result:=uModuleLoader.LoadModule(FModuleHandle, sName);
  // if failed > GetModuleSymbol return nil
  Pointer(FVFSInit):=GetModuleSymbol(FModuleHandle,'VFSInit');
  Pointer(FVFSCaps):=GetModuleSymbol(FModuleHandle,'VFSCaps');
  Pointer(FVFSDestroy):=GetModuleSymbol(FModuleHandle,'VFSDestroy');
  Pointer(FVFSGetExts):=GetModuleSymbol(FModuleHandle,'VFSGetExts');
  Pointer(FVFSOpen):=GetModuleSymbol(FModuleHandle,'VFSOpen');
  Pointer(FVFSClose):=GetModuleSymbol(FModuleHandle,'VFSClose');
  Pointer(FVFSMkDir):=GetModuleSymbol(FModuleHandle,'VFSMkDir');
  Pointer(FVFSRmDir):=GetModuleSymbol(FModuleHandle,'VFSRmDir');
  Pointer(FVFSCopyOut):=GetModuleSymbol(FModuleHandle,'VFSCopyOut');
  Pointer(FVFSCopyIn):=GetModuleSymbol(FModuleHandle,'VFSCopyIn');
  Pointer(FVFSRename):=GetModuleSymbol(FModuleHandle,'VFSRename');
  Pointer(FVFSRun):=GetModuleSymbol(FModuleHandle,'VFSRun');
  Pointer(FVFSDelete):=GetModuleSymbol(FModuleHandle,'VFSDelete');
  Pointer(FVFSList):=GetModuleSymbol(FModuleHandle,'VFSList');
end;

procedure TVFSModule.UnloadModule;
begin
  if FModuleHandle<>INVALID_MODULEHANDLE_VALUE then
    uModuleLoader.UnloadModule(FModuleHandle);
  FModuleHandle:=INVALID_MODULEHANDLE_VALUE;
  Pointer(FVFSInit):=nil;
  Pointer(FVFSCaps):=nil;
  Pointer(FVFSDestroy):=nil;
  Pointer(FVFSGetExts):=nil;
  Pointer(FVFSOpen):=nil;
  Pointer(FVFSClose):=nil;
  Pointer(FVFSMkDir):=nil;
  Pointer(FVFSRmDir):=nil;
  Pointer(FVFSCopyOut):=nil;
  Pointer(FVFSCopyIn):=nil;
  Pointer(FVFSRename):=nil;
  Pointer(FVFSRun):=nil;
  Pointer(FVFSDelete):=nil;
  Pointer(FVFSList):=nil;
end;

function TVFSModule.VFSInit:TVFSResult;
var
  iMemoryNeed:Integer;
begin
  Result:=FVFSInit(iMemoryNeed);
  if Result=cVFS_OK then
    GetMem(FModuleGlobs,iMemoryNeed+2); // for safe 2 bytes, i know C programmers
end;

procedure TVFSModule.VFSDestroy;
begin
  if assigned(@FVFSDestroy) then
    FVFSDestroy(FModuleGlobs);
end;

function TVFSModule.VFSCaps(const sExt:String):Integer;
begin
  Result:= FVFSCaps(FModuleGlobs, PChar(sExt));
end;


function TVFSModule.VFSGetExts:String;
begin
  Result:=FVFSGetExts(FModuleGlobs);
end;

function TVFSModule.VFSOpen(const sName:String):TVFSResult;
begin
  Result:=FVFSOpen(FModuleGlobs,PChar(sName));
end;

function TVFSModule.VFSClose:TVFSResult;
begin
  Result:= FVFSClose(FModuleGlobs);
end;

function TVFSModule.VFSMkDir(const sDirName:String ):TVFSResult;
begin
  Result:=FVFSMkDir(FModuleGlobs,PChar(sDirName));
end;

function TVFSModule.VFSRmDir(const sDirName:String):TVFSResult;
begin
  Result:=FVFSRmDir(FModuleGlobs,PChar(sDirName));
end;

function TVFSModule.VFSCopyOut(const sSrcName, sDstName:String):TVFSResult;
begin
  Result:=FVFSCopyOut(FModuleGlobs,PChar(sSrcName), PChar(sDstName));
end;

function TVFSModule.VFSCopyIn(const sSrcName, sDstName:String):TVFSResult;
begin
  Result:=FVFSCopyIn(FModuleGlobs,PChar(sSrcName), PChar(sDstName));
end;

function TVFSModule.VFSRename(const sSrcName, sDstName:String):TVFSResult;
begin
  Result:=FVFSRename(FModuleGlobs,PChar(sSrcName), PChar(sDstName));
end;

function TVFSModule.VFSRun(const sName:String):TVFSResult;
begin
  Result:=FVFSRun(FModuleGlobs,PChar(sName));
end;

function TVFSModule.VFSDelete(const sName:String):TVFSResult;
begin
  Result:=FVFSDelete(FModuleGlobs,PChar(sName));
end;

function TVFSModule.VFSList(const sDir:String; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult;
begin
  Result:=FVFSList(FModuleGlobs,PChar(sDir),iItemID, VFSItem);
end;

end.
