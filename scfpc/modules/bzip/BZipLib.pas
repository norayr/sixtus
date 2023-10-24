{******************************************************************************}
{                                                                              }
{ Linux BZipLib API Interface Unit                                             }
{                                                                              }
{                                                                              }
{ Translator: Matthias Thoma                                                   }
{                                                                              }
{                                                                              }
{ Portions created by Julian R Seward are                                      }
{ Copyright (C) 1996-1999 Julian R Seward                                      }
{                                                                              }
{ The original file is: bzib.h, released 24 May 1999.                          }
{ The original Pascal code is: BZipLib.pas, released 01 Feb 2001.              }
{ The initial developer of the Pascal code is Matthias Thoma                   }
{ (ma.thoma@gmx.de).                                                           }
{                                                                              }
{ Portions created by Matthias Thoma are                                       }
{ Copyright (C) 2001 Matthias Thoma.                                           }
{                                                                              }
{                                                                              }
{ You may retrieve the latest version of this file at the Project              }
{ JEDI home page, located at http://delphi-jedi.org                            }
{                                                                              }
{ The contents of this file are used with permission, subject to               }
{ the Mozilla Public License Version 1.1 (the "License"); you may              }
{ not use this file except in compliance with the License. You may             }
{ obtain a copy of the License at                                              }
{ http://www.mozilla.org/MPL/MPL-1.1.html                                      }
{                                                                              }
{ Software distributed under the License is distributed on an                  }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or               }
{ implied. See the License for the specific language governing                 }
{ rights and limitations under the License.                                    }
{                                                                              }
{******************************************************************************}

unit BZipLib;

interface

{
/*-------------------------------------------------------------*/
/*--- Public header file for the library.                   ---*/
/*---                                               bzlib.h ---*/
/*-------------------------------------------------------------*/

/*--
  This file is a part of bzip2 and/or libbzip2, a program and
  library for lossless, block-sorting data compression.

  Copyright (C) 1996-1999 Julian R Seward.  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. The origin of this software must not be misrepresented; you must
     not claim that you wrote the original software.  If you use this
     software in a product, an acknowledgment in the product
     documentation would be appreciated but is not required.

  3. Altered source versions must be plainly marked as such, and must
     not be misrepresented as being the original software.

  4. The name of the author may not be used to endorse or promote
     products derived from this software without specific prior written
     permission.

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Julian Seward, Cambridge, UK.
  jseward@acm.org
  bzip2/libbzip2 version 0.9.5 of 24 May 1999

  This program is based on (at least) the work of:
     Mike Burrows
     David Wheeler
     Peter Fenwick
     Alistair Moffat
     Radford Neal
     Ian H. Witten
     Robert Sedgewick
     Jon L. Bentley

  For more information on these sources, see the manual.
--*/
}

const
   BZ_RUN               =  0;
   {$EXTERNALSYM BZ_RUN}
   BZ_FLUSH             =  1;
   {$EXTERNALSYM BZ_FLUSH}
   BZ_FINISH            =  2;
   {$EXTERNALSYM BZ_FINISH}

   BZ_OK                =  0;
   {$EXTERNALSYM BZ_OK}
   BZ_RUN_OK            =  1;
   {$EXTERNALSYM BZ_RUN_OK}
   BZ_FLUSH_OK          =  2;
   {$EXTERNALSYM BZ_FLUSH_OK}
   BZ_FINISH_OK         =  3;
   {$EXTERNALSYM BZ_FINISH_OK}
   BZ_STREAM_END        =  4;
   {$EXTERNALSYM BZ_STREAM_END}
   BZ_SEQUENCE_ERROR    = -1;
   {$EXTERNALSYM BZ_SEQUENCE_ERROR}
   BZ_PARAM_ERROR       = -2;
   {$EXTERNALSYM BZ_PARAM_ERROR}
   BZ_MEM_ERROR         = -3;
   {$EXTERNALSYM BZ_MEM_ERROR}
   BZ_DATA_ERROR        = -4;
   {$EXTERNALSYM BZ_DATA_ERROR}
   BZ_DATA_ERROR_MAGIC  = -5;
   {$EXTERNALSYM BZ_DATA_ERROR_MAGIC}
   BZ_IO_ERROR          = -6;
   {$EXTERNALSYM BZ_IO_ERROR}
   BZ_UNEXPECTED_EOF    = -7;
   {$EXTERNALSYM BZ_UNEXPECTED_EOF}
   BZ_OUTBUFF_FULL      = -8;
   {$EXTERNALSYM BZ_OUTBUFF_FULL}

type
  PBZStream = ^TBZStream;
  bz_stream = packed record
    next_in:   PChar;
    avail_in:  Cardinal;
    total_in:  Cardinal;

    next_out:  PChar;
    avail_out: Cardinal;
    total_out: Cardinal;

    state:     Pointer;
    bzalloc:   Pointer;
    bzfree:    Pointer;
    opaque:    Pointer;
  end;
  {$EXTERNALSYM bz_stream}
  TBZStream = bz_stream;

{-- Core (low-level) library functions --}

function bzCompressInit(strm: PBZStream; blockSize100k, verbosity, workFactor: Integer): Integer; cdecl;
{$EXTERNALSYM bzCompressInit}
function bzCompress(strm: PBZStream; action: Integer): Integer; cdecl;
{$EXTERNALSYM bzCompress}
function bzCompressEnd(strm: PBZStream): Integer; cdecl;
{$EXTERNALSYM bzCompressEnd}
function bzDecompressInit(strm: PBZStream; verbosity, small: Integer): Integer; cdecl;
{$EXTERNALSYM bzDecompressInit}
function bzDecompress(strm: PBZStream): Integer; cdecl;
{$EXTERNALSYM bzDecompress}
function bzDecompressEnd (strm: PBZStream): Integer; cdecl;
{$EXTERNALSYM bzDecompressEnd}

{-- High(er) level library functions --}

const
  BZ_MAX_UNUSED = 5000;
  {$EXTERNALSYM BZ_MAX_UNUSED}

type
  BZFILE = Pointer;

function bzReadOpen(var bzerror: Integer; f: Pointer; verbosity, small: Integer;
  unused: Pointer; nUnused: Integer): BZFILE; cdecl;
{$EXTERNALSYM bzReadOpen}
procedure bzReadClose(var bzerror: Integer; b: BZFILE); cdecl;
{$EXTERNALSYM bzReadClose}
procedure bzReadGetUnused(var bzerror: Integer; b: BZFILE; unused: Pointer; var nUnused: Integer); cdecl;
{$EXTERNALSYM bzReadGetUnused}
function bzRead2(var bzerror: Integer; b: BZFILE; buf: Pointer; len: Integer): Integer; cdecl;
function bzWriteOpen(var bzerror: Integer; f: Pointer; blockSize100k, verbosity, workFactor: Integer): BZFILE; cdecl;
{$EXTERNALSYM bzWriteOpen}
procedure bzWrite2(var bzerror: Integer; b: BZFILE; buf: Pointer; len: Integer); cdecl;
procedure bzWriteClose(var bzerror: Integer; b: BZFILE; abandon: Integer; var nbytes_in, nbytes_out: Cardinal);
{$EXTERNALSYM bzWriteClose}

{-- Utility functions --}

{  Code contributed by Yoshioka Tsuneo
   (QWF00133@niftyserve.or.jp/tsuneo-y@is.aist-nara.ac.jp),
   to support better zlib compatibility.
   This code is not _officially_ part of libbzip2 (yet);
   I haven't tested it, documented it, or considered the
   threading-safeness of it.
   If this code breaks, please contact both Yoshioka and me. }

function bzlibVersion: PChar; cdecl;
{$EXTERNALSYM bzlibVersion}
function bzopen(const path: PChar; const mode: PChar): PChar; cdecl;
{$EXTERNALSYM bzopen}
function bzdopen(fd: Integer; const mode: PChar): PChar; cdecl;
{$EXTERNALSYM bzdopen}
function bzread(b: BZFILE; buf: Pointer; len: Integer): Integer; cdecl;
{$EXTERNALSYM bzread}
function bzwrite(b: BZFILE; buf: Pointer; len: Integer): Integer; cdecl;
{$EXTERNALSYM bzwrite}
function bzflush(b: BZFILE): Integer; cdecl;
{$EXTERNALSYM bzflush}
function bzclose(b: BZFILE): Integer; cdecl;
{$EXTERNALSYM bzclose}
function bzerror(b: BZFILE; var errnum: Integer): PChar; cdecl;
{$EXTERNALSYM bzerror}

implementation

const
  BZipLibModuleName = 'libbz2.so';

function bzCompressInit;   external BZipLibModuleName name 'bzCompressInit';
function bzCompress;       external BZipLibModuleName name 'bzCompress';
function bzCompressEnd;    external BZipLibModuleName name 'bzCompressEnd';
function bzDecompressInit; external BZipLibModuleName name 'bzCompressInit';
function bzDecompress;     external BZipLibModuleName name 'bzDecompress';
function bzDecompressEnd;  external BZipLibModuleName name 'bzDecompressEnd';
function bzlibVersion;     external BZipLibModuleName name 'bzlibVersion';
function bzopen;           external BZipLibModuleName name 'bzoben';
function bzdopen;          external BZipLibModuleName name 'bzdopen';
function bzflush;          external BZipLibModuleName name 'bzflush';
function bzclose;          external BZipLibModuleName name 'bzclose';
function bzerror;          external BZipLibModuleName name 'bzerror';
function bzReadOpen;       external BZipLibModuleName name 'bzReadOpen';
function bzWriteOpen;      external BZipLibModuleName name 'bzWriteOpen';
procedure bzReadClose;     external BZipLibModuleName name 'bzReadClose';
procedure bzReadGetUnused; external BZipLibModuleName name 'bzReadGetUnused';
procedure bzWriteClose;    external BZipLibModuleName name 'bzWriteClose';

function  bzRead2;         external BZipLibModuleName name 'bzRead';
procedure bzWrite2;        external BZipLibModuleName name 'bzWrite';
function  bzread;          external BZipLibModuleName name 'bzread';
function  bzwrite;         external BZipLibModuleName name 'bzwrite';

end.
