module Issues.Models exposing (..)

import Time exposing (Time)


type alias IssueId =
  String


type alias Issue =
  { id : IssueId
  , type_ : String
  , priority : String
  , summary : String
  , description : String
  , created : Time
  , hidden : Bool
  }


type alias IssueMetadata =
  { type_ : List String
  , priority : List String

  -- whether discarded issues are merely hidden or deleted for real
  , isDiscardDelete : Bool
  }


type alias Model =
  { issueMetadata : IssueMetadata
  , issues : List Issue
  , editedIssue : Issue
  , hasChanged : Bool
  , issueIdToRemove : Maybe IssueId
  }


initialModel : Model
initialModel =
  { issueMetadata = IssueMetadata [] [] False
  , issues = []
  , editedIssue = emptyIssue
  , hasChanged = False
  , issueIdToRemove = Nothing
  }


emptyIssue : Issue
emptyIssue =
  Issue "" "" "" "" "" 0.0 False


createIssue : Model -> Issue
createIssue model =
  let
    nextIssueId =
      List.map .id model.issues
        |> List.map String.toInt
        |> List.map (Result.withDefault 0)
        |> List.maximum
        |> Maybe.withDefault 0
        |> (+) 1
        |> toString
    type_ =
      List.head model.issueMetadata.type_
        |> Maybe.withDefault ""
    priority =
      List.head model.issueMetadata.priority
        |> Maybe.withDefault ""
    description = """
Description
 * first
 * second
"""
  in
    Issue nextIssueId type_ priority "Summary" description 1234.45 False
