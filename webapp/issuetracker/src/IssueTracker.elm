module IssueTracker exposing (Model, Msg, initialModel, update, view)

import User exposing (User, displayName, userDecoder, userEncoder)

import Css exposing (px, width)
import Html.Styled exposing (Html, div, label, text)
import Html.Styled.Attributes exposing (css)
import Mwc.Button
import Mwc.TextField


type alias Model =
    { user : Maybe User
    }


type Msg =
    Nop


initialModel : Model
initialModel =
    { user = Nothing
    }


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
    ( model
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div
        []
        [ label [] [ text (model.user |> Maybe.map User.displayName |> Maybe.withDefault "no user defined" ) ]
        ]
