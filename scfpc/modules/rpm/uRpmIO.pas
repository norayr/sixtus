{ This code is based on:
  RPM plugin v.1.4 for Windows Commander.
  Copyright (c) 2000..2002 Mandryka Yurij ( Brain Group )

  licence is defined in licence.txt in original wc_rpm-1.5-src.zip
  (GNU GPL 2)

  original file name is rpm_io.pas

  http://braingroup.hotmail.ru/wcplugins/
  or www.ghisler.com

  some changes for Seksi Commander
  Radek Cervinka (C) 2003

}
//***************************************************************
// This file is part of RPMWCX, a archiver plugin for
// Windows Commander.
// Copyright (C) 2000 Mandryka Yurij  e-mail:braingroup@hotmail.ru
//***************************************************************

//***************************************************************
// This code based on Christian Ghisler (support@ghisler.com) sources
//***************************************************************

//***************************************************************
// This code was improved by Sergio Daniel Freue (sfreue@dc.uba.ar)
//***************************************************************

{$A-,I-}
unit uRpmIO;

interface

uses
  SysUtils,
  uRPMDef;

type
  TStrBuf = array[1..260] of Char;

function  RPM_ReadLead(handle : Integer; var lead : RPM_Lead) : Boolean;
function  RPM_ReadSignature(handle : Integer; sig_type : Word; var signature : RPM_Header) : Boolean;
function  RPM_ReadHeader(handle : Integer; align_data : Boolean; var header : RPM_Header; var info : RPM_InfoRec) : Boolean;
function  RPM_ReadEntry(handle : Integer; data_start : LongInt; var entry : RPM_EntryInfo) : Boolean;
function  RPM_ProcessEntry(handle : Integer; data_start : LongInt; var entry : RPM_EntryInfo; var info : RPM_InfoRec) : Boolean;

procedure swap_value(var value; size : Integer);
procedure copy_str2buf(var buf : TStrBuf; s : AnsiString);
function  read_string(handle : Integer; var s : AnsiString) : Boolean;
function  read_int32(handle : Integer; var int32 : LongWord) : Boolean;

implementation

procedure swap_value(var value; size:Integer);
type
  byte_array = array[1..MaxInt] of Byte;
var
  i      : Integer;
  avalue : Byte;
begin
  for i:=1 to size div 2 do
  begin
    avalue := byte_array(value)[i];
    byte_array(value)[i] := byte_array(value)[size + 1 - i];
    byte_array(value)[size + 1 - i] := avalue;
  end;
end;

procedure copy_str2buf(var buf : TStrBuf; s : AnsiString);
var
  i_char : Integer;
begin
  FillChar(buf, Sizeof(buf), 0);
  if Length(s) = 0 then Exit;
  if Length(s) > 259 then
    SetLength(s, 259);
  s := s + #0;
  for i_char := 1 to Length(s) do
    buf[i_char] := s[i_char];
end;


function  RPM_ReadLead(handle : Integer; var lead : RPM_Lead) : Boolean;
var
  iR:Integer;
begin
  Result := False;
  iR:=FileRead(handle, lead, sizeof(lead));
//  BlockRead(f, lead, Sizeof(Lead));
  if iR<>sizeof(lead) then Exit;
  Result := True;
  with lead do begin
    swap_value(rpmtype, 2);
    swap_value(archnum, 2);
    swap_value(osnum, 2);
    swap_value(signature_type, 2);
  end;
end;

function  RPM_ReadHeader(handle : Integer; align_data : Boolean; var header : RPM_Header; var info : RPM_InfoRec) : Boolean;
var
  i_entry  : LongWord;
  start    : Integer;
  entry    : RPM_EntryInfo;
  iR:Integer;
