{
  rpm module for VFS in Seksi Commander
  GNU GPL 2

  (C) Radek Cervinka 2003, radek.cervinka@centrum.cz

  based on wc_rpm-1.5-src.zip (plugin for Total Commander)
  // Copyright (C) 2000 Mandryka Yurij  e-mail:braingroup@hotmail.ru

  version 0.1 - first version (list, copyout, run)

}
unit uVFSrpm;

interface
uses
  uVFStypes, uRPMLib;
{ generic function about module
  cdecl is calling convention from C language }
type

  TVFSGlobs=PRpmGlobs;   // retype TVFSGlobs from pointer

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
  SysUtils {$IFDEF LINUX}, Libc{$ENDIF};

const
  csInst='install';
  csUpgrade='upgrade';
  csInfo='info.txt';

function VFSInit(Var iMemoryNeed:Integer):TVFSResult;
begin
  iMemoryNeed:=SizeOf(TRPMGlobs);
  Result:=cVFS_OK;
end;

function VFSCaps(g:TVFSGlobs; const sExt:PChar):Integer;
begin
  if (sExt='.rpm')then
    Result:=capVFS_List or capVFS_CopyOut
 {$IFDEF LINUX} or capVFS_Execute{$ENDIF}
  else
    Result:=capVFS_nil;
end;

procedure VFSDestroy(g:TVFSGlobs);
begin

end;

function VFSGetExts(g:TVFSGlobs):PChar;
begin
  Result:='.rpm;';
end;

function VFSOpen(g:TVFSGlobs; const sName:PChar):TVFSResult;
begin
  Result:=cVFS_Failed;
  if OpenRpmRO(g,sName) then
    Result:=cVFS_OK;
end;

function VFSClose(g:TVFSGlobs):TVFSResult;
begin
  with g^ do
  begin
    if iRpmHandle>-1 then
      FileClose(iRpmHandle);
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
var
  fOut:Integer;
  buf:Pointer;
  iRead:Integer;
  s:String;
begin
  Result:=cVFS_OK;
  //must handle virtually files first
  if sSrcName=csInfo then
  begin
    fOut:=FileCreate(String(sDstName));
    if fOut=-1 then
      Result:=cVFS_Failed
    else
    begin
      s:=InfoString(g.info);
      FileWrite(fOut,s[1],length(s));
      FileClose(fOut);
    end;
    Exit;
  end;

  if (sSrcName=csInst) or (sSrcName=csUpgrade) then
  begin
    // file install and upgrade not copy
    Result:=cVFS_OK;
    Exit;
  end;
  // now must copy file
  with g^ do
  begin
    fOut:=FileCreate(String(sDstName));
    if fOut=-1 then
      Result:=cVFS_Failed
    else
    begin
      writeln(FileSeek(iRpmHandle,iDataPosition,0));
      GetMem(buf,32768);
      repeat
        iRead:=FileRead(iRpmHandle,buf^,32768);
        if iRead>0 then
          FileWrite(fOut,buf^,iRead);
      until iRead<=0;
      FreeMem(buf);
      FileClose(fOut);
    end;
  end;
end;

function VFSCopyIn (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult;
begin
  Result:=cVFS_Not_Supported;
end;

procedure VirtualFile(Var VFSItem:TVFSItem; iItemID:Integer);
begin
  with VFSItem do
  begin
    iSize:=0;
    if iItemID>1 then
      iMode:=0  // r-xr-xr-x
    else
      iMode:=0; // r--r--r--
    sLinkTo:='';
    iUID:=0;
    iGID:=0;
    ItemType:=vRegular;
    m_time:=0;
    a_time:=0;
    c_time:=0;
    case iItemID of
      1: sFileName:=csInfo;
      2: sFileName:=csInst;
      3: sFileName:=csUpgrade;
    end;
  end;
end;

function VFSList (g:TVFSGlobs; const sDir:PChar; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult; cdecl;
begin
  Result:=cVFS_Not_More_Files;
  if iItemID=0 then
  begin
{    with g^ do
      FileSeek(iRpmHandle,0,0);}
    if FindNextDir(g,VFSItem) then
      Result:=cVFS_OK;
    Exit;
  end;
  Result:=cVFS_OK;
  case iItemID of
    1: VirtualFile(VFSItem,1); // info file
  {$IFDEF LINUX}
    2,3: VirtualFile(VFSItem,iItemID); // install, upgrade
  {$ENDIF}
  else
    Result:=cVFS_Not_More_Files;
  end;
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
  // must handle virtually files install, upgrade
  {$IFDEF LINUX}
  Result:=cVFS_OK;
  if sName=csInst then
    Libc.System(PChar('rpm -i '+sName)) // maybe > /dev/null or file
  else
    if sName=csUpgrade then
      Libc.System(PChar('rpm  -Uh '+sName))
    else
  {$ENDIF}
     Result:=cVFS_Not_Supported;
end;

end.
