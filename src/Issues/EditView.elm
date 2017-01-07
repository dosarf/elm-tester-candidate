module Issues.EditView exposing (..)

import Html exposing (Html, h1, div, text, table, tbody, thead, th, td, tr, button, i, input, textarea, select, option, span)
import Html.Attributes exposing (class, value, disabled, rows, selected)
import Html.Events exposing (onClick, onInput)
import Markdown

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model, IssueMetadata)

import Issues.CommonGui exposing (navBar, navButton)

view : Model -> Html Msg
view model =
  div []
      [ nav model.hasChanged
      , form model.editedIssue model.issueMetadata
      ]


nav : Bool -> Html Msg
nav hasIssueChanged =
  let
    buttonsForChangedIssue =
      if hasIssueChanged then
        [ applyButton hasIssueChanged ]
      else
        []
  in
    navBar
      (List.append [ cancelButton hasIssueChanged ] buttonsForChangedIssue)


form : Issue -> IssueMetadata -> Html Msg
form editedIssue issueMetadata =
  div [ class "m3 max-width-3" ]
      [ div [ class "col col-2" ] [ text "Summary" ]
      , input [ class "h4 col col-10 mb3 bold"
              , value editedIssue.summary
              , onInput SummaryChanged
              ]
              []
      , (fieldSelect issueMetadata.type_ editedIssue.type_ TypeChanged |> fieldRow "Type")
      , (fieldSelect issueMetadata.priority editedIssue.priority PriorityChanged |> fieldRow "Priority")
      , div [ class "col col-12" ]
            [ text "Description" ]
      , textarea [ class "col col-12"
                 , rows 10
                 , onInput DescriptionChanged
                 ]
                 [ text editedIssue.description ]
      , Markdown.toHtml [ class "col col-10" ] editedIssue.description
      ]


fieldSelect : List String -> String -> (String -> Msg) -> Html Msg
fieldSelect options initialValue onInputMsg =
  let
    fieldOption v =
      option [ value v
             , selected (v == initialValue)
             ]
             [ text v ]
  in
    select [ class "bold", onInput onInputMsg ]
           (List.map fieldOption options)


fieldRow : String -> Html Msg -> Html Msg
fieldRow displayName gadget =
  div []
      [ div [ class "mb1 col col-2" ]
            [ text displayName ]
      , div [ class "mb1 col col-10" ]
            [ gadget ]
      ]


cancelButton : Bool -> Html Msg
cancelButton hasIssueChanged =
  let
    buttonText =
      if hasIssueChanged then "Cancel" else "Back"
    faIcon =
      if hasIssueChanged then "ban" else "chevron-left"
  in
    navButton buttonText faIcon ShowIssues


applyButton : Bool -> Html Msg
applyButton hasIssueChanged =
  navButton "Apply" "save" ApplyIssueChanges
