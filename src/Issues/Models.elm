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

type alias EditedIssue =
  { type_ : String
  , priority : String
  , summary : String
  , description : String
  }

type alias Model =
  { issues : List Issue
  , editedIssue : EditedIssue
  }

initialModel : Model
initialModel =
  { issues = []
  , editedIssue = EditedIssue "" "" "" ""
  }
