unit utarlib;
{
 Tar helper rutines, based on:

/*
 * Tarpet - Tar struct definitions
 *
 * Placed in the public domain by Abigail Brady <morwen@evilmagic.org>
 *
 * Implemented from a definition provided by Rachel Hestilow,
 * md5sum 7606d69d61dfc7eed10857a888136b62
 *
 * See documentation-1.1.txt for details.
 *
 */

 translated for Object Pascal by Radek Cervinka radek.cervinka at centrum.cz
 This translation is released under GNU GPL 2
}

interface
uses
  uVFStypes;
const
  cRecordSize  = 512;
  cNameLen     = 100;

type
  TTarpet_POSIX = packed record
     Name     : array [0..cNameLen-1] of Char;
     Mode     : array [0..7] of Char;
     UID      : array [0..7] of Char;
     GID      : array [0..7] of Char;
     Size     : array [0..11] of Char;
     MTime    : array [0..11] of Char;
     Checksum   : array [0..7] of Char;
     TypeFlag : Char;
     LinkName : array [0..cNameLen-1] of Char;
     Magic    : array [0..7] of Char;
//     Version  : array [0..1] of Char;
     UserName : array [0..31] of Char;
     GroupName: array [0..31] of Char;
     DevMajor : array [0..7] of Char;
     DevMinor : array [0..7] of Char;
     Extend   : array [0..154] of Char;
     reserved :array[0..11] of Char; // fill to 512
  end;
  PTarpet_POSIX=^TTarpet_POSIX;


  TTarGlobs=record
//my globs, thread safe
//    iTarPosition:Int64;
    TarRec:PTarpet_POSIX;
    iTarHandle:Integer;
    iBytesToSkip:Int64;
    bOpened: Boolean;
  end;
  PTarGlobs=^TTarGlobs;


Function OpenTarRO(g:PTarGlobs; const sFileName:String):Boolean;

function FindNextDir(g:PTarGlobs;var item:TVFSItem): Boolean;


implementation

uses
  SysUtils;


{struct TARPET_POSIX {
  char name[100];
  char mode[8];
  char uid[8];
  char gid[8];
  char size[12];
  char mtime[12];
  char checksum[8];
  char typeflag;
  char linkname[100];
  char magic[6];
  char version[2];
  char username[32];
  char groupname[32];
  char major[8];
  char minor[8];
  char extend[155];
;}

const
  TARPET_TYPE_REGULAR    =#0;
  TARPET_TYPE_REGULAR2   ='0';
  TARPET_TYPE_LINK       ='1';
  TARPET_TYPE_SYMLINK    ='2';
  TARPET_TYPE_CHARDEV    ='3';
  TARPET_TYPE_BLOCKDEV   ='4';
  TARPET_TYPE_DIRECTORY  ='5';
  TARPET_TYPE_FIFO       ='6';
  TARPET_TYPE_CONTIGUOUS ='7';
  TARPET_TYPE_DUMPDIR    ='D';
  TARPET_TYPE_LONGLINKN  ='K';
  TARPET_TYPE_LONGFILEN  ='L';
  TARPET_TYPE_MULTIVOL   ='M';
  TARPET_TYPE_LONGNAME   ='N';
  TARPET_TYPE_SPARSE     ='S';
  TARPET_TYPE_VOLUME     ='V';

  TARPET_GNU_MAGIC       ='ustar';
  TARPET_GNU_MAGIC_OLD   ='ustar  ';


Function OpenTarRO(g:PTarGlobs; const sFileName:String):Boolean;
begin
  with g^ do
  begin
//    iTarPosition:=0;
    iBytesToSkip:=0;
    iTarHandle:=FileOpen(sFileName, fmOpenRead);
    Result:=iTarHandle>-1;
    new(TarRec);
    bOpened:=Result;
  end;
end;

function OctalToInt(const s:String):Integer;
var
  i:Integer;
begin
  Result := 0;
  for i:=1 to length(s) do
  begin
    if s[i]=' ' then Continue;
    Result := (ORD (s[i]) - ORD ('0')) OR (Result SHL 3);
  end;
end;

function RecCount(bytes:Int64):Int64;
begin
  Result:=bytes div cRecordSize;
  if (bytes mod cRecordSize) >0 then
    inc (Result);
end;

function ExtractN64 (s:String) : Int64;
var i:Integer;
begin
  Result := 0;
  for i:=1 to length(s) do
  begin
    if s[i]=' ' then Continue;
    Result:= (Ord(s[i])- Ord('0')) or (Result shl 3);
  end;
end;

function ExtractN (s:String) : Integer;
var i:Integer;
begin
  Result := 0;
  for i:=1 to length(s) do
  begin
    if s[i]=' ' then Continue;
    Result:= (Ord(s[i])- Ord('0')) or (Result shl 3);
  end;
end;

function FindNextDir(g:PTarGlobs ; var item:TVFSItem): Boolean;
var
  iReaded:Integer;
  iCheckSumR:Integer; // readed checksum
  i:Integer;
  iCheckSumC:Integer; // counted checksum

begin
  with g^ do
  begin
    Result:=False;
    if not bOpened then Exit;
    if iBytesToSkip>0 then
      FileSeek(iTarHandle,RecCount(iBytesToSkip)*cRecordSize,1);
  //  writeln('Position pred ctenim:$',IntToHex(FileSeek(iTarHandle,0,1),6));
    iReaded:=FileRead(iTarHandle,TarRec^,SizeOf(TTarpet_POSIX));
    if iReaded<SizeOf(TarRec) then Exit;
    if TarRec^.Name[0]=#0 then Exit;
    // at the end of TARPET is many zeros, (for fill sectors on tapes?)
    iCheckSumR:=ExtractN(String(TarRec.Checksum));
    FillChar(TarRec.Checksum,8,' '); // blank checksum
    iCheckSumC:=0;
    for i:=0 to 511 do
      iCheckSumC:=iCheckSumC+ord(PChar(TarRec)[i]);
    if iCheckSumC<>iCheckSumR then
      Exit;
    if Trim(String(TarRec.Magic))<>'ustar' then
      Exit;
    Result:=True;
    item.sFileName:=String(TarRec.Name);
    item.iSize:= ExtractN64(String(TarRec.Size));
    item.iMode:=ExtractN(String(TarRec.Mode));
    item.iUID:=ExtractN(String(TarRec.UID));
    item.iGID:=ExtractN(String(TarRec.GID));
    item.a_time:=0;
    item.c_time:=0;
    item.m_time:=ExtractN(String(TarRec.MTime)); // div 60*60*24 ?
   // time
//  DirRec.DateTime := EncodeDate (1970, 1, 1) + (ExtractNumber (@Header.MTime, 12) / 86400.0);   
    case(TarRec.TypeFlag) of
      #0, '0' : item.ItemType:=vRegular;
      '1'     : item.ItemType:=vLink;
      '2'     : item.ItemType:=vSymlink;
      '3'     : item.ItemType:=vChardev;
      '4'     : item.ItemType:=vBlockdev;
      '5'     : item.ItemType:=vDirectory;
      '6'     : item.ItemType:=vFifo;
      '7','S' : item.ItemType:=vOther;
      'D','M' : item.ItemType:=vOther;
      'V','K' : item.ItemType:=vOther;
      'L','N' : item.ItemType:=vOther;
      //! warning for L
    else
      item.ItemType:=vOther;
    end;
    iBytesToSkip:=0;
    if item.ItemType=vRegular then
      iBytesToSkip := item.iSize ;
  //  writeln('>',iBytesToSkip);
  end;
end;
end.
