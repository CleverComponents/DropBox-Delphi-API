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

unit DropboxApi.Requests;

interface

uses
  System.Classes, DropboxApi, DropboxApi.Data;

type
  TFilesCreateFolderRequest = class(TServiceRequest<TFolderMetadata>)
  strict private
    FCreateFolderArg: TCreateFolderArg;
  public
    constructor Create(AService: TService; ACreateFolderArg: TCreateFolderArg);

    function Execute: TFolderMetadata; override;
  end;

  TFilesDeleteRequest = class(TServiceRequest<TMetadata>)
  strict private
    FDeleteArg: TDeleteArg;
  public
    constructor Create(AService: TService; ADeleteArg: TDeleteArg);

    function Execute: TMetadata; override;
  end;

  TFilesListFolderRequest = class(TServiceRequest<TListFolderResult>)
  strict private
    FListFolderArg: TListFolderArg;
  public
    constructor Create(AService: TService; AListFolderArg: TListFolderArg);

    function Execute: TListFolderResult; override;
  end;

  TFilesListFolderContinueRequest = class(TServiceRequest<TListFolderResult>)
  strict private
    FListFolderContinueArg: TListFolderContinueArg;
  public
    constructor Create(AService: TService; AListFolderContinueArg: TListFolderContinueArg);

    function Execute: TListFolderResult; override;
  end;

  TFilesUploadRequest = class(TServiceRequest<TFileMetadata>)
  strict private
    FCommitInfo: TCommitInfo;
    FBody: TStream;
  public
    constructor Create(AService: TService; ACommitInfo: TCommitInfo; ABody: TStream);

    function Execute: TFileMetadata; override;
  end;

  TFilesDownloadRequest = class(TServiceRequest<TFileMetadata>)
  strict private
    FDownloadArg: TDownloadArg;
    FBody: TStream;
  public
    constructor Create(AService: TService; ADownloadArg: TDownloadArg; ABody: TStream);

    function Execute: TFileMetadata; override;
  end;

  TFilesSearchRequest = class(TServiceRequest<TSearchResult>)
  strict private
    FSearchArg: TSearchArg;
  public
    constructor Create(AService: TService; ASearchArg: TSearchArg);

    function Execute: TSearchResult; override;
  end;

  TFilesCopyRequest = class(TServiceRequest<TMetadata>)
  strict private
    FRelocationArg: TRelocationArg;
  public
    constructor Create(AService: TService; ARelocationArg: TRelocationArg);

    function Execute: TMetadata; override;
  end;

  TFilesMoveRequest = class(TServiceRequest<TMetadata>)
  strict private
    FRelocationArg: TRelocationArg;
  public
    constructor Create(AService: TService; ARelocationArg: TRelocationArg);

    function Execute: TMetadata; override;
  end;

  TFilesSaveUrlRequest = class(TServiceRequest<TSaveUrlResult>)
  strict private
    FSaveUrlArg: TSaveUrlArg;
  public
    constructor Create(AService: TService; ASaveUrlArg: TSaveUrlArg);

    function Execute: TSaveUrlResult; override;
  end;

  TFilesSaveUrlCheckJobStatusRequest = class(TServiceRequest<TSaveUrlJobStatus>)
  strict private
    FPollArg: TPollArg;
  public
    constructor Create(AService: TService; APollArg: TPollArg);

    function Execute: TSaveUrlJobStatus; override;
  end;

implementation

{ TFilesListFolderRequest }

constructor TFilesListFolderRequest.Create(AService: TService; AListFolderArg: TListFolderArg);
begin
  inherited Create(AService);
  FListFolderArg := AListFolderArg;
end;

function TFilesListFolderRequest.Execute: TListFolderResult;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FListFolderArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/list_folder', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TListFolderResult, response) as TListFolderResult;
end;

{ TFilesCreateFolderRequest }

constructor TFilesCreateFolderRequest.Create(AService: TService; ACreateFolderArg: TCreateFolderArg);
begin
  inherited Create(AService);
  FCreateFolderArg := ACreateFolderArg;
end;

function TFilesCreateFolderRequest.Execute: TFolderMetadata;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FCreateFolderArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/create_folder', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TFolderMetadata, response) as TFolderMetadata;
end;

{ TFilesDeleteRequest }

