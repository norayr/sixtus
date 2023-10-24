{
  Types and definition for VFS modules for Seksi Commander
  GNU GPL 2

  Radek Cervinka, radek.cervinka@centrum.cz
}


unit uVFStypes;

interface
const
// capabilies
  capVFS_nil=0; //nothing
  capVFS_List=1;
  capVFS_CopyOut=2;
  capVFS_CopyIn=4;
  capVFS_MkDir=8;
  capVFS_RmDir=16;
  capVFS_Multiple=32; //support multiple files
  capVFS_Delete=64;
  capVFS_Rename=128;
  capVFS_Execute=256;
  capVFS_ListByDir=512; // reserved, in this moment is ignored


//error codes (TVFSResult)
  cVFS_OK=0;
  cVFS_Failed=1;
  cVFS_Not_Supported=2;
  cVFS_Not_More_Files=3;
  cVFS_ReadErr=4;
  
type

  TVFSResult=Integer;

  TVFSHandle=Integer;
  TVFSGlobs=Pointer;
{ TVFSGlobs is only declarations for SeksiCommander,
  in module is better to retype to pointer to record structure
  like TVFSGlobs=^TMyGlobs, TMyGlobs=record my global variables

  This is need for thread safe calling modules.
}

  TVFSItemType=(
    vRegular=0, vLink=1, vSymlink=2, vChardev=3,
    vBlockdev=4, vDirectory=5, vFifo=6, vOther=7);
  time_t= type Longint;
// shortstring is the same as array[0..255] of char, where at 0 is length

  TVFSItem=packed record
    sFileName:ShortString;
    iSize:Int64;
    iMode:Integer;
    sLinkTo:ShortString;
    iUID: Integer;
    iGID: Integer;
    ItemType:TVFSItemType;
// time_t  representing  the time in seconds since 00:00:00 UTC, January 1, 1970) }
    m_time: time_t;
    a_time: time_t;
    c_time: time_t;
// file date
//  DirRec.DateTime := EncodeDate (1970, 1, 1) + (ExtractNumber (@Header.MTime, 12) / 86400.0);

  end;

implementation

end.
