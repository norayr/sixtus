{
  tar module for VFS in Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}
unit uVFStar;

interface
uses
  uVFStypes, utarlib;
{ generic function about module
  cdecl is calling convention from C language }
type


  TVFSGlobs=PTarGlobs;   // retype TVFSGlobs from pointer

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
  iMemoryNeed:=SizeOf(TTarGlobs);
  Result:=cVFS_OK;
end;

function VFSCaps(g:TVFSGlobs; const sExt:PChar):Integer;
begin
  if sExt='.tar' then
    Result:=capVFS_List or capVFS_CopyOut or capVFS_CopyIn or
      capVFS_MkDir or capVFS_RmDir or capVFS_Multiple or capVFS_Delete
//      or capaVFS_Rename
  else
    Result:=capVFS_nil;
end;

procedure VFSDestroy(g:TVFSGlobs);
begin

end;

function VFSGetExts(g:TVFSGlobs):PChar;
begin
  Result:='.tar;';
end;

function VFSOpen(g:TVFSGlobs; const sName:PChar):TVFSResult;
begin
  Result:=cVFS_Failed;
  if OpenTarRO(g,sName) then
    Result:=cVFS_OK;
end;

function VFSClose(g:TVFSGlobs):TVFSResult;
begin
  with g^ do
  begin
    dispose(TarRec);
    if iTarHandle>-1 then
      FileClose(iTarHandle);
    bOpened:=False;
  end;
  Result:=cVFS_OK;
end;

function VFSMkDir(g:TVFSGlobs; const sDirName:PChar ):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSRmDir(g:TVFSGlobs; const sDirName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSCopyOut(g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSCopyIn (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
  // tar -r
end;

function VFSList (g:TVFSGlobs; const sDir:PChar; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult; cdecl;
begin
  if iItemID=0 then
    with g^ do
    begin
      FileSeek(iTarHandle,0,0);
      iBytesToSkip:=0;
    end;
  Result:=cVFS_Not_More_Files;
  if FindNextDir(g,VFSItem) then
    Result:=cVFS_OK;
end;

function VFSDelete (g:TVFSGlobs; const sName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSRename (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_OK;
end;

function VFSRun (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
begin
  Result:=cVFS_OK;
end;


end.
