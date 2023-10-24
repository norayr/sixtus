unit uVFS;
{
  Implementation of Virtual File System with cache.
  Part of Commander, realised under GNU GPL 2.  (C)opyright 2003

Authors:
  Radek Cervinka, radek.cervinka@centrum.cz

Version:
  0.1 - write all from scratch
  0.2 - implemented more caches
  0.3 - loading config from file (03/2003)
  0.4 - removed more caches :), new plugin interface (08/2003)

}

interface
uses
  Classes, uFileList, uVFSutil, uTypes, uVFSmodule;
type

  TVirtualFS=Class
  protected
    lsModules:TStringList;
    sLastArchive:String;
    lsCache:TFileList;
    function ExtractDirLevel(const sPrefix, sPath:String):String;
    procedure FillList(const sVFS:String; sVFSDir: String; var flist: TFileList);
    procedure FillListFromCache(const sVFSDir:String; var flist:TFileList);
    procedure AddUpLevel (var ls:TFileList); // add virtually ..
  public
    Constructor Create(const sPluginDir:String);
    Destructor Destroy; override;
    function FindModule(const sFileName:String):TVFSModule;
    function VFSListItems(const sVFS, sVFSDir:String; Var flist:TFileList):Boolean;
    procedure InvalidateCache;
  end; //class TVirtualFS


var
  VFS:TVirtualFS=nil;  // global variable for VFS

procedure InitVFS;

implementation

uses
  SysUtils, uGlobsPaths, uVFStypes, FindEx;

{ TVirtualFS }

procedure InitVFS;
begin
  VFS:=TVirtualFS.Create(gpVFSDir);
end;

constructor TVirtualFS.Create(const sPluginDir:String);
var
  sr: TSearchRec;
  VFSModule:TVFSModule;
begin
  lsModules:=TStringList.Create; // list of modules
  writeln(Format('Looking for VFS modules in [%s]...',[sPluginDir]));
  if FindFirstEx(sPluginDir+'libscv*.1', faAnyFile, sr)<>0 then
  begin
    FindCloseEx(sr);
    Exit;
  end;
  repeat
    if (sr.Name='.') or (sr.Name='..') then Continue;

//    if ((sr.attr and faArchive)>0) then Continue;
//    if S_ISDIR(sr.Mode) then continue;
//    writeln(sr.Name);
    VFSModule:=TVFSModule.Create;
    writeln('Founded. Try load '+sPluginDir+sr.Name);
    if VFSModule.LoadModule(sPluginDir+sr.Name) then
    begin
      if VFSModule.VFSInit=cVFS_OK then
      begin
        writeln('Good. Module can handle:'+VFSModule.VFSGetExts);
        lsModules.AddObject(VFSModule.VFSGetExts, VFSModule);
      end
      else
      begin
        writeln('Bad VFS initialization, unloading.');
        VFSModule.VFSDestroy;
        VFSModule.UnloadModule;
      end;
   end
   else
   begin
     writeln('Bad VFS module, canceled.');
     VFSModule.Free;
   end;
  until (FindNextEx(sr)<>0);
  FindCloseEx(sr);
  sLastArchive:='';  // nothing
  lsCache:=TFileList.Create;
end;

destructor TVirtualFS.Destroy;
var
  i:Integer;
begin
  for i:=lsModules.Count-1 downto 0 do
  begin
    with TVFSModule(lsModules.Objects[i]) do
    begin
      VFSClose;
      VFSDestroy;
      Free;
    end;
    lsModules.Delete(i);
  end;
  FreeAndNil(lsModules);
  FreeAndNil(lsCache);
  inherited
end;

function TVirtualFS.ExtractDirLevel(const sPrefix, sPath: String): String;
begin
  Result:=Copy(sPath, length(sPrefix)+1, length(sPath)-length(sPrefix)+1); // remove prefix
  if Result='' then Exit;
  if Result[1]='/' then
    Delete(Result,1,1);
  if pos('/',Result)>0 then // remove next level of dir
    Result:=Copy(Result,1,Pos('/',Result)-1);
end;

procedure TVirtualFS.FillList(const sVFS:String; sVFSDir: String; var flist: TFileList);
var
//  i:Integer;
  fi:TFileRecItem;
  iIndex:Integer;
//  frp: PFileRecItem;
  module:TVFSModule;
  vfsItem:TVFSItem;
