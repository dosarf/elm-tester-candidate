module Issues.ListView exposing (..)

import Html exposing (Html, div, text, table, tbody, thead, th, td, tr, i, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick, onDoubleClick)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model)

view : Model -> Html Msg
view model =
  div []
      [ nav
      , list model.issues
      ]

nav : Html Msg
nav =
  div [ class "clearfix mb2 white bg-black" ]
      [ div [ class "left p2"]
            [ text "Issues" ]
      ]

list : List Issue -> Html Msg
list issues =
  div []
      [ table []
              [ thead []
                      [ tr []
                           [ th [] [ text "Id" ]
                           , th [] [ text "Type" ]
                           , th [] [ text "Priority" ]
                           , th [] [ text "Summary" ]
                           , th [] []
                           ]
                      ]
              , tbody []
                      (List.map issueRow issues)
              ]
      ]

issueRow : Issue -> Html Msg
issueRow issue =
  tr [ onDoubleClick (ShowIssue issue.id) ]
     [ td [] [ text issue.id ]
     , td [] [ text issue.type_ ]
     , td [] [ text issue.priority ]
     , td [] [ text issue.summary ]
     , td []
          [ editButton issue ]
     ]

editButton : Issue -> Html Msg
editButton issue =
  button [ class "btn regular"
         , onClick (ShowIssue issue.id) ]
         [ i [ class "fa fa-pencil mr1" ]
             [ text "Edit" ]
         ]