begin
  Result := False;
  iR:=FileRead(handle, header, sizeof(header));
  if iR<>sizeof(header) then Exit;
  with header do begin
    swap_value(count, 4);
    swap_value(data_size, 4);
    start := FileSeek(handle,0,1) + LongInt(count) * Sizeof(entry);
    for i_entry := 0 to count - 1 do begin
      if not RPM_ReadEntry(handle, start, entry) then
        Exit
      else
        if not RPM_ProcessEntry(handle, start, entry, info) then Exit;
    end;
  end;
  start := start + LongInt(header.data_size);
  // Move file pointer on padded to a multiple of 8 bytes position
  if align_data then
    if (start mod 8) <> 0 then begin
      start := start and $FFFFFFF8;
      Inc(start, 8);
    end;
  FileSeek(handle, start,0);
  Result := True;
end;

function  RPM_ReadEntry(handle : Integer; data_start : LongInt; var entry : RPM_EntryInfo) : Boolean;
var
  iR:Integer;
begin
  Result := False;
  iR:=FileRead(handle, entry, sizeof(entry));
  if iR<>sizeof(entry) then Exit;
  Result := True;
  with entry do begin
    swap_value(tag, 4);
    swap_value(etype, 4);
    swap_value(offset, 4);
    offset := data_start + LongInt(offset);
    swap_value(count, 4);
  end;
end;

function  RPM_ReadSignature(handle : Integer; sig_type : Word; var signature : RPM_Header) : Boolean;
var
  info : RPM_InfoRec;
begin
  Result := False;
  case sig_type of
    RPMSIG_PGP262_1024 : ;  // Old PGP signature
    RPMSIG_MD5         : ;  //
    RPMSIG_MD5_PGP     : ;  //
    RPMSIG_HEADERSIG   :    // New header signature
      begin
        Result:= RPM_ReadHeader(handle, True, signature, info);
      end;
  end;{case signature type}
end;


function  RPM_ProcessEntry(handle : Integer; data_start : LongInt; var entry : RPM_EntryInfo; var info : RPM_InfoRec) : Boolean;
var
  save_pos : Integer;
  fgError  : Boolean;
begin
  Result:=true;
  if entry.tag = RPMTAG_FILENAMES then exit;
  fgError := False;
  save_pos := FileSeek(Handle,0,1);
  FileSeek(handle, entry.offset,0);
  case entry.tag of
    RPMTAG_NAME :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.name);
    RPMTAG_VERSION :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.version);
    RPMTAG_RELEASE :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.release);
    RPMTAG_SUMMARY :
      if entry.etype = 9 then
        fgError := not read_string(handle, info.summary);
    RPMTAG_DESCRIPTION :
      if entry.etype = 9 then begin
        fgError := not read_string(handle, info.description);
      end;
    RPMTAG_BUILDTIME :
      if entry.etype = 4 then
        fgError := not read_int32(handle, info.buildtime);
    RPMTAG_DISTRIBUTION :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.distribution);
    RPMTAG_VENDOR :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.vendor);
    RPMTAG_LICENSE :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.license);
    RPMTAG_PACKAGER :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.packager);
    RPMTAG_GROUP :
      if entry.etype = 9 then
        fgError := not read_string(handle, info.group);
    RPMTAG_OS :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.os);
    RPMTAG_ARCH :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.arch);
    RPMTAG_SOURCERPM :
      if entry.etype = 6 then
        fgError := not read_string(handle, info.sourcerpm);
  end;{case}
  Result := not fgError;
  FileSeek(handle, save_pos,0);
end;

function read_string(handle : Integer; var s : AnsiString) : Boolean;
var
  c  : Char;
  iReaded:Integer;
begin
  SetLength(s, 0);
  s:='';
  repeat
    iReaded:=FileRead(handle,c,1);
    if c<>#0 then
      s:=s+c;
  until (iReaded=0) or (c=#0);
  Result := iReaded<>0;
end;

function  read_int32(handle : Integer; var int32 : LongWord) : Boolean;
begin
  Result :=FileRead(handle,int32, sizeof(longWord))=sizeof(longWord);
  swap_value(int32, Sizeof(LongWord));
end;

procedure RPM_CreateInfoRec(var info : RPM_InfoRec);
begin
end;

procedure RPM_DeleteInfoRec(var info : RPM_InfoRec);
begin
end;

end.
