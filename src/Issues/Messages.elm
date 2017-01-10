module Issues.Messages exposing (..)

import Http

import Issues.Models exposing (Issue, IssueId, IssueConfig)

type Msg =
    OnFetchAllIssues (Result Http.Error (List Issue))
  | OnFetchIssueConfig (Result Http.Error IssueConfig)
  | OnSaveIssue (Result Http.Error Issue)
  | OnIssueDiscardConfirmation (Bool, String)
  | OnDeleteIssue (Result Http.Error String)
  | CreateIssue
  | ConfirmDiscardIssue IssueId
  | ShowIssue IssueId
  | ShowIssues
  | ApplyIssueChanges
  | SummaryChanged String
  | TypeChanged String
  | PriorityChanged String
  | DescriptionChanged String
  | EditDescription
  | ViewDescription
