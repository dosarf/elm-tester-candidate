module Issues.Commands exposing (..)

import Http
import Json.Decode as Decode

import Issues.Models exposing (IssueId, Issue)
import Issues.Messages exposing (..)

fetchAllIssues : Cmd Msg
fetchAllIssues =
  Http.get fetchAllIssuesUrl issueCollectionDecoder
    |> Http.send OnFetchAllIssues

fetchAllIssuesUrl : String
fetchAllIssuesUrl =
  "http://localhost:4000/issues"

issueCollectionDecoder : Decode.Decoder (List Issue)
issueCollectionDecoder =
  Decode.list issueMemberDecoder

issueMemberDecoder : Decode.Decoder Issue
issueMemberDecoder =
  Decode.map7 Issue
    (Decode.field "id" Decode.string)
    (Decode.field "type" Decode.string)
    (Decode.field "priority" Decode.string)
    (Decode.field "summary" Decode.string)
    (Decode.field "description" Decode.string)
    (Decode.field "created" Decode.float)
    (Decode.field "hidden" Decode.bool)
