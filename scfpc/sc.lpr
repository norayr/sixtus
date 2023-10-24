{ $threading on}
program sc;
// uGlobs must be first in uses, uLng must be before any form;
{%File 'doc/changelog.txt'}

uses
  Interfaces,
  uGlobsPaths,
  uGlobs,
  uLng,
  uIni,
  SysUtils,

//  cthreads,
  Forms,
  fMain,
  fAbout,
  uFileList,
  uFilePanel,
  uFileOp,
  uConstants,
  uTypes,
  framePanel,
  uExecCmd,
  uFileOpThread,
  uFileProcs,
  fFileOpDlg,
  uCopyThread,
  uDeleteThread,
  fMkDir,
  uCompareFiles,
  uHighlighterProcs,
  fEditor,
  uMoveThread,
  uFilter,
  uFindMmap,
  fMsg,
  uSpaceThread,
  fHotDir,
  uConv,
  fHardLink,
  fFindView,
  uPathHistory,
  uExts,
  uLog,
  uShowForm,
  fEditSearch,
  uColorExt,
  fEditorConf,
  fFileProperties,
  uUsersGroups,
  fLinker,
  fCompareFiles,
  dmHigh,
  uPixMapManager,
  uVFS;


 begin
//  try
  Application.Initialize;
  ThousandSeparator:=' ';
  writeln('Seksi commander 0.6 beta1 - Free Pascal');
  writeln('This program is free software released under terms of GNU GPL 2');
  writeln('                       v');
  writeln('(C)opyright 2003-4 Radek Cervinka (radek.cervinka@centrum.cz)');
  writeln('  and contributors (see about dialog)');
  
  LoadPaths;
  LoadGlobs;
  LoadPixMapManager;
  InitVFS;
  Application.CreateForm(TfrmMain, frmMain); // main form
  Application.CreateForm(TdmHighl, dmHighl); // highlighters
  Application.Run;
{  except
  on E:Exception do
    Writeln('Critical unhandled exception:', E.Message);
end}

end.
