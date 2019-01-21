{
  Copyright (C) 2017 by Clever Components

  Author: Sergey Shirokov <admin@clevercomponents.com>

  Website: www.CleverComponents.com

  This file is part of Dropbox Client Library for Delphi.

  Dropbox Client Library for Delphi is free software:
  you can redistribute it and/or modify it under the terms of
  the GNU Lesser General Public License version 3
  as published by the Free Software Foundation and appearing in the
  included file COPYING.LESSER.

  Dropbox Client Library for Delphi is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  along with Dropbox Client Library. If not, see <http://www.gnu.org/licenses/>.

  The current version of Dropbox Client Client Library for Delphi needs for
  the non-free library Clever Internet Suite. This is a drawback,
  and we suggest the task of changing
  the program so that it does the same job without the non-free library.
  Anyone who thinks of doing substantial further work on the program,
  first may free it from dependence on the non-free library.
}

unit DropboxManager.Tests;

interface

uses
  System.Classes, System.SysUtils, TestFramework, DropboxManager, DropboxApi, DropboxApi.Persister, DropboxApi.Data;

type
  TDropboxManagerTests = class(TTestCase)
  strict private
    procedure AssignCredentials(ADropbox: TDropboxManager);
  published
    procedure TestSerialization;
    procedure TestFolderRoutine;
    procedure TestFileRoutine;
    procedure TestCopyMove;
    procedure TestSaveUrl;
  end;

implementation

{ TDropboxManagerTests }

procedure TDropboxManagerTests.AssignCredentials(ADropbox: TDropboxManager);
begin
  ADropbox.ClientID := 'x0hh3lne06oc1cg';
  ADropbox.ClientSecret := 'xrkh8yumfunrrnl';
  ADropbox.RedirectURL := 'http://localhost:55896';
end;

procedure TDropboxManagerTests.TestCopyMove;
var
  dropbox: TDropboxManager;
  list: TStrings;
begin
  dropbox := nil;
  list := nil;
  try
    dropbox := TDropboxManager.Create();
    list := TStringList.Create();

    AssignCredentials(dropbox);

    try
      dropbox.Delete('/TestFolder');
    except
      on EDropboxException do;
    end;

    try
      dropbox.Delete('/TestFolderCopy');
    except
      on EDropboxException do;
    end;

    try
      dropbox.Delete('/TestFolderMove');
    except
      on EDropboxException do;
    end;

    dropbox.CreateFolder('/TestFolder');

    dropbox.Copy('/TestFolder', '/TestFolderCopy');

    dropbox.Move('/TestFolderCopy', '/TestFolderMove');

    dropbox.Search('', 'TestFolderCopy', False, list);
    Assert(0 = list.Count);

    dropbox.Delete('/TestFolder');
    dropbox.Delete('/TestFolderMove');
  finally
    list.Free();
    dropbox.Free();
  end;
end;

procedure TDropboxManagerTests.TestFileRoutine;
var
  dropbox: TDropboxManager;
  list: TStrings;
  stream: TStringStream;
begin
  dropbox := nil;
  list := nil;
  stream := nil;
  try
    dropbox := TDropboxManager.Create();
    list := TStringList.Create();

    AssignCredentials(dropbox);

    stream := TStringStream.Create('test content', TEncoding.UTF8);

    try
      dropbox.Delete('/testfile.txt');
    except
      on EDropboxException do;
    end;

    dropbox.Upload(stream, '/testfile.txt');

    stream.Size := 0;

    dropbox.Download('/testfile.txt', stream);

    Assert('test content' = stream.DataString);

    dropbox.Search('', 'testfile', False, list);

    Assert(1 = list.Count);
    Assert('/testfile.txt' = list[0]);

    dropbox.Delete('/testfile.txt');

    Sleep(2000);

    dropbox.Search('', 'testfile', False, list);
    Assert(0 = list.Count);

    dropbox.Search('', 'testfile', True, list);
    Assert(1 = list.Count);
    Assert('<Deleted> /testfile.txt' = list[0]);
  finally
    stream.Free();
    list.Free();
    dropbox.Free();
  end;
end;

procedure TDropboxManagerTests.TestFolderRoutine;
var
  dropbox: TDropboxManager;
  list: TStrings;
  cnt: Integer;
