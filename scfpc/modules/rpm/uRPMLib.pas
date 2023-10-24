unit uRPMLib;
{
  rpm helper rutines
  This code used some snipets from :
  RPM plugin v.1.4 for Windows Commander.
  Copyright (c) 2000..2002 Mandryka Yurij ( Brain Group )

  licence is defined in licence.txt in original wc_rpm-1.5-src.zip
  (GNU GPL 2)

  Radek Cervinka (C) 2003
}

interface
uses
  uVFStypes, uRPMDef;
type
  TRpmGlobs=record
//my globs, thread safe
    sRpmName:String;
    iRpmHandle:Integer;
    bOpened: Boolean;
    bBZ2: Boolean;
    iDataPosition:Int64;
    header         : RPM_Header;
    info           : RPM_InfoRec;
  end;
  PRpmGlobs=^TRpmGlobs;

Function OpenRpmRO(g:PRpmGlobs; const sFileName:String):Boolean;
function FindNextDir(g:PRpmGlobs;var item:TVFSItem): Boolean;

function InfoString(info:RPM_InfoRec):String;


implementation

uses
  SysUtils, uRpmIO;

function InfoString(info:RPM_InfoRec):String;
const
  cr=#10;
begin
  with info do
  begin
    Result:=       'Name:        '+name+cr;
    Result:=Result+'Version:     '+version+cr;
    Result:=Result+'Release:     '+release+cr;
    Result:=Result+'Summary:     '+summary+cr;
    Result:=Result+'Distribution:'+distribution+cr;
    Result:=Result+'Buildtime:   '+DateTimeToStr(EncodeDate (1970, 1, 1) + buildtime / (60*60*24.0))+cr;
    Result:=Result+'Vendor:      '+vendor+cr;
    Result:=Result+'License:     '+license+cr;
    Result:=Result+'Packager:    '+packager+cr;
    Result:=Result+'Group:       '+group+cr;
    Result:=Result+'Os:          '+os+cr;
    Result:=Result+'Arch:        '+arch+cr;
    Result:=Result+'Sourcerpm:   '+sourcerpm+cr;
    Result:=Result+'Description:'+cr+description+cr;
  end;
end;

Function OpenRpmRO(g:PRpmGlobs; const sFileName:String):Boolean;
var
  r_lead    : RPM_Lead;
  signature : RPM_Header;
  bErr: Boolean;
  
begin
  with g^ do
  begin
    Result:=False;
    bOpened:=False;
    iRpmHandle:=FileOpen(sFileName, fmOpenRead);
    sRpmName:=sFileName;
    if iRpmHandle=-1 then Exit;
    bErr:=False;
    try
      RPM_ReadLead(iRpmHandle, r_lead);
      if r_lead.magic <> RPM_MAGIC then
      begin
        bErr:=True;
        Exit; // through finally
      end;
      if not RPM_ReadSignature(iRpmHandle, r_lead.signature_type, signature) then
      begin
        bErr:=True;
        Exit; // through finally
      end;
      if not RPM_ReadHeader(iRpmHandle, False, header, info) then
      begin
        bErr:=True;
        Exit; // through finally
      end;
      iDataPosition:=FileSeek(iRpmHandle,0,1);  // current pos
    finally
      bOpened:=Not bErr;
      Result:=bOpened;
      if bErr then
        FileClose(iRpmHandle);
    end;
  end;
end;

function ChangeName(const sFileName:String; bBz2:Boolean):String;
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
   if sExt='.rpm' then
   begin
     if bBz2 then
       Result:=Copy(sFileName,1,length(sFileName)-3)+'cpio.bz2'
     else
       Result:=Copy(sFileName,1,length(sFileName)-3)+'cpio.gz';
   end;
end;

function FindNextDir(g:PRpmGlobs;var item:TVFSItem): Boolean;
var
  iReaded:Integer;
  iFileSize:Cardinal;
  DataSign   : array[0..3] of char;

begin
  with g^ do
  begin
    Result:=False;
    if not bOpened then Exit;
    iFileSize:=FileSeek(iRpmHandle,0,2); // filesize
    FileSeek(iRpmHandle,iDataPosition,0); // seek back
    item.iSize:=iFileSize-iDataPosition;

    iReaded:=FileRead(iRpmHandle,DataSign,3);
    if iReaded<>3 then Exit;
    bBZ2:=(DataSign[0]='B') and (DataSign[1]='Z') and (DataSign[2]='h');
    item.sFileName:=ChangeName(sRpmName,bBZ2);
    item.iMode:=0;
    item.sLinkTo:='';
    item.m_time:=0;
    item.a_time:=0;
    item.c_time:=0;
    item.iUID:=0;
    item.iGID:=0;
  end;
  Result:=True;
end;
end.
