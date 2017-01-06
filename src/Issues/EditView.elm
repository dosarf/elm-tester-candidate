module Issues.EditView exposing (..)

import Html exposing (Html, h1, div, text, table, tbody, thead, th, td, tr, button, i, input, textarea, select, option)
import Html.Attributes exposing (class, value, disabled, rows, selected)
import Html.Events exposing (onClick, onInput)
import Markdown

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Issue, Model, IssueMetadata)

view : Model -> Html Msg
view model =
  div []
      [ nav model.hasChanged
      , form model.editedIssue model.issueMetadata
      ]

nav : Bool -> Html Msg
nav hasIssueChanged =
  div [ class "clearfix mb2 white bg-black" ]
      [ cancelButton hasIssueChanged
      , applyButton hasIssueChanged ]

form : Issue -> IssueMetadata -> Html Msg
form editedIssue issueMetadata =
  div [ class "m3" ]
      [ input [ class "h2 col col-10"
              , value editedIssue.summary
              , onInput SummaryChanged
              ]
              []
      , (fieldSelect issueMetadata.type_ editedIssue.type_ TypeChanged |> fieldRow "Type")
      , (fieldSelect issueMetadata.priority editedIssue.priority PriorityChanged |> fieldRow "Priority")
      , div [ class "col col-10 h3 bold" ]
            [ text "Description" ]
      , textarea [ class "col col-10"
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
             ] [ text v ]
  in
    select [ onInput onInputMsg ]
           (List.map fieldOption options)


fieldRow : String -> Html Msg -> Html Msg
fieldRow displayName gadget =
  div [ class "clearfix py1" ]
      [ div [ class "col col-3 h3 bold" ]
            [ text displayName ]
      , div [ class "col col-9" ]
            [ gadget ]
      ]

cancelButton : Bool -> Html Msg
cancelButton hasIssueChanged =
  button [ class "btn btn-primary left p2"
         , onClick ShowIssues ]
         [ i [ class "mr1" ]
             [ text (if hasIssueChanged then "Cancel" else "Back") ]
         ]

applyButton : Bool -> Html Msg
applyButton hasIssueChanged =
  button [ class "btn btn-primary left p2"
         , disabled (not hasIssueChanged)
         , onClick ApplyIssueChanges ]
         [ i [ class "mr1" ]
             [ text "Apply" ]
         ]