begin
  dropbox := nil;
  list := nil;
  try
    dropbox := TDropboxManager.Create();
    list := TStringList.Create();

    AssignCredentials(dropbox);

    try
      dropbox.Delete('/TestFolder');
    except
      on EDropboxException do;
    end;

    dropbox.ListFolder('', list);
    cnt := list.Count;

    dropbox.CreateFolder('/TestFolder');

    dropbox.ListFolder('', list);
    Assert(cnt + 1 = list.Count);

    dropbox.Delete('/TestFolder');
  finally
    list.Free();
    dropbox.Free();
  end;
end;

procedure TDropboxManagerTests.TestSaveUrl;
var
  dropbox: TDropboxManager;
  list: TStrings;
  cnt: Integer;
  id: string;
  status: TSaveUrlStatus;
begin
  dropbox := nil;
  list := nil;
  try
    dropbox := TDropboxManager.Create();
    list := TStringList.Create();

    AssignCredentials(dropbox);

    try
      dropbox.Delete('/testfile.txt');
    except
      on EDropboxException do;
    end;

    dropbox.ListFolder('', list);
    cnt := list.Count;

    id := dropbox.SaveUrl('/testfile.txt', 'http://www.clevercomponents.com/robots.txt');

    Assert('' <> id);

    repeat
      status := dropbox.SaveUrlCheckStatus(id);
    until (status <> usInProgress);

    Assert(usComplete = status);

    dropbox.ListFolder('', list);
    Assert(cnt + 1 = list.Count);

    dropbox.Delete('/testfile.txt');
  finally
    list.Free();
    dropbox.Free();
  end;
end;

procedure TDropboxManagerTests.TestSerialization;
const
  source = '{"entries": ['
    + '{".tag": "file", "name": "Get Started with Dropbox.pdf", "path_lower": "/get started with dropbox.pdf",'
    + ' "path_display": "/Get Started with Dropbox.pdf", "id": "id:99W9FmuZVTAAAAAAAAAAAg", "client_modified": "2016-12-20T21:27:34Z",'
    + ' "server_modified": "2016-12-20T21:28:34Z", "rev": "1521e41da", "size": 905827}],'
    + ' "cursor": "AAHiavvxdBrJsoC9q5E4girQd5LvgbyGhnTR1lYC5mo7OU_Ni0h_thdoLdQocqOK03ZyRPyshA2ifDnjIeyWV_FZ6UwMsh6unZMhoVpDPkCrXp8jYtnGUJ-g9u8LKjhatGA3e9ZAULV4IeFaUOMpLcjD", "has_more": false}';

var
  json: TDropboxJsonSerializer;
  obj: TListFolderResult;
  fileEntry: TFileMetadata;
begin
  json := nil;
  obj := nil;
  try
    json := TDropboxJsonSerializer.Create();
    obj := json.JsonToObject(TListFolderResult, source) as TListFolderResult;

    Assert(1 = Length(obj.Entries));
    Assert('AAHiavvxdBrJsoC9q5E4girQd5LvgbyGhnTR1lYC5mo7OU_Ni0h_thdoLdQocqOK03ZyRPyshA2ifDnjIeyWV_FZ6UwMsh6unZMhoVpDPkCrXp8jYtnGUJ-g9u8LKjhatGA3e9ZAULV4IeFaUOMpLcjD' = obj.Cursor);
    Assert(not obj.HasMore);

    fileEntry := obj.Entries[0] as TFileMetadata;

    Assert('Get Started with Dropbox.pdf' = fileEntry.Name);
    Assert('/get started with dropbox.pdf' = fileEntry.PathLower);
    Assert('/Get Started with Dropbox.pdf' = fileEntry.PathDisplay);
    Assert('id:99W9FmuZVTAAAAAAAAAAAg' = fileEntry.Id);
    Assert('2016-12-20T21:27:34Z' = fileEntry.ClientModified);
    Assert('2016-12-20T21:28:34Z' = fileEntry.ServerModified);
    Assert('1521e41da' = fileEntry.Rev);
    Assert(905827 = fileEntry.Size);
  finally
    obj.Free();
    json.Free();
  end;
end;

initialization
  TestFramework.RegisterTest(TDropboxManagerTests.Suite);

end.
