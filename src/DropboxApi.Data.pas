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

unit DropboxApi.Data;

interface

uses
  System.Classes, clJsonSerializerBase;
type
  TError = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TListFolderArg = class
  strict private
    FPath: string;
    FRecursive: Boolean;
    FIncludeMediaInfo: Boolean;
    FIncludeDeleted: Boolean;
    FIncludeHasExplicitSharedMembers: Boolean;
  public
    [TclJsonRequired]
    [TclJsonString('path')]
    property Path: string read FPath write FPath;

    [TclJsonProperty('recursive')]
    property Recursive: Boolean read FRecursive write FRecursive;

    [TclJsonProperty('include_media_info')]
    property IncludeMediaInfo: Boolean read FIncludeMediaInfo write FIncludeMediaInfo;

    [TclJsonProperty('include_deleted')]
    property IncludeDeleted: Boolean read FIncludeDeleted write FIncludeDeleted;

    [TclJsonProperty('include_has_explicit_shared_members')]
    property IncludeHasExplicitSharedMembers: Boolean read FIncludeHasExplicitSharedMembers write FIncludeHasExplicitSharedMembers;
  end;

  TListFolderContinueArg = class
  strict private
    FCursor: string;
  public
    [TclJsonString('cursor')]
    property Cursor: string read FCursor write FCursor;
  end;

  [TclJsonTypeNameMap('.tag', 'file', 'DropboxApi.Data.TFileMetadata')]
  [TclJsonTypeNameMap('.tag', 'folder', 'DropboxApi.Data.TFolderMetadata')]
  [TclJsonTypeNameMap('.tag', 'deleted', 'DropboxApi.Data.TDeletedMetadata')]
  TMetadata = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TFileSharingInfo = class
  strict private
    FParentSharedFolderId: string;
    FModifiedBy: string;
    FReadOnly: Boolean;
  public
    [TclJsonProperty('read_only')]
    property ReadOnly: Boolean read FReadOnly write FReadOnly;

    [TclJsonString('parent_shared_folder_id')]
    property ParentSharedFolderId: string read FParentSharedFolderId write FParentSharedFolderId;

    [TclJsonString('modified_by')]
    property ModifiedBy: string read FModifiedBy write FModifiedBy;
  end;

  TFileMetadata = class(TMetadata)
  strict private
    FRev: string;
    FName: string;
    FPathDisplay: string;
    FPathLower: string;
    FId: string;
    FSize: Int64;
    FHasExplicitSharedMembers: Boolean;
    FServerModified: string;
    FClientModified: string;
    FSharingInfo: TFileSharingInfo;

    procedure SetSharingInfo(const Value: TFileSharingInfo);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('name')]
    property Name: string read FName write FName;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonString('client_modified')]
    property ClientModified: string read FClientModified write FClientModified;

    [TclJsonString('server_modified')]
    property ServerModified: string read FServerModified write FServerModified;

    [TclJsonString('rev')]
    property Rev: string read FRev write FRev;

    [TclJsonProperty('size')]
    property Size: Int64 read FSize write FSize;

    [TclJsonString('path_lower')]
    property PathLower: string read FPathLower write FPathLower;

    [TclJsonString('path_display')]
    property PathDisplay: string read FPathDisplay write FPathDisplay;

    //media_info

    [TclJsonProperty('sharing_info')]
    property SharingInfo: TFileSharingInfo read FSharingInfo write SetSharingInfo;

    //property_groups

    [TclJsonProperty('has_explicit_shared_members')]
    property HasExplicitSharedMembers: Boolean read FHasExplicitSharedMembers write FHasExplicitSharedMembers;
  end;

  TFolderSharingInfo = class
  strict private
    FTraverseOnly: Boolean;
    FSharedFolderId: string;
    FParentSharedFolderId: string;
    FReadOnly: Boolean;
    FNoAccess: Boolean;
  public
    [TclJsonProperty('read_only')]
    property ReadOnly: Boolean read FReadOnly write FReadOnly;

    [TclJsonString('parent_shared_folder_id')]
    property ParentSharedFolderId: string read FParentSharedFolderId write FParentSharedFolderId;

    [TclJsonString('shared_folder_id')]
    property SharedFolderId: string read FSharedFolderId write FSharedFolderId;

    [TclJsonProperty('traverse_only')]
    property TraverseOnly: Boolean read FTraverseOnly write FTraverseOnly;

    [TclJsonProperty('no_access')]
    property NoAccess: Boolean read FNoAccess write FNoAccess;
  end;

  TFolderMetadata = class(TMetadata)
  strict private
    FName: string;
    FPathDisplay: string;
    FPathLower: string;
    FId: string;
    FSharingInfo: TFolderSharingInfo;

    procedure SetSharingInfo(const Value: TFolderSharingInfo);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('name')]
    property Name: string read FName write FName;

    [TclJsonString('id')]
    property Id: string read FId write FId;

    [TclJsonString('path_lower')]
    property PathLower: string read FPathLower write FPathLower;

    [TclJsonString('path_display')]
    property PathDisplay: string read FPathDisplay write FPathDisplay;

    [TclJsonProperty('sharing_info')]
    property SharingInfo: TFolderSharingInfo read FSharingInfo write SetSharingInfo;

    //property_groups
  end;

  TDeletedMetadata = class(TMetadata)
  strict private
    FName: string;
    FPathDisplay: string;
    FPathLower: string;
  public
    constructor Create;

    [TclJsonString('name')]
    property Name: string read FName write FName;

    [TclJsonString('path_lower')]
    property PathLower: string read FPathLower write FPathLower;

    [TclJsonString('path_display')]
    property PathDisplay: string read FPathDisplay write FPathDisplay;
  end;

  TListFolderResult = class
  strict private
    FEntries: TArray<TMetadata>;
    FCursor: string;
    FHasMore: Boolean;

    procedure SetEntries(const Value: TArray<TMetadata>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('entries')]
    property Entries: TArray<TMetadata> read FEntries write SetEntries;

    [TclJsonString('cursor')]
    property Cursor: string read FCursor write FCursor;

    [TclJsonProperty('has_more')]
    property HasMore: Boolean read FHasMore write FHasMore;
  end;

  TCreateFolderArg = class
  strict private
    FPath: string;
    FAutoRename: Boolean;
  public
    [TclJsonString('path')]
    property Path: string read FPath write FPath;

    [TclJsonProperty('autorename')]
    property AutoRename: Boolean read FAutoRename write FAutoRename;
  end;

  TDeleteArg = class
  strict private
    FPath: string;
  public
    [TclJsonString('path')]
    property Path: string read FPath write FPath;
  end;

  [TclJsonTypeNameMap('.tag', 'add', 'DropboxApi.Data.TAddWriteMode')]
  [TclJsonTypeNameMap('.tag', 'overwrite', 'DropboxApi.Data.TOverwriteWriteMode')]
  [TclJsonTypeNameMap('.tag', 'update', 'DropboxApi.Data.TUpdateWriteMode')]
  TWriteMode = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TAddWriteMode = class(TWriteMode)
  public
    constructor Create;
  end;

  TOverwriteWriteMode = class(TWriteMode)
  public
    constructor Create;
  end;

  TUpdateWriteMode = class(TWriteMode)
  strict private
    FUpdate: string;
  public
    constructor Create;

    [TclJsonString('update')]
    property Update: string read FUpdate write FUpdate;
  end;

  TCommitInfo = class
  strict private
    FPath: string;
    FMode: TWriteMode;
    FMute: Boolean;
    FAutoRename: Boolean;
    FClientModified: string;

    procedure SetMode(const Value: TWriteMode);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonString('path')]
    property Path: string read FPath write FPath;

    [TclJsonProperty('mode')]
    property Mode: TWriteMode read FMode write SetMode;

    [TclJsonProperty('autorename')]
    property AutoRename: Boolean read FAutoRename write FAutoRename;

    [TclJsonProperty('client_modified')]
    property ClientModified: string read FClientModified write FClientModified;

    [TclJsonProperty('mute')]
    property Mute: Boolean read FMute write FMute;
  end;

  TDownloadArg = class
  strict private
    FPath: string;
  public
    [TclJsonString('path')]
    property Path: string read FPath write FPath;
  end;

  [TclJsonTypeNameMap('.tag', 'filename', 'DropboxApi.Data.TFileNameSearchMode')]
  [TclJsonTypeNameMap('.tag', 'filename_and_content', 'DropboxApi.Data.TFilenameAndContentSearchMode')]
  [TclJsonTypeNameMap('.tag', 'deleted_filename', 'DropboxApi.Data.TDeletedFilenameSearchMode')]
  TSearchMode = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TFileNameSearchMode = class(TSearchMode)
  public
    constructor Create;
  end;

  TFilenameAndContentSearchMode = class(TSearchMode)
  public
    constructor Create;
  end;

  TDeletedFilenameSearchMode = class(TSearchMode)
  public
    constructor Create;
  end;

  TSearchArg = class
  strict private
    FPath: string;
    FQuery: string;
    FStart: Int64;
    FMaxResults: Int64;
    FMode: TSearchMode;

    procedure SetMode(const Value: TSearchMode);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonRequired]
    [TclJsonString('path')]
    property Path: string read FPath write FPath;

    [TclJsonRequired]
    [TclJsonString('query')]
    property Query: string read FQuery write FQuery;

    [TclJsonProperty('start')]
    property Start: Int64 read FStart write FStart;

    [TclJsonProperty('max_results')]
    property MaxResults: Int64 read FMaxResults write FMaxResults;

    [TclJsonProperty('mode')]
    property Mode: TSearchMode read FMode write SetMode;
  end;

  [TclJsonTypeNameMap('.tag', 'filename', 'DropboxApi.Data.TFileNameSearchMatchType')]
  [TclJsonTypeNameMap('.tag', 'content', 'DropboxApi.Data.TContentSearchMatchType')]
  [TclJsonTypeNameMap('.tag', 'both', 'DropboxApi.Data.TBothSearchMatchType')]
  TSearchMatchType = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TFileNameSearchMatchType = class(TSearchMatchType)
  public
    constructor Create;
  end;

  TContentSearchMatchType = class(TSearchMatchType)
  public
    constructor Create;
  end;

  TBothSearchMatchType = class(TSearchMatchType)
  public
    constructor Create;
  end;

  TSearchMatch = class
  strict private
    FMatchType: TSearchMatchType;
    FMetadata: TMetadata;

    procedure SetMatchType(const Value: TSearchMatchType);
    procedure SetMetadata(const Value: TMetadata);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('match_type')]
    property MatchType: TSearchMatchType read FMatchType write SetMatchType;

    [TclJsonProperty('metadata')]
    property Metadata: TMetadata read FMetadata write SetMetadata;
  end;

  TSearchResult = class
  strict private
    FMatches: TArray<TSearchMatch>;
    FMore: Boolean;
    FStart: Int64;

    procedure SetMatches(const Value: TArray<TSearchMatch>);
  public
    constructor Create;
    destructor Destroy; override;

    [TclJsonProperty('matches')]
    property Matches: TArray<TSearchMatch> read FMatches write SetMatches;

    [TclJsonProperty('more')]
    property More: Boolean read FMore write FMore;

    [TclJsonProperty('start')]
    property Start: Int64 read FStart write FStart;
  end;

  TRelocationArg = class
  strict private
    FFromPath: string;
    FToPath: string;
    FAllowSharedFolder: Boolean;
    FAutoRename: Boolean;
  public
    [TclJsonString('from_path')]
    property FromPath: string read FFromPath write FFromPath;

    [TclJsonString('to_path')]
    property ToPath: string read FToPath write FToPath;

    [TclJsonProperty('allow_shared_folder')]
    property AllowSharedFolder: Boolean read FAllowSharedFolder write FAllowSharedFolder;

    [TclJsonProperty('autorename')]
    property AutoRename: Boolean read FAutoRename write FAutoRename;
  end;

  TSaveUrlArg = class
  strict private
    FPath: string;
    FUrl: string;
  public
    [TclJsonString('path')]
    property Path: string read FPath write FPath;

    [TclJsonString('url')]
    property Url: string read FUrl write FUrl;
  end;

  [TclJsonTypeNameMap('.tag', 'async_job_id', 'DropboxApi.Data.TSaveUrlResultAsyncJobId')]
  [TclJsonTypeNameMap('.tag', 'complete', 'DropboxApi.Data.TSaveUrlResultComplete')]
  TSaveUrlResult = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TSaveUrlResultAsyncJobId = class(TSaveUrlResult)
  strict private
    FAsyncJobId: string;
  public
    constructor Create;

    [TclJsonString('async_job_id')]
    property AsyncJobId: string read FAsyncJobId write FAsyncJobId;
  end;

  //TODO implement unions of different types without the common ancentor in json serializer
  //here must be the TFileMetadata class
  TSaveUrlResultComplete = class(TSaveUrlResult)
  public
    constructor Create;
  end;

  TPollArg = class
  strict private
    FAsyncJobId: string;
  public
    [TclJsonString('async_job_id')]
    property AsyncJobId: string read FAsyncJobId write FAsyncJobId;
  end;

  [TclJsonTypeNameMap('.tag', 'in_progress', 'DropboxApi.Data.TSaveUrlJobStatusInProgress')]
  [TclJsonTypeNameMap('.tag', 'complete', 'DropboxApi.Data.TSaveUrlJobStatusComplete')]
  [TclJsonTypeNameMap('.tag', 'failed', 'DropboxApi.Data.TSaveUrlJobStatusFailed')]
  TSaveUrlJobStatus = class
  strict private
    FTag: string;
  public
    [TclJsonString('.tag')]
    property Tag: string read FTag write FTag;
  end;

  TSaveUrlJobStatusInProgress = class(TSaveUrlJobStatus)
  public
    constructor Create;
  end;

  //TODO implement unions of different types without the common ancentor in json serializer
  //here must be the TFileMetadata class
  TSaveUrlJobStatusComplete = class(TSaveUrlJobStatus)
  public
    constructor Create;
  end;

  TSaveUrlJobStatusFailed = class(TSaveUrlJobStatus)
  public
    constructor Create;
  end;

