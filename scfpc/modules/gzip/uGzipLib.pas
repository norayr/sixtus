unit uGzipLib;
{
 gzip helper rutines
}

interface
uses
  uVFStypes;
type
  TGzipGlobs=record
//my globs, thread safe
//    iTarPosition:Int64;
    sGzipName:String;
    iGzipHandle:Integer;
    bOpened: Boolean;
  end;
  PGzipGlobs=^TGzipGlobs;


Function OpenGzipRO(g:PGzipGlobs; const sFileName:String):Boolean;

function FindNextDir(g:PGzipGlobs;var item:TVFSItem): Boolean;


implementation

uses
  SysUtils;

type
  TGzipHead= packed Record
    IDs:Word; // 2 bytes of header (ID1, ID2 by RFC)
    CM: Byte; // 1 byte for compression method
    FLG:Byte; // 1 byte for Flag
    MTime:Integer; // Modification Time
    XFL: Byte;  // extra flag
    OS: Byte;  // operating system
  end;

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
   if sExt='.tgz' then
   begin
     Result:=Copy(sFileName,1,length(sFileName)-3)+'tar';
     Exit;
   end;
   if sExt='.gz' then
     Result:=Copy(sFileName,1,length(sFileName)-3);
end;


Function OpenGzipRO(g:PGzipGlobs; const sFileName:String):Boolean;
begin
  with g^ do
  begin
//    iTarPosition:=0;
    iGzipHandle:=FileOpen(sFileName, fmOpenRead);
    sGzipName:=sFileName;
    Result:=iGzipHandle>-1;
    bOpened:=Result;
  end;
end;

function FindNextDir(g:PGzipGlobs;var item:TVFSItem): Boolean;
var
  iReaded:Integer;
  head:TGzipHead;
  iWord:Word;
  iFileSize:Cardinal;
  s:String;
  c:Char;
begin
  with g^ do
  begin
    Result:=False;
    if not bOpened then Exit;
    iReaded:=FileRead(iGzipHandle,head,SizeOf(TGzipHead));
    if iReaded<>SizeOf(TGzipHead) then Exit;
    with Head do
    begin
      if IDs<>$8b1f then Exit; // not a gzip file !
      if (FLG And 4)>0 then
      begin
         //FEXTRA is present
         iReaded:=FileRead(iGzipHandle,iWord,2);
         if iReaded<>2 then Exit;
         FileSeek(iGzipHandle,iWord,1); // skip FEXTRA blok
      end;
      if (FLG And 8)>0 then
      begin
         //FName is present
         s:='';
         repeat
           iReaded:=FileRead(iGzipHandle,c,1);
           if c<>#0 then
             s:=s+c;
         until (iReaded=0) or (c=#0);
         item.sFileName:=s;
      end
      else
         item.sFileName:=ChangeName(sGzipName);
      if (FLG And 16)>0 then
      begin
         //FComment is present
         //zero terminated text
      end;
      if (FLG And 2)>0 then
      begin
         //FHCRC (2 bytes) is present (never set in new gzip)
      end;
      // at this position start compressed block
      item.m_time:=MTime;
    end; // with head
    writeln( FileSeek(iGzipHandle,-4,2));
    iReaded:= FileRead(iGzipHandle,iFileSize,SizeOf(iFileSize)); // read uncompressed file size
    writeln(iReaded);
    item.iSize:=iFileSize;
    item.a_time:=0;
    item.c_time:=0;
    item.iUID:=0;  // maybe stat gzip file
    item.iGID:=0;
    item.iMode:=0;
    item.sLinkTo:='';
    item.ItemType:=vRegular;    
  end;
  Result:=True;
end;
end.
