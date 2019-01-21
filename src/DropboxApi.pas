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

unit DropboxApi;

interface

uses
  System.Classes, System.SysUtils, clJsonSerializerBase, DropboxApi.Data;

type
  EDropboxException = class(Exception)
  strict private
    FError: TError;

    procedure SetError(const Value: TError);
    function GetErrorSummary: string;
    procedure SetErrorSummary(const Value: string);
  public
    constructor Create; overload;
    constructor Create(AError: TError); overload;
    destructor Destroy; override;

    [TclJsonString('error_summary')]
    property ErrorSummary: string read GetErrorSummary write SetErrorSummary;

    [TclJsonProperty('error')]
    property Error: TError read FError write SetError;
  end;

  TCredential = class abstract
  public
    function GetAuthorization: string; virtual; abstract;
    function RefreshAuthorization: string; virtual; abstract;
    procedure RevokeAuthorization; virtual; abstract;
    procedure Abort; virtual; abstract;
  end;

  TJsonSerializer = class abstract
  public
    function JsonToException(const AJson: string): EDropboxException; virtual; abstract;
    function ExceptionToJson(E: EDropboxException): string; virtual; abstract;

    function JsonToObject(AType: TClass; const AJson: string): TObject; virtual; abstract;
    function ObjectToJson(AObject: TObject): string; virtual; abstract;
  end;

  TServiceInitializer = class;

  THttpClient = class abstract
  strict private
    FInitializer: TServiceInitializer;
  strict protected
    function GetStatusCode: Integer; virtual; abstract;
  public
    constructor Create(AInitializer: TServiceInitializer);

    function RpcEndPointRequest(const AUri: string; const ARequest: string): string; virtual; abstract;
    function ContentUploadEndPointRequest(const AUri: string; const ARequestHeader: string; ABody: TStream): string; virtual; abstract;
    function ContentDownloadEndPointRequest(const AUri: string; const ARequestHeader: string; ABody: TStream): string; virtual; abstract;
    procedure Abort; virtual; abstract;

    property Initializer: TServiceInitializer read FInitializer;
    property StatusCode: Integer read GetStatusCode;
  end;

  TServiceInitializer = class abstract
  strict private
    FApplicationName: string;
    FCredential: TCredential;
  strict protected
    function GetHttpClient: THttpClient; virtual; abstract;
    function GetJsonSerializer: TJsonSerializer; virtual; abstract;
  public
    constructor Create(ACredential: TCredential; const ApplicationName: string);
    destructor Destroy; override;

    property HttpClient: THttpClient read GetHttpClient;
    property JsonSerializer: TJsonSerializer read GetJsonSerializer;
    property Credential: TCredential read FCredential;
    property ApplicationName: string read FApplicationName;
  end;

  TService = class
  strict private
    FInitializer: TServiceInitializer;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    procedure Abort;

    property Initializer: TServiceInitializer read FInitializer;
  end;

  TServiceRequest<TResponse> = class abstract
  strict private
    FService: TService;
  public
    constructor Create(AService: TService);

    function Execute: TResponse; virtual; abstract;

    property Service: TService read FService;
  end;

resourcestring
  cUnspecifiedError = 'Unspecified error';

implementation

{ EDropboxException }

constructor EDropboxException.Create;
begin
  inherited Create(cUnspecifiedError);
end;

constructor EDropboxException.Create(AError: TError);
begin
  inherited Create(cUnspecifiedError);
  SetError(AError);
end;

destructor EDropboxException.Destroy;
begin
  SetError(nil);
  inherited Destroy();
end;

function EDropboxException.GetErrorSummary: string;
begin
  Result := Message;
end;

procedure EDropboxException.SetError(const Value: TError);
begin
  FError.Free();
  FError := Value;
end;

procedure EDropboxException.SetErrorSummary(const Value: string);
begin
  Message := Value;
end;

{ THttpClient }

constructor THttpClient.Create(AInitializer: TServiceInitializer);
begin
  inherited Create();
  FInitializer := AInitializer;
end;

{ TServiceInitializer }

constructor TServiceInitializer.Create(ACredential: TCredential; const ApplicationName: string);
begin
  inherited Create();

  FCredential := ACredential;
  FApplicationName := ApplicationName;

  Assert(FCredential <> nil);
end;

destructor TServiceInitializer.Destroy;
begin
  FCredential.Free();
  inherited Destroy();
end;

{ TService }

procedure TService.Abort;
begin
  FInitializer.Credential.Abort();
  FInitializer.HttpClient.Abort();
end;

constructor TService.Create(AInitializer: TServiceInitializer);
begin
  inherited Create();
  FInitializer := AInitializer;
  Assert(FInitializer <> nil);
end;

destructor TService.Destroy;
begin
  FInitializer.Free();
  inherited Destroy();
end;

{ TServiceRequest<TResponse> }

constructor TServiceRequest<TResponse>.Create(AService: TService);
begin
  inherited Create();
  FService := AService;
end;

end.
