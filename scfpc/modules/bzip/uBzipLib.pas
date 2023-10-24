unit uBzipLib;
{
 gzip helper rutines
}

interface
uses
  uVFStypes;
type
  TBzipGlobs=record
    sBzipName:String;
    iBzipHandle:Integer;
    bOpened: Boolean;
  end;
  PBzipGlobs=^TBzipGlobs;


Function OpenBzipRO(g:PBzipGlobs; const sFileName:String):Boolean;

function FindNextDir(g:PBzipGlobs;var item:TVFSItem): Boolean;


implementation

uses
  SysUtils;


function ChangeName(const sFileName:String):String;
var
  sExt:String;
  i:Integer;
begin
  sExt:='';
  Result:=sFileName;
  for i:=length(sFileName) downto 1 do
    if sFileName[i]='.' then
    begin
      sExt:=lowercase(Copy(sFileName,i,length(sFileName)-i+1));
      Break;
    end;
   if sExt='' then
     Exit;
   if sExt='.bz2' then
     Result:=Copy(sFileName,1,length(sFileName)-4);
end;


Function OpenBzipRO(g:PBzipGlobs; const sFileName:String):Boolean;
begin
  with g^ do
  begin
    iBzipHandle:=FileOpen(sFileName, fmOpenRead);
    sBzipName:=sFileName;
    Result:=iBzipHandle>-1;
    bOpened:=Result;
  end;
end;

function FindNextDir(g:PBzipGlobs; var item:TVFSItem): Boolean;
var
  Head: packed Array[0..2] of Char;
  iReaded:Integer;
begin
  with g^ do
  begin
    Result:=False;
    if not bOpened then Exit;
    iReaded:=FileRead(iBzipHandle,Head,3);
    if iReaded<>3 then Exit;
    if (head[0]<>'B') or (head[1]<>'Z') or (head[2]<>'h') then Exit;
    item.sFileName:=ChangeName(sBzipName);
    // stat to other
    item.m_time:=0;
    item.iSize:=0;
    item.a_time:=0;
    item.c_time:=0;
    item.iUID:=0;  
    item.iGID:=0;
    item.iMode:=0;
    item.sLinkTo:='';
    item.ItemType:=vRegular;    
  end;
  Result:=True;
end;
end.