implementation

{ TListFolderResult }

constructor TListFolderResult.Create;
begin
  inherited Create();
  FEntries := nil;
end;

destructor TListFolderResult.Destroy;
begin
  SetEntries(nil);
  inherited Destroy();
end;

procedure TListFolderResult.SetEntries(const Value: TArray<TMetadata>);
var
  obj: TObject;
begin
  if (FEntries <> nil) then
  begin
    for obj in FEntries do
    begin
      obj.Free();
    end;
  end;

  FEntries := Value;
end;

{ TFolderMetadata }

constructor TFolderMetadata.Create;
begin
  inherited Create();

  FSharingInfo := nil;
  Tag := 'folder';
end;

destructor TFolderMetadata.Destroy;
begin
  FSharingInfo.Free();
  inherited Destroy();
end;

procedure TFolderMetadata.SetSharingInfo(const Value: TFolderSharingInfo);
begin
  FSharingInfo.Free();
  FSharingInfo := Value;
end;

{ TFileMetadata }

constructor TFileMetadata.Create;
begin
  inherited Create();

  FSharingInfo := nil;
  Tag := 'file';
end;

destructor TFileMetadata.Destroy;
begin
  FSharingInfo.Free();
  inherited Destroy();
end;

procedure TFileMetadata.SetSharingInfo(const Value: TFileSharingInfo);
begin
  FSharingInfo.Free();
  FSharingInfo := Value;
