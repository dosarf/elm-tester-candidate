module Issues.EditView exposing (..)

import Html exposing (Html, h1, div, text, table, tbody, thead, th, td, tr, button, i, input, textarea)
import Html.Attributes exposing (class, value)
import Html.Events exposing (onClick)
import Markdown

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, EditedIssue, Model)

view : Model -> Issue -> Html Msg
view model issue =
  div []
      [ nav
      , form issue model.editedIssue
      ]

nav : Html Msg
nav =
  div [ class "clearfix mb2 white bg-black" ]
      [ listButton ]

form : Issue -> EditedIssue -> Html Msg
form issue  editedIssue =
  div [ class "m3" ]
      [ input [ class "h1 col col-10"
              , value editedIssue.summary ]
              []
      , (text issue.id |> fieldRow "Id")
      , (input [ value editedIssue.type_ ] [] |> fieldRow "Type")
      , (input [ value editedIssue.priority ] [] |> fieldRow "Priority")
      , textarea [ class "col col-10" ] [ text editedIssue.description ]
      , Markdown.toHtml [ class "col col-10" ] editedIssue.description
      ]

fieldRow : String -> Html Msg -> Html Msg
fieldRow displayName gadget =
  div [ class "clearfix py1" ]
      [ div [ class "col col-3" ]
            [ text displayName ]
      , div [ class "col col-9" ]
            [ gadget ]
      ]

listButton : Html Msg
listButton =
  button [ class "btn left p2"
         , onClick ShowIssues ]
         [ i [ class "fa fa-chevron-left mr1" ]
             [ text "List" ]
         ]
