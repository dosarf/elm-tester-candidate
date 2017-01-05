module Main exposing (..)

import Models exposing (Model)
import Messages exposing (Msg)
import Update exposing (update)
import View exposing (view)

import Html exposing (program)

-- MODEL INIT

init : ( Model, Cmd Msg )
init =
  ( "'allo, 'allo, world", Cmd.none )

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- MAIN
main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
