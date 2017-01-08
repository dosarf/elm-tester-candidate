module Issues.ListView exposing (..)

import Html exposing (Html, div, text, table, tbody, thead, th, td, tr, i, button)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model)

import Issues.CommonGui exposing (navBar, navButton, issueEditorButton)


view : Model -> Html Msg
view model =
  div []
      [ nav
      , list model.issues
      ]


nav : Html Msg
nav =
  navBar
    [ createButton
    ]


list : List Issue -> Html Msg
list issues =
  let
    visibleIssues =
      issues |> List.filter (\issue -> not issue.hidden)
  in
    div [ class "overflow-scroll" ]
        [ table [ class "table table-light overflow-hidden bg-white" ]
                [ thead [ class "bg-darken-2 left-align" ]
                        [ tr []
                             [ th [ class issueTableCellClass ] [ text "Id" ]
                             , th [ class issueTableCellClass ] [ text "Type" ]
                             , th [ class issueTableCellClass ] [ text "Priority" ]
                             , th [ class issueTableCellClass ] [ text "Summary" ]
                             , th [] []
                             ]
                        ]
                , tbody []
                        (List.map issueRow visibleIssues)
                ]
        ]


issueRow : Issue -> Html Msg
issueRow issue =
  let
    showIssueMsg =
      ShowIssue issue.id
  in
    tr []
       [ issueTd issue.id showIssueMsg
       , issueTd issue.type_ showIssueMsg
       , issueTd issue.priority showIssueMsg
       , issueTd issue.summary showIssueMsg
       , td []
            [ editButton issue
            , discardButton issue
            ]
       ]


issueTd : String -> Msg -> Html Msg
issueTd tdText onClickMessage =
  td [ class issueTableCellClass
     , style [ ("cursor", "pointer") ]
     , onClick onClickMessage
     ]
     [ text tdText ]


editButton : Issue -> Html Msg
editButton issue =
  issueEditorButton "pencil" (ShowIssue issue.id)


discardButton : Issue -> Html Msg
discardButton issue =
  issueEditorButton "trash" (ConfirmDiscardIssue issue.id)


createButton : Html Msg
createButton =
  navButton "Create" "plus-circle" CreateIssue


issueTableCellClass : String
issueTableCellClass =
  "table-cell pl1 pr1"