end;

{ TCommitInfo }

constructor TCommitInfo.Create;
begin
  inherited Create();
  FMode := nil;
end;

destructor TCommitInfo.Destroy;
begin
  SetMode(nil);
  inherited Destroy();
end;

procedure TCommitInfo.SetMode(const Value: TWriteMode);
begin
  FMode.Free();
  FMode := Value;
end;

{ TDeletedMetadata }

constructor TDeletedMetadata.Create;
begin
  inherited Create();
  Tag := 'deleted';
end;

{ TAdd }

constructor TAddWriteMode.Create;
begin
  inherited Create();
  Tag := 'add';
end;

{ TUpdate }

constructor TUpdateWriteMode.Create;
begin
  inherited Create();
  Tag := 'update';
end;

{ TOverwrite }

constructor TOverwriteWriteMode.Create;
begin
  inherited Create();
  Tag := 'overwrite';
end;

{ TFileName }

constructor TFileNameSearchMode.Create;
begin
  inherited Create();
  Tag := 'filename';
end;

{ TFilenameAndContent }

constructor TFilenameAndContentSearchMode.Create;
begin
  inherited Create();
  Tag := 'filename_and_content';
end;

{ TDeletedFilename }

constructor TDeletedFilenameSearchMode.Create;
begin
  inherited Create();
  Tag := 'deleted_filename';
end;

{ TSearchArg }

constructor TSearchArg.Create;
begin
  inherited Create();
  FMode := nil;
  MaxResults := 100;
end;

destructor TSearchArg.Destroy;
begin
  SetMode(nil);
  inherited Destroy();
end;

procedure TSearchArg.SetMode(const Value: TSearchMode);
begin
  FMode.Free();
  FMode := Value;
end;

{ TSearchResult }

constructor TSearchResult.Create;
begin
  inherited Create();
  FMatches := nil;
end;

destructor TSearchResult.Destroy;
begin
  SetMatches(nil);
  inherited Destroy();
end;

procedure TSearchResult.SetMatches(const Value: TArray<TSearchMatch>);
var
  obj: TObject;
begin
  if (FMatches <> nil) then
  begin
    for obj in FMatches do
    begin
      obj.Free();
    end;
  end;

  FMatches := Value;
end;

{ TFileNameSearchMatchType }

constructor TFileNameSearchMatchType.Create;
begin
  inherited Create();
  Tag := 'filename';
end;

{ TContentSearchMatchType }

constructor TContentSearchMatchType.Create;
begin
  inherited Create();
  Tag := 'content';
end;

{ TBothSearchMatchType }

constructor TBothSearchMatchType.Create;
begin
  inherited Create();
  Tag := 'both';
