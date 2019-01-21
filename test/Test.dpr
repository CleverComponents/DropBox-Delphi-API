program Test;

uses
  Vcl.Forms,
  TestFrameWork,
  GUITestRunner,
  DropboxManager.Tests in 'DropboxManager.Tests.pas',
  clJsonSerializer in '..\..\JsonSerializer\json\clJsonSerializer.pas',
  clJsonSerializerBase in '..\..\JsonSerializer\json\clJsonSerializerBase.pas',
  DropboxManager in '..\src\DropboxManager.pas',
  DropboxApi.Data in '..\src\DropboxApi.Data.pas',
  DropboxApi in '..\src\DropboxApi.pas',
  DropboxApi.Persister in '..\src\DropboxApi.Persister.pas',
  DropboxApi.Routes in '..\src\DropboxApi.Routes.pas',
  DropboxApi.Requests in '..\src\DropboxApi.Requests.pas',
  clJsonParser in '..\..\JsonSerializer\json\clJsonParser.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