constructor TFilesDeleteRequest.Create(AService: TService; ADeleteArg: TDeleteArg);
begin
  inherited Create(AService);
  FDeleteArg := ADeleteArg;
end;

function TFilesDeleteRequest.Execute: TMetadata;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FDeleteArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/delete', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TMetadata, response) as TMetadata;
end;

{ TFilesListFolderContinueRequest }

constructor TFilesListFolderContinueRequest.Create(AService: TService; AListFolderContinueArg: TListFolderContinueArg);
begin
  inherited Create(AService);
  FListFolderContinueArg := AListFolderContinueArg;
end;

function TFilesListFolderContinueRequest.Execute: TListFolderResult;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FListFolderContinueArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/list_folder/continue', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TListFolderResult, response) as TListFolderResult;
end;

{ TFilesUploadRequest }

constructor TFilesUploadRequest.Create(AService: TService; ACommitInfo: TCommitInfo; ABody: TStream);
begin
  inherited Create(AService);

  FCommitInfo := ACommitInfo;
  FBody := ABody;
end;

function TFilesUploadRequest.Execute: TFileMetadata;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FCommitInfo);
  response := Service.Initializer.HttpClient.ContentUploadEndPointRequest('https://content.dropboxapi.com/2/files/upload', request, FBody);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TFileMetadata, response) as TFileMetadata;
end;

{ TFilesDownloadRequest }

constructor TFilesDownloadRequest.Create(AService: TService; ADownloadArg: TDownloadArg; ABody: TStream);
begin
  inherited Create(AService);

  FDownloadArg := ADownloadArg;
  FBody := ABody;
end;

function TFilesDownloadRequest.Execute: TFileMetadata;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FDownloadArg);
  response := Service.Initializer.HttpClient.ContentDownloadEndPointRequest('https://content.dropboxapi.com/2/files/download', request, FBody);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TFileMetadata, response) as TFileMetadata;
end;

{ TFilesSearchRequest }

constructor TFilesSearchRequest.Create(AService: TService; ASearchArg: TSearchArg);
begin
  inherited Create(AService);
  FSearchArg := ASearchArg;
end;

function TFilesSearchRequest.Execute: TSearchResult;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FSearchArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/search', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TSearchResult, response) as TSearchResult;
end;

{ TFilesCopyRequest }

constructor TFilesCopyRequest.Create(AService: TService; ARelocationArg: TRelocationArg);
begin
  inherited Create(AService);
  FRelocationArg := ARelocationArg;
end;

function TFilesCopyRequest.Execute: TMetadata;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FRelocationArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/copy', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TMetadata, response) as TMetadata;
end;

{ TFilesMoveRequest }

constructor TFilesMoveRequest.Create(AService: TService; ARelocationArg: TRelocationArg);
begin
  inherited Create(AService);
  FRelocationArg := ARelocationArg;
end;

function TFilesMoveRequest.Execute: TMetadata;
var
  request, response: string;
begin
  FRelocationArg.AllowSharedFolder := True;

  request := Service.Initializer.JsonSerializer.ObjectToJson(FRelocationArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/move', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TMetadata, response) as TMetadata;
end;

{ TFilesSaveUrlRequest }

constructor TFilesSaveUrlRequest.Create(AService: TService; ASaveUrlArg: TSaveUrlArg);
begin
  inherited Create(AService);
  FSaveUrlArg := ASaveUrlArg;
end;

function TFilesSaveUrlRequest.Execute: TSaveUrlResult;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FSaveUrlArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/save_url', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TSaveUrlResult, response) as TSaveUrlResult;
end;

{ TFilesSaveUrlCheckJobStatusRequest }

constructor TFilesSaveUrlCheckJobStatusRequest.Create(AService: TService; APollArg: TPollArg);
begin
  inherited Create(AService);
  FPollArg := APollArg;
end;

function TFilesSaveUrlCheckJobStatusRequest.Execute: TSaveUrlJobStatus;
var
  request, response: string;
begin
  request := Service.Initializer.JsonSerializer.ObjectToJson(FPollArg);
  response := Service.Initializer.HttpClient.RpcEndPointRequest('https://api.dropboxapi.com/2/files/save_url/check_job_status', request);
  Result := Service.Initializer.JsonSerializer.JsonToObject(TSaveUrlJobStatus, response) as TSaveUrlJobStatus;
end;

end.
