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
  , author : String
  }


type alias IssueMetadata =
  { type_ : List String
  , priority : List String
  }


type alias IssueConfig =
  { issueMetadata : IssueMetadata

  -- whether discarded issues are merely hidden or deleted for real
  , isDiscardDelete : Bool

  , showAuthors : Bool
  }


type alias Model =
  { issueConfig : IssueConfig
  , issues : List Issue
  , editedIssue : Issue
  , hasChanged : Bool
  , editingDescription : Bool
  , issueIdToRemove : Maybe IssueId
  , authors : List String
  , authorFilter : Maybe String
  }


initialModel : Model
initialModel =
  { issueConfig = emptyIssueConfig
  , issues = []
  , editedIssue = emptyIssue
  , hasChanged = False
  , editingDescription = False
  , issueIdToRemove = Nothing
  , authors = []
  , authorFilter = Nothing
  }


emptyIssueMetadata : IssueMetadata
emptyIssueMetadata =
  IssueMetadata [] []


emptyIssueConfig : IssueConfig
emptyIssueConfig =
  IssueConfig emptyIssueMetadata False False


emptyIssue : Issue
emptyIssue =
  Issue "" "" "" "" "" False ""


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
      List.head model.issueConfig.issueMetadata.type_
        |> Maybe.withDefault ""
    priority =
      List.head model.issueConfig.issueMetadata.priority
        |> Maybe.withDefault ""
    description = """## Your description
 * using [Markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) notation."""
  in
    Issue nextIssueId type_ priority "Your summary" description False "Anonymous"
