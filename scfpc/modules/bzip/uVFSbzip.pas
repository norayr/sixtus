{
  gzip module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}
unit uVFSbzip;

interface
uses
  uVFStypes, uBzipLib;
{ generic function about module
  cdecl is calling convention from C language }
type

  TVFSGlobs=PBzipGlobs;   // retype TVFSGlobs from pointer

function VFSInit(Var iMemoryNeed:Integer):TVFSResult; cdecl;
{VFSInit is usefull for finding helpers library, or load cfg.
 If Result is cVFS_Failed, then library is unloaded and ignored at run.
 iMemoryNeed is allocated by SeksiCommander and
 passed VFSGlobs is pointer to this memory place - needed for thread safe and so
}

function VFSCaps(g:TVFSGlobs; const sExt:PChar):Integer; cdecl;
// return capabilities for ext (.tar), sc only call procedures marked by this return value

procedure VFSDestroy(g:TVFSGlobs); cdecl;
// called at the end, unload helper libraries, but NOT freemem for g
function VFSGetExts(g:TVFSGlobs):PChar; cdecl;
// result is in this form: .zip;.gzip;.gz; - last must be ; (lowercase)

function VFSOpen(g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
// handle (if any needed) must be stored in g!

function VFSClose(g:TVFSGlobs):TVFSResult;cdecl;

function VFSMkDir(g:TVFSGlobs; const sDirName:PChar ):TVFSResult; cdecl;
function VFSRmDir(g:TVFSGlobs; const sDirName:PChar):TVFSResult; cdecl;
function VFSCopyOut(g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;
function VFSCopyIn (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;
function VFSRename (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;

function VFSRun (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;

function VFSDelete (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
function VFSList (g:TVFSGlobs; const sDir:PChar; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult; cdecl;
{ iItemID is only for information, but 0 mark new listing
  in some cases is iItemID needed (virtually generated items - like for RPM)
  capaVFS_ListByDir and sDir is reserved for future use
}

implementation
uses
  SysUtils;

function VFSInit(Var iMemoryNeed:Integer):TVFSResult;
begin
  iMemoryNeed:=SizeOf(TBzipGlobs);
  Result:=cVFS_OK;
end;

function VFSCaps(g:TVFSGlobs; const sExt:PChar):Integer;
begin
  if (sExt='.bz2') then
    Result:=capVFS_List or capVFS_CopyOut
  else
    Result:=capVFS_nil;
end;

procedure VFSDestroy(g:TVFSGlobs);
begin

end;

function VFSGetExts(g:TVFSGlobs):PChar;
begin
  Result:='.bz2;';
end;

function VFSOpen(g:TVFSGlobs; const sName:PChar):TVFSResult;
begin
  Result:=cVFS_Failed;
  if OpenBzipRO(g,sName) then
    Result:=cVFS_OK;
end;

function VFSClose(g:TVFSGlobs):TVFSResult;
begin
  with g^ do
  begin
    if iBzipHandle>-1 then
      FileClose(iBzipHandle);
    bOpened:=False;
  end;
  Result:=cVFS_OK;
end;

function VFSMkDir(g:TVFSGlobs; const sDirName:PChar ):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

function VFSRmDir(g:TVFSGlobs; const sDirName:PChar):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

function VFSCopyOut(g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSCopyIn (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

function VFSList (g:TVFSGlobs; const sDir:PChar; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult; cdecl;
begin
  Result:=cVFS_Not_More_Files;
  if iItemID=0 then
    with g^ do
    begin
      FileSeek(iBzipHandle,0,0);
    end
  else
    Exit; // only 1 file in bzip  
  if FindNextDir(g,VFSItem) then
    Result:=cVFS_OK;
end;

function VFSDelete (g:TVFSGlobs; const sName:PChar):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

function VFSRename (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

function VFSRun (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
begin
  Result:=cVFS_Not_Supported;
end;


end.
