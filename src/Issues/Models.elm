module Issues.Models exposing (..)

type alias IssueId =
  String


type alias Issue =
  { id : IssueId
  , type_ : String
  , priority : String
  , summary : String
  , description : String
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
  , editingDescription : Bool
  , issueIdToRemove : Maybe IssueId
  }


initialModel : Model
initialModel =
  { issueMetadata = IssueMetadata [] [] False
  , issues = []
  , editedIssue = emptyIssue
  , hasChanged = False
  , editingDescription = False
  , issueIdToRemove = Nothing
  }


emptyIssue : Issue
emptyIssue =
  Issue "" "" "" "" "" False


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
    description = """## Your description
 * using [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) notation."""
  in
    Issue nextIssueId type_ priority "Your summary" description False
