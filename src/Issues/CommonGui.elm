module Issues.CommonGui exposing (..)

import Issues.Messages exposing (Msg)

import Html exposing (Html, div, text, button, i, span)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)

navBar : List (Html Msg) -> Html Msg
navBar content =
  div [ class "clearfix mb2 white bg-black" ]
      (( div [ class "left ml2 mr2 mb1 mt1 h3" ]
             [ text "Issue Tracker "] ) :: content)

navButton : String -> String -> Msg -> Html Msg
navButton buttonText faIcon onClickMessage =
  let
    iconCssClasses =
      fontAwesomeClasses faIcon
      |> List.append [ "mr1" ]
      |> String.join " "
  in
    button [ class "btn btn-primary left mb1 mt1 mr1"
           , onClick onClickMessage ]
           [ i [ class iconCssClasses ] []
           , span [ class "h4" ] [ text buttonText ]
           ]


issueEditorButton : String -> Msg -> Html Msg
issueEditorButton faIcon onClickMessage =
  let
    iconCssClasses =
      fontAwesomeClasses faIcon
      |> String.join " "
  in
    button [ class "btn regular"
           , onClick onClickMessage
           ]
           [ i [ class iconCssClasses ]
               []
           ]


fontAwesomeClasses : String -> List String
fontAwesomeClasses faIcon =
  [ "fa"
  , "fa-" ++ faIcon
  ]
