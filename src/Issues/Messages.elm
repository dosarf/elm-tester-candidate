module Issues.Messages exposing (..)

import Http

import Issues.Models exposing (Issue, IssueId, IssueMetadata)

type Msg =
    OnFetchAllIssues (Result Http.Error (List Issue))
  | OnFetchIssueMetadata (Result Http.Error IssueMetadata)
  | OnSaveIssue (Result Http.Error Issue)
  | OnIssueDeletionConfirmation (Bool, String)
  | OnDeleteIssue (Result Http.Error String)
  | CreateIssue
  | ConfirmDeleteIssue IssueId
  | ShowIssue IssueId
  | ShowIssues
  | ApplyIssueChanges
  | SummaryChanged String
  | TypeChanged String
  | PriorityChanged String
  | DescriptionChanged String