begin
  flist.Clear;
  AddUpLevel(flist);   // add virtual ..
  if (sVFSDir<>'') and (sVFSDir[1]='/') then
    Delete(sVFSDir,1,1);
  module:=FindModule(sVFS);
  if not assigned(module) then Exit;
  iIndex:=0;
  if module.VFSOpen(sVFS)<>cVFS_OK then Exit;
  While module.VFSList(sVFSDir,iIndex,vfsItem)=cVFS_OK do
  begin
    fi.sName:=vfsItem.sFileName;
    fi.sExt:=ExtractFileExt(fi.sName);
    fi.sNameNoExt:=Copy(fi.sName,1,length(fi.sName)-length(fi.sExt));
    fi.sLinkTo:=vfsItem.sLinkTo;
    fi.iSize:=vfsItem.iSize;
    fi.iMode:=vfsItem.iMode;
    fi.iGroup:=vfsItem.iGID;
    fi.iOwner:=vfsItem.iUID;
    fi.fTimeI:=EncodeDate (1970, 1, 1) + vfsItem.m_time / (60*60*24.0);
    if sVFSDir='' then
    begin
      // root level of archive, process it separately
      // remove additional path
      if fi.sName[1]='/' then
        fi.sName:=ExtractDirLevel('/', fi.sName)
      else
        fi.sName:=ExtractDirLevel('', fi.sName);
    end;
    flist.AddItem(@fi);
    inc(iIndex);
  end;

  {        iIndex:=flist.CheckFileName(fi.sName);
        if iIndex=-1 then
        begin
          fi.sExt:=ExtractFileExt(fi.sName);
          fi.sNameNoExt:=Copy(fi.sName,1,length(fi.sName)-length(fi.sExt));
          flist.AddItem(@fi);
        end
        else
        begin
          // mark as directory
          frp:=flist.GetItem(iIndex);
          frp.iMode:=frp.iMode or __S_IFDIR;
        end
      end
      else
      begin
        if pos(sVFSDir,fi.sName)in [1..2] then
        begin
          fi.sName:=ExtractDirLevel(sVFSDir, fi.sName);
          iIndex:=flist.CheckFileName(fi.sNameNoExt);
          if iIndex=-1 then
          // sNameNoExt at this point temporally have full name (ls2FileInfo)
          begin
            fi.sExt:=ExtractFileExt(fi.sNameNoExt);
            fi.sNameNoExt:=Copy(fi.sName,1,length(fi.sNameNoExt)-length(fi.sExt));
            // and now trim extension
            if fi.sNameNoExt<>'' then
              flist.AddItem(@fi);
          end
          else
          begin
            // mark as directory
            frp:=flist.GetItem(iIndex);
            frp.iMode:=frp.iMode or __S_IFDIR;
          end;
        end;
      end;
    end;
  end; //cache
  }
end;

function TVirtualFS.VFSListItems(const sVFS, sVFSDir: String;
  var flist: TFileList): Boolean;
var
  module:TVFSModule;  
begin
  Result:=False;
  if sLastArchive<>sVFS then
  begin
    // if any archive > free them
    module:=FindModule(sLastArchive);
    if assigned(module) then
      module.VFSClose;
    FillList(sVFS, sVFSDir, lsCache); // fill up cache
    sLastArchive:=sVFS;
  end;

  FillListFromCache(sVFSDir, flist);
end;

procedure TVirtualFS.AddUpLevel(var ls:TFileList); // add virtually ..
var
  fi:TFileRecItem;
begin
  fi.sName:='..';
  fi.iSize:=0;
  fi.sExt:='';
  fi.sNameNoExt:=fi.sName;
  fi.bSelected:=False;
  fi.bExecutable:=False;
  fi.sModeStr:='drwxr-xr-x';
  fi.iMode:=ModeStr2Mode(fi.sModeStr); //!!!!
  fi.iDirSize:=0;
  ls.AddItem(@fi);
end;

function TVirtualFS.FindModule(const sFileName:String):TVFSModule;
var
  i:Integer;
  sExt:String;
begin
  Result:=nil;
  sExt:=ExtractFileExt(sFileName)+';';
  for i:=0 to lsModules.Count-1 do
  begin
    if Pos(sExt,lsModules.Strings[i])>0 then
      Result:=TVFSModule(lsModules.Objects[i]);
  end;
end;

procedure TVirtualFS.FillListFromCache(const sVFSDir:String; var flist:TFileList);
var
  i:Integer;
  fi:PFileRecItem;
begin
  fList.Clear;
  for i:=0 to lsCache.Count-1 do
  begin
    fi:=lsCache.GetItem(i);
    fList.AddItem(fi);
    if sVFSDir='' then
    begin
      // root level of archive, process it separately
      // remove additional path
      if fi^.sName[1]='/' then
        fi^.sName:=ExtractDirLevel('/', fi^.sName)
      else
        fi^.sName:=ExtractDirLevel('', fi^.sName);
    end;

  end;
end;

procedure TVirtualFS.InvalidateCache;
begin


end;


initialization

finalization
  if assigned(VFS) then
    FreeAndNil(VFS);
end.
