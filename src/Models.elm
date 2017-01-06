module Models exposing (..)

import Issues.Models
import Routing

type alias Model =
  { issuesModel : Issues.Models.Model
  , route : Routing.Route
  }

initialModel : Routing.Route -> Model
initialModel route =
  { issuesModel = Issues.Models.initialModel
  , route = route
  }