end;

{ TSearchMatch }

constructor TSearchMatch.Create;
begin
  inherited Create();

  FMatchType := nil;
  FMetadata := nil;
end;

destructor TSearchMatch.Destroy;
begin
  SetMatchType(nil);
  SetMetadata(nil);

  inherited Destroy();
end;

procedure TSearchMatch.SetMatchType(const Value: TSearchMatchType);
begin
  FMatchType.Free();
  FMatchType := Value;
end;

procedure TSearchMatch.SetMetadata(const Value: TMetadata);
begin
  FMetadata.Free();
  FMetadata := Value;
end;

{ TSaveUrlResultAsyncJobId }

constructor TSaveUrlResultAsyncJobId.Create;
begin
  inherited Create();
  Tag := 'async_job_id';
end;

{ TSaveUrlResultComplete }

constructor TSaveUrlResultComplete.Create;
begin
  inherited Create();
  Tag := 'complete';
end;

{ TSaveUrlJobStatusInProgress }

constructor TSaveUrlJobStatusInProgress.Create;
begin
  inherited Create();
  Tag := 'in_progress';
end;

{ TSaveUrlJobStatusComplete }

constructor TSaveUrlJobStatusComplete.Create;
begin
  inherited Create();
  Tag := 'complete';
end;

{ TSaveUrlJobStatusFailed }

constructor TSaveUrlJobStatusFailed.Create;
begin
  inherited Create();
  Tag := 'failed';
end;

procedure ForceReferenceToClass(C: TClass);
begin
end;

initialization
  ForceReferenceToClass(TError);
  ForceReferenceToClass(TListFolderArg);
  ForceReferenceToClass(TListFolderContinueArg);
  ForceReferenceToClass(TMetadata);
  ForceReferenceToClass(TFileSharingInfo);
  ForceReferenceToClass(TFileMetadata);
  ForceReferenceToClass(TFolderSharingInfo);
  ForceReferenceToClass(TFolderMetadata);
  ForceReferenceToClass(TDeletedMetadata);
  ForceReferenceToClass(TListFolderResult);
  ForceReferenceToClass(TCreateFolderArg);
  ForceReferenceToClass(TDeleteArg);
  ForceReferenceToClass(TWriteMode);
  ForceReferenceToClass(TAddWriteMode);
  ForceReferenceToClass(TOverwriteWriteMode);
  ForceReferenceToClass(TUpdateWriteMode);
  ForceReferenceToClass(TCommitInfo);
  ForceReferenceToClass(TDownloadArg);
  ForceReferenceToClass(TSearchMode);
  ForceReferenceToClass(TFileNameSearchMode);
  ForceReferenceToClass(TFilenameAndContentSearchMode);
  ForceReferenceToClass(TDeletedFilenameSearchMode);
  ForceReferenceToClass(TSearchArg);
  ForceReferenceToClass(TSearchMatchType);
  ForceReferenceToClass(TFileNameSearchMatchType);
  ForceReferenceToClass(TContentSearchMatchType);
  ForceReferenceToClass(TBothSearchMatchType);
  ForceReferenceToClass(TSearchMatch);
  ForceReferenceToClass(TSearchResult);
  ForceReferenceToClass(TRelocationArg);
  ForceReferenceToClass(TSaveUrlArg);
  ForceReferenceToClass(TSaveUrlResult);
  ForceReferenceToClass(TSaveUrlResultAsyncJobId);
  ForceReferenceToClass(TSaveUrlResultComplete);
  ForceReferenceToClass(TPollArg);
  ForceReferenceToClass(TSaveUrlJobStatus);
  ForceReferenceToClass(TSaveUrlJobStatusInProgress);
  ForceReferenceToClass(TSaveUrlJobStatusComplete);
  ForceReferenceToClass(TSaveUrlJobStatusFailed);

end.
