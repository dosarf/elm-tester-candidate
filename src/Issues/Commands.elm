module Issues.Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Issues.Models exposing (IssueId, Issue, IssueMetadata)
import Issues.Messages exposing (..)


-- FIXME - hardwired URL
baseUrl : String
baseUrl =
  "http://localhost:4000/"


issueMetadataUrl : String
issueMetadataUrl =
  baseUrl ++ "issueMetadata"


fetchIssueMetadata : Cmd Msg
fetchIssueMetadata =
  Http.get issueMetadataUrl issueMetadataDecoder
    |> Http.send OnFetchIssueMetadata


allIssuesUrl : String
allIssuesUrl =
  baseUrl ++ "issues"


fetchAllIssues : Cmd Msg
fetchAllIssues =
  Http.get allIssuesUrl issueCollectionDecoder
    |> Http.send OnFetchAllIssues


fetchIssueInitStuff : List (Cmd Msg)
fetchIssueInitStuff =
  [ fetchAllIssues
  , fetchIssueMetadata
  ]

issueMetadataDecoder : Decode.Decoder IssueMetadata
issueMetadataDecoder =
   Decode.map2 IssueMetadata
     (Decode.field "type" (Decode.list Decode.string))
     (Decode.field "priority" (Decode.list Decode.string))


issueCollectionDecoder : Decode.Decoder (List Issue)
issueCollectionDecoder =
  Decode.list memberDecoder


memberDecoder : Decode.Decoder Issue
memberDecoder =
  Decode.map7 Issue
    (Decode.field "id" Decode.string)
    (Decode.field "type" Decode.string)
    (Decode.field "priority" Decode.string)
    (Decode.field "summary" Decode.string)
    (Decode.field "description" Decode.string)
    (Decode.field "created" Decode.float)
    (Decode.field "hidden" Decode.bool)


issueUrl : IssueId -> String
issueUrl issueId =
  allIssuesUrl ++ "/" ++ issueId


saveIssue : Bool -> Issue -> Cmd Msg
saveIssue isNewIssue issue =
  saveRequest isNewIssue issue
    |> Http.send OnSaveIssue


saveRequest : Bool -> Issue -> Http.Request Issue
saveRequest isNewIssue issue =
  let
    method =
      if isNewIssue then "POST" else "PATCH"
    url =
      if isNewIssue then allIssuesUrl else (issueUrl issue.id)
  in
    Http.request
      { body = memberEncoded issue |> Http.jsonBody
      , expect = Http.expectJson memberDecoder
      , headers = []
      , method = method
      , timeout = Nothing
      , url = url
      , withCredentials = False
      }


memberEncoded : Issue -> Encode.Value
memberEncoded issue =
  let list =
    [ ( "id", Encode.string issue.id )
    , ( "type", Encode.string issue.type_ )
    , ( "priority", Encode.string issue.priority )
    , ( "summary", Encode.string issue.summary )
    , ( "description", Encode.string issue.description )
    , ( "created", Encode.float issue.created )
    , ( "hidden", Encode.bool issue.hidden )
    ]
  in
    list
      |> Encode.object