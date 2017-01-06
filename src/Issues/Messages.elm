module Issues.Messages exposing (..)

import Http

import Issues.Models exposing (Issue, IssueId)

type Msg =
    OnFetchAllIssues (Result Http.Error (List Issue))
  | ShowIssue IssueId
  | ShowIssues
