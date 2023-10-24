unit uExecCmd;
{
  Execute external commands (and get there output) .
  Part of Commander, realised under GNU GPL 2.  (C)opyright 2003

Authors:
  Radek Cervinka, radek.cervinka@centrum.cz
Version:
  0.1 - write all from scratch

TODO:
- ExecCmdSimple - better error checking

}

{$H+}
interface
uses
  Classes;

function ExecCmdInput(const sCmd:String; var lsListing:TStringlist):Boolean;
function ExecCmdSimple(const sCmd:String):Boolean;
function ExecCmdFork(const sCmd:String):Integer;

implementation
uses
  SysUtils, BaseUnix, Unix;


function ExecCmdSimple(const sCmd:String):Boolean;
begin
  Result:=ExecuteProcess(sCmd,'')=0;
end;

function ExecCmdFork(const sCmd:String):Integer;
var
  pid    : longint;
Begin
  { always surround the name of the application by quotes
    so that long filenames will always be accepted. But don't
    do it if there are already double quotes!
  }
{  shell(sCmd);
  Exit;}
  pid:=fpFork;
  if pid=0 then
   begin
     {The child does the actual exec, and then exits}
      fpexecl('/bin/sh',['-c',sCmd]);
     { If the execve fails, we return an exitvalue of 127, to let it be known}
      fpExit(127);
   end
  else
   if pid=-1 then         {Fork failed}
    begin
      raise Exception.Create('Fork failed:'+sCmd);
    end;
  Result:=0;
end;

function ExecCmdInput(const sCmd:String; var lsListing:TStringlist):Boolean;
{var
  OutPut:PIOFile;
  rb:Integer;
  sDummy:String;
  c:Char;}
//  i:Integer;
begin
  assert(assigned(lsListing),'ExecCmdInput: lsListing=nil');
  Result:=False;
//  writeln(sCmd);

// replace with frepascal popen
  Exit;
{  lsListing.Clear;
  OutPut:=popen(PChar(sCmd),'r');
  if not assigned(output) then Exit;
  sDummy:='';
  rb:=1;
  while (FEOF(OutPut)=0) and (rb=1) do
    begin
      rb:=fread(@c, 1, 1, output);
      if (c=#$0A) or (rb=0) then
      begin
        if sDummy<>'' then
          lsListing.Add(sDummy);
        sDummy:='';
      end
      else
        sDummy:=sDummy+c;
    end;
  pclose(output);
  Result:=True;}
  
{  for i:=0 to lsListing.Count-1 do
    writeln(lsListing.Strings[i]);}
end;
end.
