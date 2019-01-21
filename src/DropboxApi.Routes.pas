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

unit DropboxApi.Routes;

interface

uses
  System.Classes, System.SysUtils, DropboxApi, DropboxApi.Data, DropboxApi.Requests;

type
  TDropboxRoutes = class
  strict private
    FService: TService;
  public
    constructor Create(AService: TService);

    property Service: TService read FService;
  end;

  TAuthUserRoutes = class(TDropboxRoutes)
  public
    procedure TokenRevoke;
  end;

  TFilesUserRoutes = class(TDropboxRoutes)
    function Copy(ARelocationArg: TRelocationArg): TMetadata;
    //copy_batch
    //copy_batch/check
    //copy_reference/get
    //copy_reference/save
    function CreateFolder(ACreateFolderArg: TCreateFolderArg): TFolderMetadata;
    function Delete(ADeleteArg: TDeleteArg): TMetadata;
    //delete_batch
    //delete_batch/check
    function Download(ADownloadArg: TDownloadArg; ABody: TStream): TFileMetadata;
    //get_metadata
    //get_preview
    //get_temporary_link
    //get_thumbnail
    function ListFolder(AListFolderArg: TListFolderArg): TListFolderResult;
    function ListFolderContinue(AListFolderContinueArg: TListFolderContinueArg): TListFolderResult;
    //list_folder/get_latest_cursor
    //list_folder/longpoll
    //list_revisions
    function Move(ARelocationArg: TRelocationArg): TMetadata;
    //move_batch
    //move_batch/check
    //permanently_delete
    //restore
    function SaveUrl(ASaveUrlArg: TSaveUrlArg): TSaveUrlResult;
    function SaveUrlCheckJobStatus(APollArg: TPollArg): TSaveUrlJobStatus;
    function Search(ASearchArg: TSearchArg): TSearchResult;
    function Upload(ACommitInfo: TCommitInfo; ABody: TStream): TFileMetadata;
    //upload_session/append_v2
    //upload_session/finish
    //upload_session/finish_batch
    //upload_session/finish_batch/check
    //upload_session/start
  end;

  TDropboxClient = class(TService)
  strict private
    FAuth: TAuthUserRoutes;
    FFiles: TFilesUserRoutes;

    function GetAuth: TAuthUserRoutes;
    function GetFiles: TFilesUserRoutes;
  strict protected
    function CreateAuth: TAuthUserRoutes; virtual;
    function CreateFiles: TFilesUserRoutes; virtual;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    property Auth: TAuthUserRoutes read GetAuth;
    property Files: TFilesUserRoutes read GetFiles;
    //PaperUserRoutes Paper
    //SharingUserRoutes Sharing
    //UsersUserRoutes Users
  end;

implementation

{ TDropboxClient }

constructor TDropboxClient.Create(AInitializer: TServiceInitializer);
begin
  inherited Create(AInitializer);

  FAuth := nil;
  FFiles := nil;
end;

function TDropboxClient.CreateAuth: TAuthUserRoutes;
begin
  Result := TAuthUserRoutes.Create(Self);
end;

function TDropboxClient.CreateFiles: TFilesUserRoutes;
begin
  Result := TFilesUserRoutes.Create(Self);
end;

destructor TDropboxClient.Destroy;
begin
  FreeAndNil(FAuth);
  FreeAndNil(FFiles);

  inherited Destroy();
end;

function TDropboxClient.GetAuth: TAuthUserRoutes;
begin
  if (FAuth = nil) then
  begin
    FAuth := CreateAuth();
  end;
  Result := FAuth;
end;

function TDropboxClient.GetFiles: TFilesUserRoutes;
begin
  if (FFiles = nil) then
  begin
    FFiles := CreateFiles();
  end;
  Result := FFiles;
end;

{ TDropboxRoutes }

constructor TDropboxRoutes.Create(AService: TService);
begin
  inherited Create();
  FService := AService;
end;

{ TAuthUserRoutes }

procedure TAuthUserRoutes.TokenRevoke;
begin
  Service.Initializer.Credential.RevokeAuthorization();
end;

{ TFilesUserRoutes }

function TFilesUserRoutes.Copy(ARelocationArg: TRelocationArg): TMetadata;
var
  request: TFilesCopyRequest;
begin
  request := TFilesCopyRequest.Create(Service, ARelocationArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.CreateFolder(ACreateFolderArg: TCreateFolderArg): TFolderMetadata;
var
  request: TFilesCreateFolderRequest;
begin
  request := TFilesCreateFolderRequest.Create(Service, ACreateFolderArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.Delete(ADeleteArg: TDeleteArg): TMetadata;
var
  request: TFilesDeleteRequest;
begin
  request := TFilesDeleteRequest.Create(Service, ADeleteArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.Download(ADownloadArg: TDownloadArg; ABody: TStream): TFileMetadata;
var
  request: TFilesDownloadRequest;
begin
  request := TFilesDownloadRequest.Create(Service, ADownloadArg, ABody);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.ListFolder(AListFolderArg: TListFolderArg): TListFolderResult;
var
  request: TFilesListFolderRequest;
begin
  request := TFilesListFolderRequest.Create(Service, AListFolderArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.ListFolderContinue(AListFolderContinueArg: TListFolderContinueArg): TListFolderResult;
var
  request: TFilesListFolderContinueRequest;
begin
  request := TFilesListFolderContinueRequest.Create(Service, AListFolderContinueArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.Move(ARelocationArg: TRelocationArg): TMetadata;
var
  request: TFilesMoveRequest;
begin
  request := TFilesMoveRequest.Create(Service, ARelocationArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.SaveUrl(ASaveUrlArg: TSaveUrlArg): TSaveUrlResult;
var
  request: TFilesSaveUrlRequest;
begin
  request := TFilesSaveUrlRequest.Create(Service, ASaveUrlArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.SaveUrlCheckJobStatus(APollArg: TPollArg): TSaveUrlJobStatus;
var
  request: TFilesSaveUrlCheckJobStatusRequest;
begin
  request := TFilesSaveUrlCheckJobStatusRequest.Create(Service, APollArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.Search(ASearchArg: TSearchArg): TSearchResult;
var
  request: TFilesSearchRequest;
begin
  request := TFilesSearchRequest.Create(Service, ASearchArg);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

function TFilesUserRoutes.Upload(ACommitInfo: TCommitInfo; ABody: TStream): TFileMetadata;
var
  request: TFilesUploadRequest;
begin
  request := TFilesUploadRequest.Create(Service, ACommitInfo, ABody);
  try
    Result := request.Execute();
  finally
    request.Free();
  end;
end;

end.
