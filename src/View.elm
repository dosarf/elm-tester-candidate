module View exposing (..)

import Messages exposing (Msg)
import Models exposing (Model)

import Html exposing (Html, text, div)

view : Model -> Html Msg
view model =
  div []
      [ text model ]
