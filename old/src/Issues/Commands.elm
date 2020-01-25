module Issues.Commands exposing (..)

import Http
import Json.Decode as Decode
import Json.Encode as Encode

import Issues.Models exposing (IssueId, Issue, IssueConfig, IssueMetadata, Model)
import Issues.Messages exposing (..)


baseUrl : String
baseUrl =
  "/"


issueConfigUrl : String
issueConfigUrl =
  baseUrl ++ "issueConfig"


fetchIssueConfig : Cmd Msg
fetchIssueConfig =
  Http.get issueConfigUrl issueConfigDecoder
    |> Http.send OnFetchIssueConfig


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
  , fetchIssueConfig
  ]


issueMetadataDecoder : Decode.Decoder IssueMetadata
issueMetadataDecoder =
   Decode.map2 IssueMetadata
     (Decode.field "type" (Decode.list Decode.string))
     (Decode.field "priority" (Decode.list Decode.string))


issueConfigDecoder : Decode.Decoder IssueConfig
issueConfigDecoder =
  Decode.map3 IssueConfig
    (Decode.field "issueMetadata" issueMetadataDecoder)
    (Decode.field "isDiscardDelete" Decode.bool)
    (Decode.field "showAuthors" Decode.bool)


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
    (Decode.field "hidden" Decode.bool)
    (Decode.field "author" Decode.string)


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
    , ( "hidden", Encode.bool issue.hidden )
    , ( "author", Encode.string issue.author )
    ]
  in
    list
      |> Encode.object


discardIssue : Model -> IssueId -> Cmd Msg
discardIssue model issueId =
  case model.issueConfig.isDiscardDelete of
    True ->
      deleteIssue issueId
    False ->
      hideAndSaveIssue model issueId


deleteIssue : IssueId -> Cmd Msg
deleteIssue issueId =
  deleteRequest issueId
    |> Http.send OnDeleteIssue


deleteRequest : IssueId -> Http.Request String
deleteRequest issueId =
  Http.request
    { body = Http.emptyBody
    , expect = Http.expectString
    , headers = []
    , method = "DELETE"
    , timeout = Nothing
    , url = (issueUrl issueId)
    , withCredentials = False
    }


hideAndSaveIssue : Model -> IssueId -> Cmd Msg
hideAndSaveIssue model issueId =
  let
    maybeIssue =
      model.issues
        |> List.filter (\issue -> issue.id == issueId)
        |> List.head
  in
    case maybeIssue of
      Just issue ->
        saveRequest False { issue | hidden = True }
          |> Http.send OnSaveIssue

      Nothing ->
        Cmd.none
