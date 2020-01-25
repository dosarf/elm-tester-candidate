module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Issues.Update

import Routing exposing (parseLocation)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    IssuesMsg issuesMsg ->
      let
        ( issuesModel, cmd ) =
          Issues.Update.update issuesMsg model.issuesModel
      in
        ( { model | issuesModel = issuesModel }, Cmd.map IssuesMsg cmd )

    OnLocationChange location ->
      let newRoute =
        parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )
