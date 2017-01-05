module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    NoOp ->
      ( model, Cmd.none )
