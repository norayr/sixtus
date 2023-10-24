{
Seksi Commander
----------------------------
Implementing of Generic File operation thread
(copying, moving ... is inherited from this)

Licence  : GNU GPL v 2.0
Author   : radek.cervinka@centrum.cz

contributors:

}
unit uFileOpThread;
{$mode objfpc}{$H+}

interface

uses
  Classes, uFileList, fFileOpDlg, uTypes {$IFNDEF NOFAKETHREAD}, uFakeThread{$ENDIF};

type

{$IFDEF NOFAKETHREAD}
  TFileOpThread = class(TThread)          check compilation
{$ELSE}
  TFileOpThread = class(TFakeThread)
{$ENDIF}
  private
    { Private declarations }
  protected
    FFileList: TFileList;  // input filelist (not rekursive walked)
    NewFileList: TFileList; // fill it with complete list of all files
    FFilesCount: Integer;
    FFilesSize: Int64;
    FDirCount :Integer;
    FFileOpDlg: TfrmFileOp; // progress window
    FBeginTime: TDateTime;
    FDownTo: Boolean; // browse list backward (for deleting)
    FReplaceAll:Boolean;
    FSkipAll:Boolean;
    FDstNameMask:String;
    FDstExtMask:String;
    FAppend: Boolean; // used mainly for pass information between move and copy

    procedure Execute; override;
    procedure MainExecute; virtual; abstract; // main loop for copy /delete ...
    procedure FillAndCount;
    procedure FillAndCountRec(const srcPath, dstPath:String); // rekursive called
    procedure EstimateTime(iSizeCoped:Int64);
    Function GetCaptionLng:String; virtual;
    procedure CorrectMask;
    Function CorrectDstName(const sName:String):String;
    Function CorrectDstExt(const sExt:String):String;
  public
    sDstPath: String;
    sDstMask: String;
    constructor Create(aFileList:TFileList);
    destructor Destroy; override;
    function UseForm:Boolean; virtual;
    function FreeAtEnd:Boolean; virtual;
    function DlgFileExist(const sMsg:String):Boolean; // result=true > rewrite file
  end;

implementation

uses
  SysUtils, uShowMsg, uLng, uFilter, uFileProcs, Forms, FindEx, BaseUnix;

{ TFileOpThread }

{if we use WaitFor, we don't use FreeOnTerminate
possible SIGSEV}

constructor TFileOpThread.Create(aFileList:TFileList);
begin
  inherited Create(True); // create Suspended
  FFileList := aFileList;
//  FreeOnTerminate:=FreeAtEnd;
  sDstMask:='*.*';
end;

destructor TFileOpThread.Destroy;
begin
  if assigned(FFileList) then
    FreeAndNil(FFileList);
end;

procedure TFileOpThread.FillAndCountRec(const srcPath, dstPath:String);
var
  sr:TSearchRec;
  fr:TFileRecItem;
  sb: stat64;
  
begin
  if FindFirstEx(srcPath+'*',faAnyFile,sr)<>0 then
  begin
    FindCloseEx(sr);
    Exit;
  end;
  repeat
    if (sr.Name='.') or (sr.Name='..') then Continue;
    fr.sName:=srcPath+sr.Name;
    fpstat64(PChar(fr.sName),sb);
//    write(fr.sName,': ');
    fr.sPath:=dstPath;
    fr.sNameNoExt:=sr.Name; // we use to save dstname
//    writeln(sr.Name);

    fr.iSize:=sb.st_size;
    fr.fTimeI:=FileStampToDateTime(sb.st_mtime);
    fr.sTime:='';   // not interested
    
    
    fr.iMode:=sb.st_mode;
//    writeln(sb.st_mode);
    if FPS_ISDIR(sb.st_mode) then
      writeln('ISDIR');
    
    fr.bIsLink:=FPS_ISLNK(fr.iMode);
    fr.sLinkTo:='';
    fr.bSelected:=False;
    fr.sModeStr:=''; // not interested
//    fr.sPath:=srcPath;
    NewFileList.AddItem(@fr);
    if fr.bIsLink then
      Continue;
    if FPS_ISDIR(fr.iMode) then
    begin
      inc(FDirCount);
      FillAndCountRec(srcPath+sr.Name+'/', dstPath+sr.Name+'/');
    end
    else
    begin
      inc(FFilesSize, sb.st_size);
      inc(FFilesCount);
    end;
  until FindNextEx(sr)<>0;
  FindCloseEx(sr);
end;

procedure TFileOpThread.FillAndCount;
var
  i:Integer;
  ptr:PFileRecItem;
begin
  NewFileList.Clear;
  FFilesCount:=0;
  FFilesSize:=0;
  FDirCount:=0;
  for i:=0 to FFileList.Count-1 do
  begin
    ptr:=FFileList.GetItem(i);
    if FPS_ISDIR(ptr^.iMode) and (not ptr^.bLinkIsDir) then
    begin
      inc(FDirCount);
      NewFileList.AddItem(ptr); // add DIR to List
      FillAndCountRec(ptr^.sName+'/',ptr^.sNameNoExt+'/');  // rekursive browse child dir
    end
    else
    begin
      NewFileList.AddItem(ptr);
      inc(FFilesCount);
      inc(FFilesSize, ptr^.iSize); // in first level we know file size -> use it
    end;
  end;
end;

procedure TFileOpThread.Execute;
begin
// main thread code started here

try
  FReplaceAll:=False;
  FSkipAll:=False;
  NewFileList:=TFileList.Create;
  try
    FillAndCount; // gets full list of files (rekursive)

    if UseForm then
    begin
      FFileOpDlg:=TfrmFileOp.Create(Application);
      FFileOpDlg.Caption:=GetCaptionLng;
      FFileOpDlg.Show;
      FFileOpDlg.Update;
    end;

    FBeginTime:=Now;
    if UseForm then
    begin
      FFileOpDlg.iProgress2Pos:=0;
      FFileOpDlg.iProgress2Max:=FFilesSize;
      Synchronize(@FFileOpDlg.UpdateDlg);
    end;

    MainExecute; // main executive (virtual)

  finally
    if UseForm then
      FreeAndNil(FFileOpDlg);
    if assigned(NewFileList) then
      FreeAndNil(NewFileList);
  end;
except
  on E:Exception do
    msgError(E.Message);
end;
end;

function TFileOpThread.UseForm:Boolean;
begin
  Result:=True;
end;

function TFileOpThread.FreeAtEnd:Boolean;
begin
//  Result:=True;
{ if we use WaitFor, we don't use FreeOnTerminate
  possible SIGSEV!!!!!!!!!!
}
  Result:=False;
end;

procedure TFileOpThread.EstimateTime(iSizeCoped:Int64);
begin
  if not UseForm then Exit;

  with FFileOpDlg do
  begin

    if iSizeCoped=0 then
      sEstimated:='????'
    else
      sEstimated:=FormatDateTime('HH:MM:SS',(Now-FBeginTime)*FFilesSize/iSizeCoped);


      // This is BAD ..., fixed in near future
//      TimeToStr((Now-FBeginTime)*FFilesSize/iSizeCoped);

{    writeln(FloatToStr(Now));
    writeln(sEstimated);}
    UpdateDlg;
  end;
end;

function TFileOpThread.DlgFileExist(const sMsg:String):Boolean; // result=true > rewrite file
begin
  FAppend:=False;
  Result:=False;
  case MsgBox(sMsg,[msmbRewrite, msmbNo, msmbSkip, msmbAppend, msmbRewriteAll, msmbSkipAll],
             msmbRewrite, msmbNo) of
    mmrNo, mmrSkip:;
    mmrRewrite:
      begin
        Result:=True;
      end;
    mmrRewriteAll:
      begin
        FReplaceAll:=True;
        Result:=True;
      end;
    mmrAppend:
      begin
        FAppend:=True;
        Result:=True;
      end;
    mmrSkipAll:
      begin
        FSkipAll:=True;
      end;
    else
      Raise Exception.Create('bad handling msg result');
  end; //case
end;

Function TFileOpThread.GetCaptionLng:String;
begin
  Result:='';
end;

procedure TFileOpThread.CorrectMask;
begin
  DivFileName(sDstMask,FDstNameMask,FDstExtMask);
  if FDstNameMask='' then
    FDstNameMask:='*';
  if FDstExtMask='' then
    FDstExtMask:='.*';
end;

Function TFileOpThread.CorrectDstName(const sName:String):String;
var
  i:Integer;
begin
  Result:='';
  for i:=1 to length(FDstNameMask) do
  begin
    if FDstNameMask[i]= '?' then
      Result:=Result+sName[i]
    else
    if FDstNameMask[i]= '*' then
      Result:=Result+Copy(sName,i,length(sName)-i+1)
    else
      Result:=Result+FDstNameMask[i];
  end;
end;

Function TFileOpThread.CorrectDstExt(const sExt:String):String;
var
  i:Integer;
begin
  Result:='';
  for i:=1 to length(FDstExtMask) do
  begin
    if FDstExtMask[i]= '?' then
      Result:=Result+sExt[i]
    else
    if FDstExtMask[i]= '*' then
      Result:=Result+Copy(sExt,i,length(sExt)-i+1)
    else
      Result:=Result+FDstExtMask[i];
  end;
end;
end.
