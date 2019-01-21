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

unit DropboxApi.Persister;

interface

uses
  System.Classes, System.SysUtils, DropboxApi, clOAuth, clUriUtils, clHttp, clHttpRequest, clHeaderFieldList,
  clJsonSerializer;

type
  TDropboxOAuthCredential = class(TCredential)
  strict private
    FClientID: string;
    FClientSecret: string;
    FRedirectURL: string;
    FOAuth: TclOAuth;
  public
    constructor Create;
    destructor Destroy; override;

    function GetAuthorization: string; override;
    function RefreshAuthorization: string; override;
    procedure RevokeAuthorization; override;
    procedure Abort; override;

    property ClientID: string read FClientID write FClientID;
    property ClientSecret: string read FClientSecret write FClientSecret;
    property RedirectURL: string read FRedirectURL write FRedirectURL;
  end;

  TDropboxHttpClient = class(THttpClient)
  strict private
    FHttp: TclHttp;

    procedure CheckResponse(const AJsonResponse: string);
  protected
    function GetStatusCode: Integer; override;
  public
    constructor Create(AInitializer: TServiceInitializer);
    destructor Destroy; override;

    function RpcEndPointRequest(const AUri: string; const ARequest: string): string; override;
    function ContentUploadEndPointRequest(const AUri: string; const ARequestHeader: string; ABody: TStream): string; override;
    function ContentDownloadEndPointRequest(const AUri: string; const ARequestHeader: string; ABody: TStream): string; override;
    procedure Abort; override;
  end;

  TDropboxJsonSerializer = class(TJsonSerializer)
  strict private
    FSerializer: clJsonSerializer.TclJsonSerializer;
  public
    constructor Create;
    destructor Destroy; override;

    function JsonToException(const AJson: string): EDropboxException; override;
    function ExceptionToJson(E: EDropboxException): string; override;

    function JsonToObject(AType: TClass; const AJson: string): TObject; override;
    function ObjectToJson(AObject: TObject): string; override;
  end;

  TDropboxServiceInitializer = class(TServiceInitializer)
  strict private
    FHttpClient: THttpClient;
    FJsonSerializer: TJsonSerializer;
  strict protected
    function GetHttpClient: THttpClient; override;
    function GetJsonSerializer: TJsonSerializer; override;
  public
    constructor Create(ACredential: TCredential; const ApplicationName: string);
    destructor Destroy; override;
  end;

implementation

{ TDropboxOAuthCredential }

procedure TDropboxOAuthCredential.Abort;
begin
  FOAuth.Close();
end;

constructor TDropboxOAuthCredential.Create;
begin
  inherited Create();
  FOAuth := TclOAuth.Create(nil);
end;

destructor TDropboxOAuthCredential.Destroy;
begin
  FOAuth.Free();
  inherited Destroy();
end;

function TDropboxOAuthCredential.GetAuthorization: string;
var
  uri: TclUrlParser;
begin
  FOAuth.AuthURL := 'https://www.dropbox.com/oauth2/authorize';
  FOAuth.TokenURL := 'https://api.dropbox.com/oauth2/token';

  FOAuth.ClientID := ClientID;
  FOAuth.ClientSecret := ClientSecret;
  FOAuth.RedirectURL := RedirectURL;

  uri := TclUrlParser.Create();
  try
    uri.Parse(FOAuth.RedirectURL);
    FOAuth.LocalWebServerPort := uri.Port;
  finally
    uri.Free();
  end;

  Result := FOAuth.GetAuthorization();
end;

function TDropboxOAuthCredential.RefreshAuthorization: string;
begin
  Result := FOAuth.RefreshAuthorization();
end;

procedure TDropboxOAuthCredential.RevokeAuthorization;
begin
  FOAuth.Close();
end;

{ TDropboxHttpClient }

procedure TDropboxHttpClient.Abort;
begin
  FHttp.Close();
end;

procedure TDropboxHttpClient.CheckResponse(const AJsonResponse: string);
begin
  if (FHttp.StatusCode >= 300) then
  begin
    if (FHttp.ResponseHeader.ContentType.ToLower().IndexOf('json') > -1) then
    begin
      raise Initializer.JsonSerializer.JsonToException(AJsonResponse);
    end else
    begin
      raise EclHttpError.Create(FHttp.StatusText, FHttp.StatusCode, AJsonResponse);
    end;
  end;
end;

constructor TDropboxHttpClient.Create(AInitializer: TServiceInitializer);
begin
  inherited Create(AInitializer);

  FHttp := TclHttp.Create(nil);
  FHttp.UserAgent := Initializer.ApplicationName;
  FHttp.SilentHTTP := True;
end;

