program libtest;


uses
  SysUtils,
//  utarlib in 'utarlib.pas',
//  uVFStar in 'uVFStar.pas',
  uVFStypes in '../uVFStypes.pas',
  uVFSprototypes in '../uVFSprototypes.pas',
  uVFSmodule in '../uVFSmodule.pas',
  uModuleLoader in '../uModuleLoader.pas';

var
  item:TVFSItem;
  iItemID:Integer;
  VFSModule:TVFSModule;

procedure PrintCaps(iCaps:Integer);
begin
  if iCaps And capVFS_List >0 then write('list,');
  if iCaps And capVFS_CopyOut >0 then write('copyout,');
  if iCaps And capVFS_CopyIn >0 then write('copyin,');
  if iCaps And capVFS_MkDir>0 then write('mkdir,');
  if iCaps And capVFS_RmDir>0 then write('rmdir,');
  if iCaps And capVFS_Multiple>0 then write('multiple files,');
  if iCaps And capVFS_Delete>0 then write('delete,');
  if iCaps And capVFS_Rename>0 then write('rename,');
  if iCaps And capVFS_Execute>0 then write('execute,');
  writeln;
end;

procedure PrintTime(time:time_t);
begin
 // convert time_t > TDatetime (div sec/day)
 Write(DateTimeToStr(EncodeDate (1970, 1, 1) + time / (60*60*24.0)),',');
end;

begin
  if ParamCount<>2 then
  begin
    writeln('This is tester for Shared Objects for Seksi Commander.');
    writeln('(C)opyright Radek Cervinka - 2003, GNU GPL 2');
    writeln('usage: libtest libname.so archivename');
    Exit;
  end;

  VFSModule:=TVFSModule.Create;
  VFSModule.LoadModule(ParamStr(1));
  with VFSModule do
  begin
    if VFSInit<>cVFS_OK then
    begin
      Writeln('VFSInitFailed.');
      Exit;
    end;
    Writeln('Good, module init OK.');
    try
      PrintCaps(VFSCaps('.tar'));
      if VFSOpen(ParamStr(2))<>cVFS_OK then Exit;
      writeln(Format('Opened %s OK',[ParamStr(2)]));
      iItemID:=0;
      while VFSList('',iItemID,item)=cVFS_OK do
      begin
        writeln(item.sFileName,';', item.iSize,' UID:',item.iUID,' GID:',item.iGID);
        PrintTime(item.m_time);
        PrintTime(item.c_time);
        PrintTime(item.a_time);
        writeln;
        inc(iItemID);
      end;
    finally
      write('Calling module Destroy...');
      VFSDestroy;
      writeln('OK');
      Free;
    end;
  end;  
  writeln('Work done.');
end.
