module Issues.Messages exposing (..)

import Http

import Issues.Models exposing (Issue, IssueId, IssueMetadata)

type Msg =
    OnFetchAllIssues (Result Http.Error (List Issue))
  | OnFetchIssueMetadata (Result Http.Error IssueMetadata)
  | OnSaveIssue (Result Http.Error Issue)
  | CreateIssue
  | ShowIssue IssueId
  | ShowIssues
  | ApplyIssueChanges
  | SummaryChanged String
  | TypeChanged String
  | PriorityChanged String
  | DescriptionChanged String
