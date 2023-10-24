{
 Seksi commander - Virtual File System support
 - prototypes function is archive module

 (C) Radek Cervinka 2003, radek.cervinka@centrum.cz
 released under GNU GPL2

 constributors:

}
unit uVFSprototypes;

interface
uses
  uVFStypes;
type
  TVFSInit = function (Var iMemoryNeed:Integer):TVFSResult; cdecl;
  {VFSInit is usefull for finding helpers library, or load cfg.
   If Result is cVFS_Failed, then library is unloaded and ignored at run.
   iMemoryNeed is allocated by SeksiCommander and
   passed VFSGlobs is pointer to this memory place - needed for thread safe and so
  }

  TVFSCaps= function (g:TVFSGlobs; const sExt:PChar):Integer; cdecl;
// return capabilities for ext (.tar), sc only call procedures marked by this return value

  TVFSDestroy= procedure (g:TVFSGlobs); cdecl;
// called at the end, unload helper libraries, but NOT freemem for g
  TVFSGetExts= function (g:TVFSGlobs):PChar; cdecl;
// result is in this form: .zip;.gzip;.gz; - last must be ; (lowercase)

  TVFSOpen= function (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
// handle (if any needed) must be stored in g!

  TVFSClose =function (g:TVFSGlobs):TVFSResult;cdecl;

  TVFSMkDir= function (g:TVFSGlobs; const sDirName:PChar ):TVFSResult; cdecl;
  TVFSRmDir= function (g:TVFSGlobs; const sDirName:PChar):TVFSResult; cdecl;
  TVFSCopyOut= function (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;
  TVFSCopyIn= function (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;
  TVFSRename= function (g:TVFSGlobs; const sSrcName:PChar; const sDstName:PChar):TVFSResult; cdecl;

  TVFSRun = function (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;

  TVFSDelete= function (g:TVFSGlobs; const sName:PChar):TVFSResult; cdecl;
  TVFSList= function (g:TVFSGlobs; const sDir:PChar; iItemID:Integer; var VFSItem:TVFSItem ):TVFSResult; cdecl;



implementation

end.
