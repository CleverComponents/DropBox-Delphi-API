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

unit DropboxManager;

interface

uses
  System.Classes, System.SysUtils, DropboxApi, DropboxApi.Data, DropboxApi.Routes, DropboxApi.Persister;

type
  TSaveUrlStatus = (usInProgress, usComplete, usFailed);

  TDropboxManager = class
  strict private
    FClientID: string;
    FClientSecret: string;
    FRedirectURL: string;
    FClient: TDropboxClient;

    function GetClient: TDropboxClient;
    procedure CollectFolderList(AListFolderResult: TListFolderResult; AList: TStrings);
    procedure CollectSearchList(ASearchResult: TSearchResult; AList: TStrings);
  public
    constructor Create;
    destructor Destroy; override;

    procedure CreateFolder(const APath: string);
    procedure ListFolder(const APath: string; AList: TStrings);
    procedure Delete(const APath: string);
    procedure Search(const APath, AQuery: string; ASearchDeleted: Boolean; AList: TStrings);

    procedure Copy(const AFromPath, AToPath: string);
    procedure Move(const AFromPath, AToPath: string);

    procedure Download(const ASourceFile: string; ADestination: TStream);
    procedure Upload(ASource: TStream; const ADestinationFile: string);
    function SaveUrl(const APath, AUrl: string): string;
    function SaveUrlCheckStatus(const AsyncJobId: string): TSaveUrlStatus;

    procedure Close;

    property ClientID: string read FClientID write FClientID;
    property ClientSecret: string read FClientSecret write FClientSecret;
    property RedirectURL: string read FRedirectURL write FRedirectURL;
  end;

implementation

{ TDropboxManager }

function TDropboxManager.SaveUrlCheckStatus(const AsyncJobId: string): TSaveUrlStatus;
var
  args: TPollArg;
  res: TSaveUrlJobStatus;
begin
  args := nil;
  res := nil;
  try
    args := TPollArg.Create();
    args.AsyncJobId := AsyncJobId;

    res := GetClient().Files.SaveUrlCheckJobStatus(args);

    if (res is TSaveUrlJobStatusInProgress) then
    begin
      Result := usInProgress;
    end else
    if (res is TSaveUrlJobStatusComplete) then
    begin
      Result := usComplete;
    end else
    begin
      Result := usFailed;
    end;
  finally
    res.Free();
    args.Free();
  end;
end;

procedure TDropboxManager.Close;
begin
  if (FClient <> nil) then
  begin
    FClient.Abort();
  end;
end;

constructor TDropboxManager.Create;
begin
  inherited Create();
  FClient := nil;
end;

procedure TDropboxManager.CreateFolder(const APath: string);
var
  args: TCreateFolderArg;
  res: TFolderMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TCreateFolderArg.Create();
    args.Path := APath;

    res := GetClient().Files.CreateFolder(args);

  finally
    res.Free();
    args.Free();
  end;
end;

procedure TDropboxManager.Delete(const APath: string);
var
  args: TDeleteArg;
  res: TMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TDeleteArg.Create();
    args.Path := APath;

    res := GetClient().Files.Delete(args);

  finally
    res.Free();
    args.Free();
  end;
end;

destructor TDropboxManager.Destroy;
begin
  Close();
  FClient.Free();

  inherited Destroy();
end;

procedure TDropboxManager.Download(const ASourceFile: string; ADestination: TStream);
var
  args: TDownloadArg;
  res: TFileMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TDownloadArg.Create();
    args.Path := ASourceFile;

    res := GetClient().Files.Download(args, ADestination);

  finally
    res.Free();
    args.Free();
  end;
end;

function TDropboxManager.GetClient: TDropboxClient;
var
  credential: TDropboxOAuthCredential;
  initializer: TServiceInitializer;
begin
  if (FClient = nil) then
  begin
    credential := TDropboxOAuthCredential.Create();
    initializer := TDropboxServiceInitializer.Create(credential, 'Clever Disk Manager');
    FClient := TDropboxClient.Create(initializer);

    credential.ClientID := ClientID;
    credential.ClientSecret := ClientSecret;
    credential.RedirectURL := RedirectURL;
  end;
  Result := FClient;
end;

procedure TDropboxManager.CollectFolderList(AListFolderResult: TListFolderResult; AList: TStrings);
var
  entry: TMetaData;
