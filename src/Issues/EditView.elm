module Issues.EditView exposing (..)

import Html exposing (Html, h1, div, text, table, tbody, thead, th, td, tr, button, i, input, textarea, select, option, span)
import Html.Attributes exposing (class, value, disabled, rows, selected)
import Html.Events exposing (onClick, onInput)
import Markdown

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model, IssueMetadata)

import Issues.CommonGui exposing (navBar, navButton, issueEditorButton)

view : Model -> Html Msg
view model =
  div []
      [ nav model.hasChanged
      , form model
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


form : Model -> Html Msg
form model =
  let
    editedIssue =
      model.editedIssue
    issueMetadata =
      model.issueMetadata
  in
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
              [ span [] [ text "Description" ]
              , descriptionEditOrViewButton model ]
        , descriptionEditorOrViewer model
        {-
        , textarea [ class "col col-12"
                   , rows 10
                   , onInput DescriptionChanged
                   ]
                   [ text editedIssue.description ]
        , Markdown.toHtml [ class "col col-10" ] editedIssue.description
        -}
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


descriptionEditOrViewButton : Model -> Html Msg
descriptionEditOrViewButton model =
  let
    faIcon =
      if model.editingDescription then "eye" else "edit"
    onClickMessage =
      if model.editingDescription then ViewDescription else EditDescription
  in
    issueEditorButton faIcon onClickMessage


descriptionEditorOrViewer : Model -> Html Msg
descriptionEditorOrViewer model =
  case model.editingDescription of
    True ->
      textarea [ class "col col-12"
               , rows 10
               , onInput DescriptionChanged
               ]
               [ text model.editedIssue.description ]

    False ->
      Markdown.toHtml
        [ class "col col-12 border"
        , onClick EditDescription
        ]
        model.editedIssue.description
