module Main exposing (..)

import Models exposing (Model, initialModel)
import Messages exposing (Msg(..))
import Update exposing (update)
import View exposing (view)
import Routing exposing (parseLocation)

import Issues.Commands exposing (fetchAllIssues, fetchIssueMetadata, fetchIssueInitStuff)

import Navigation exposing (Location)

-- MODEL INIT

init : Location -> ( Model, Cmd Msg )
init location =
  let currentRoute =
    Routing.parseLocation location
  in
    ( initialModel currentRoute
    , List.map (Cmd.map IssuesMsg) fetchIssueInitStuff |> Cmd.batch
    )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN
main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