begin
  for entry in AListFolderResult.Entries do
  begin
    if (entry is TFileMetadata) then
    begin
      AList.Add((entry as TFileMetadata).PathDisplay);
    end else
    if (entry is TFolderMetadata) then
    begin
      AList.Add('<Folder> ' + (entry as TFolderMetadata).PathDisplay);
    end else
    if (entry is TDeletedMetadata) then
    begin
      AList.Add('<Deleted> ' + (entry as TDeletedMetadata).PathDisplay);
    end else
    begin
      AList.Add('<Unknown> ' + entry.Tag);
    end;
  end;
end;

procedure TDropboxManager.ListFolder(const APath: string; AList: TStrings);
var
  args: TListFolderArg;
  continueArgs: TListFolderContinueArg;
  res: TListFolderResult;
begin
  AList.BeginUpdate();
  args := nil;
  continueArgs := nil;
  res := nil;
  try
    AList.Clear();

    args := TListFolderArg.Create();
    args.Path := APath;

    continueArgs := TListFolderContinueArg.Create();

    res := GetClient().Files.ListFolder(args);
    CollectFolderList(res, AList);

    while (res.HasMore) do
    begin
      continueArgs.Cursor := res.Cursor;

      FreeAndNil(res);
      res := GetClient().Files.ListFolderContinue(continueArgs);
      CollectFolderList(res, AList);
    end;
  finally
    res.Free();
    continueArgs.Free();
    args.Free();
    AList.EndUpdate();
  end;
end;

procedure TDropboxManager.Move(const AFromPath, AToPath: string);
var
  args: TRelocationArg;
  res: TMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TRelocationArg.Create();
    args.FromPath := AFromPath;
    args.ToPath := AToPath;
    args.AllowSharedFolder := True;

    res := GetClient().Files.Move(args);

  finally
    res.Free();
    args.Free();
  end;
end;

procedure TDropboxManager.CollectSearchList(ASearchResult: TSearchResult; AList: TStrings);
var
  match: TSearchMatch;
begin
  for match in ASearchResult.Matches do
  begin
    if (match.Metadata is TFileMetadata) then
    begin
      AList.Add((match.Metadata as TFileMetadata).PathDisplay);
    end else
    if (match.Metadata is TFolderMetadata) then
    begin
      AList.Add('<Folder> ' + (match.Metadata as TFolderMetadata).PathDisplay);
    end else
    if (match.Metadata is TDeletedMetadata) then
    begin
      AList.Add('<Deleted> ' + (match.Metadata as TDeletedMetadata).PathDisplay);
    end else
    begin
      AList.Add('<Unknown> ' + match.Metadata.Tag);
    end;
  end;
end;

procedure TDropboxManager.Copy(const AFromPath, AToPath: string);
var
  args: TRelocationArg;
  res: TMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TRelocationArg.Create();
    args.FromPath := AFromPath;
    args.ToPath := AToPath;

    res := GetClient().Files.Copy(args);

  finally
    res.Free();
    args.Free();
  end;
end;

function TDropboxManager.SaveUrl(const APath, AUrl: string): string;
var
  args: TSaveUrlArg;
  res: TSaveUrlResult;
begin
  args := nil;
  res := nil;
  try
    args := TSaveUrlArg.Create();
    args.Path := APath;
    args.Url := AUrl;

    res := GetClient().Files.SaveUrl(args);

    if (res is TSaveUrlResultAsyncJobId) then
    begin
      Result := (res as TSaveUrlResultAsyncJobId).AsyncJobId;
    end else
    begin
      Result := '';
    end;
  finally
    res.Free();
    args.Free();
  end;
end;

procedure TDropboxManager.Search(const APath, AQuery: string; ASearchDeleted: Boolean; AList: TStrings);
var
  args: TSearchArg;
  res: TSearchResult;
begin
  AList.BeginUpdate();
  args := nil;
  res := nil;
  try
    AList.Clear();

    args := TSearchArg.Create();
    args.Path := APath;
    args.Query := AQuery;

    if ASearchDeleted then
    begin
      args.Mode := TDeletedFilenameSearchMode.Create();
    end;

    res := GetClient().Files.Search(args);
    CollectSearchList(res, AList);

    while (res.More) do
    begin
      args.Start := res.Start;

      FreeAndNil(res);
      res := GetClient().Files.Search(args);
      CollectSearchList(res, AList);
    end;

  finally
    res.Free();
    args.Free();
    AList.EndUpdate();
  end;
end;

procedure TDropboxManager.Upload(ASource: TStream; const ADestinationFile: string);
var
  args: TCommitInfo;
  res: TFileMetadata;
begin
  args := nil;
  res := nil;
  try
    args := TCommitInfo.Create();
    args.Path := ADestinationFile;

    res := GetClient().Files.Upload(args, ASource);

  finally
    res.Free();
    args.Free();
  end;
end;

end.