destructor TDropboxHttpClient.Destroy;
begin
  FHttp.Free();
  inherited Destroy();
end;

function TDropboxHttpClient.GetStatusCode: Integer;
begin
  Result := FHttp.StatusCode;
end;

function TDropboxHttpClient.RpcEndPointRequest(const AUri, ARequest: string): string;
var
  req: TclHttpRequest;
  resp: TStringStream;
begin
  req := nil;
  resp := nil;
  try
    req := TclHttpRequest.Create(nil);

    if (ARequest <> '') then
    begin
      req.BuildJSONRequest(ARequest);
    end;

    resp := TStringStream.Create('', TEncoding.UTF8);

    FHttp.Authorization := Initializer.Credential.GetAuthorization();

    FHttp.Post(AUri, req, resp);

    CheckResponse(resp.DataString);

    Result := resp.DataString;
  finally
    resp.Free();
    req.Free();
  end;
end;

function TDropboxHttpClient.ContentDownloadEndPointRequest(const AUri, ARequestHeader: string; ABody: TStream): string;
var
  req: TclHttpRequest;
  fieldList: TclHeaderFieldList;
begin
  req := nil;
  fieldList := nil;
  try
    req := TclHttpRequest.Create(nil);

    req.Header.ExtraFields.Add('Dropbox-API-Arg: ' + ARequestHeader);

    FHttp.Authorization := Initializer.Credential.GetAuthorization();

    FHttp.SendRequest('POST', AUri, req.HeaderSource, nil, nil, ABody);

    fieldList := TclHeaderFieldList.Create();

    fieldList.Parse(0, FHttp.ResponseHeader.ExtraFields);

    Result := fieldList.GetFieldValue('Dropbox-API-Result');

    CheckResponse(Result);
  finally
    fieldList.Free();
    req.Free();
  end;
end;

function TDropboxHttpClient.ContentUploadEndPointRequest(const AUri, ARequestHeader: string; ABody: TStream): string;
var
  req: TclHttpRequest;
  resp: TStringStream;
begin
  req := nil;
  resp := nil;
  try
    req := TclHttpRequest.Create(nil);

    req.Header.ContentType := 'application/octet-stream';
    req.Header.ExtraFields.Add('Dropbox-API-Arg: ' + ARequestHeader);

    resp := TStringStream.Create('', TEncoding.UTF8);

    FHttp.Authorization := Initializer.Credential.GetAuthorization();

    FHttp.SendRequest('POST', AUri, req.HeaderSource, ABody, nil, resp);

    CheckResponse(resp.DataString);

    Result := resp.DataString;
  finally
    resp.Free();
    req.Free();
  end;
end;

{ TDropboxJsonSerializer }

constructor TDropboxJsonSerializer.Create;
begin
  inherited Create();
  FSerializer := clJsonSerializer.TclJsonSerializer.Create();
end;

destructor TDropboxJsonSerializer.Destroy;
begin
  FSerializer.Free();
  inherited Destroy();
end;

function TDropboxJsonSerializer.ExceptionToJson(E: EDropboxException): string;
begin
  Result := FSerializer.ObjectToJson(E);
end;

function TDropboxJsonSerializer.JsonToException(const AJson: string): EDropboxException;
begin
  Result := EDropboxException.Create();
  try
    Result := FSerializer.JsonToObject(Result, AJson) as EDropboxException;
  except
    Result.Free();
    raise;
  end;
end;

function TDropboxJsonSerializer.JsonToObject(AType: TClass; const AJson: string): TObject;
begin
  Result := FSerializer.JsonToObject(AType, AJson);
end;

function TDropboxJsonSerializer.ObjectToJson(AObject: TObject): string;
begin
  Result := FSerializer.ObjectToJson(AObject);
end;

{ TDropboxServiceInitializer }

constructor TDropboxServiceInitializer.Create(ACredential: TCredential; const ApplicationName: string);
begin
  inherited Create(ACredential, ApplicationName);

  FHttpClient := nil;
  FJsonSerializer := nil;
end;

destructor TDropboxServiceInitializer.Destroy;
begin
  FHttpClient.Free();
  FJsonSerializer.Free();

  inherited Destroy();
end;

function TDropboxServiceInitializer.GetHttpClient: THttpClient;
begin
  if (FHttpClient = nil) then
  begin
    FHttpClient := TDropboxHttpClient.Create(Self);
  end;
  Result := FHttpClient;
end;

function TDropboxServiceInitializer.GetJsonSerializer: TJsonSerializer;
begin
  if (FJsonSerializer = nil) then
  begin
    FJsonSerializer := TDropboxJsonSerializer.Create();
  end;
  Result := FJsonSerializer;
end;

end.
