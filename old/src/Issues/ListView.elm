module Issues.ListView exposing (..)

import Html exposing (Html, div, text, table, tbody, thead, th, td, tr, i, button, option, select, span)
import Html.Attributes exposing (class, style, value, selected)
import Html.Events exposing (onClick, onInput)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model)

import Issues.CommonGui exposing (navBar, navButton, issueEditorButton)


view : Model -> Html Msg
view model =
  div []
      [ nav
      , authorList model
      , issueList model model.issues
      ]


nav : Html Msg
nav =
  navBar
    [ createButton
    ]


authorList : Model -> Html Msg
authorList model =
  let
    selectedAuthor =
      Maybe.withDefault "" model.authorFilter
    authorOption author =
      option [ value author
             , selected (author == selectedAuthor)
             ]
             [ text author ]
    authorsWithPseudoForNone =
      "" :: model.authors
  in
    if model.issueConfig.showAuthors then
      div []
          [ span [ class "mr1" ] [ text "Author" ]
          , select [ onInput AuthorSelected ]
                   (List.map authorOption authorsWithPseudoForNone)
          ]
    else
      div [] []


issueList : Model -> List Issue -> Html Msg
issueList model issues =
  let
    showAuthors =
      model.issueConfig.showAuthors
    visibleIssueFilter issue =
      not issue.hidden
    authorFilter issue =
      if showAuthors then
        case model.authorFilter of
          Just author ->
            issue.author == author
          Nothing ->
            True
      else
        True
    filter issue =
      visibleIssueFilter issue && authorFilter issue
    visibleIssues =
      issues |> List.filter filter
  in
    div [ class "overflow-scroll" ]
        [ table [ class "table table-light overflow-hidden bg-white" ]
                [ thead [ class "bg-darken-2 left-align" ]
                        (issueTableHeaderCells showAuthors)
                , tbody []
                        (visibleIssues |> List.map (issueRow showAuthors))
                ]
        ]


issueTableHeaderCells : Bool -> List (Html Msg)
issueTableHeaderCells showAuthors =
  let
    possibleAuthorColumn =
      if showAuthors
        then [ th [ class issueTableCellClass ] [ text "Author" ] ]
        else []
  in
    [ th [ class issueTableCellClass ] [ text "Id" ] ]
    ++ possibleAuthorColumn
    ++ [ th [ class issueTableCellClass ] [ text "Type" ]
       , th [ class issueTableCellClass ] [ text "Priority" ]
       , th [ class issueTableCellClass ] [ text "Summary" ]
       , th [] []
       ]


issueRow : Bool -> Issue -> Html Msg
issueRow showAuthors issue =
  tr []
     (issueTableDataCells showAuthors issue)


issueTableDataCells : Bool -> Issue -> List (Html Msg)
issueTableDataCells showAuthors issue =
  let
    showIssueMsg =
      ShowIssue issue.id
    possibleAuthorColumn =
      if showAuthors
        then [ issueTd issue.author showIssueMsg ]
        else []
  in
    [ issueTd issue.id showIssueMsg ]
    ++ possibleAuthorColumn
    ++ [issueTd issue.type_ showIssueMsg
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
