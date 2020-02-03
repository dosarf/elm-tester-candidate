module EditingIssue exposing (
    Model, Msg(..),
    title,
    newIssue, startEditingIssue, updateIssue, shouldSaveIssue, shouldCreateIssue,
    update, view)

import Html.Styled exposing (button, div, Html, input, label, option, select, span, text, textarea)
import Html.Styled.Attributes exposing (class, disabled, rows, selected, value)
import Html.Styled.Events exposing (onClick, onInput)
import Html.Attributes
import FontAwesome
import Markdown
import User exposing (User)
import Issue exposing (Issue)

-- CONSTANTS

editIcon : Html Msg
editIcon =
    span
        [ class "ml1" ]
        [ FontAwesome.icon FontAwesome.edit |> Html.Styled.fromUnstyled ]


viewIcon : Html Msg
viewIcon =
    span
        [ class "ml1" ]
        [ FontAwesome.icon FontAwesome.eye |> Html.Styled.fromUnstyled ]

-- MODEL

type MarkdownMode
    = ViewMarkdown
    | EditMarkdown


type alias Model =
    { isEdited : Bool
    , isNew : Bool
    , issue : Issue
    , markdownMode : MarkdownMode
    }

type Msg
    = SummaryChanged String
    | PriorityChanged Issue.Priority
    | TypeChanged Issue.Type
    | DescriptionChanged String
    | SaveIssue
    | CreateIssue
    | ToggleMarkdownMode


maxLimitedSummaryLength : Int
maxLimitedSummaryLength =
    13


idString : Model -> String
idString model =
    if model.isNew
        then
            "NEW"
        else
            "#" ++ String.fromInt model.issue.id


title : Model -> String
title model =
    let
        modifiedPrefix =
            if model.isEdited then "*" else ""

        limitedSummary =
            let
                fullSummary = model.issue.summary
            in
                if String.length fullSummary <= maxLimitedSummaryLength
                    then
                        fullSummary
                    else
                        String.left maxLimitedSummaryLength fullSummary ++ "..."

    in
        modifiedPrefix ++ (idString model) ++ " " ++ limitedSummary


newIssue : Int -> User -> Model
newIssue id user =
    { isEdited = False
    , isNew = True
    , issue = Issue.newIssue id user
    , markdownMode = ViewMarkdown
    }

startEditingIssue : Issue -> Model
startEditingIssue issue =
    Model False False issue ViewMarkdown


updateIssue : Issue -> Model -> Model
updateIssue issue model =
    { model
    | issue = issue
    , isEdited = False
    , isNew = Issue.isNewIssue issue
    , markdownMode = ViewMarkdown
    }


shouldSaveIssue : Msg -> Bool
shouldSaveIssue msg =
    msg == SaveIssue


shouldCreateIssue : Msg -> Bool
shouldCreateIssue msg =
    msg == CreateIssue


update : Msg -> Model -> Model
update msg model =
    case msg of
        SummaryChanged summary ->
            let
                _ = Debug.log "summary" summary
            in
            { model
            | isEdited = True
            , issue = Issue.changeSummary summary model.issue
            }

        TypeChanged type_ ->
            { model
            | isEdited = True
            , issue = Issue.changeType type_ model.issue
            }

        PriorityChanged priority ->
            { model
            | isEdited = True
            , issue = Issue.changePriority priority model.issue
            }

        DescriptionChanged description ->
            { model
            | isEdited = True
            , issue = Issue.changeDescription description model.issue
            }

        SaveIssue ->
            model

        CreateIssue ->
            model

        ToggleMarkdownMode ->
            { model | markdownMode = if model.markdownMode == ViewMarkdown then EditMarkdown else ViewMarkdown
            }


markdownOptions : Markdown.Options
markdownOptions =
    { githubFlavored = Just { tables = False, breaks = False }
    , defaultHighlighting = Nothing
    , sanitize = True
    , smartypants = False
    }


descriptionView : Model -> Html Msg
descriptionView model =
    case model.markdownMode of
        ViewMarkdown ->
            Markdown.toHtmlWith
                markdownOptions
                [ Html.Attributes.class "border" ]
                model.issue.description
                |> Html.Styled.fromUnstyled

        EditMarkdown ->
            textarea
                [ class "block col-12 mb1 field"
                , rows 20
                , value model.issue.description
                , onInput DescriptionChanged
                ]
                []

-- https://basscss.com/v7/docs/base-forms/
view : Model -> Html Msg
view model =
    div [ class "ml2 sm-col-6" ]
        [ div
            []
            [ div
                [ class "p2 h2 bold" ]
                [ text <| idString model ]
            ]
        , label
              [ class "bold" ]
              [ text "Summary" ]
        , input
              [ class "block col-12 mb1 field"
              , value model.issue.summary
              , onInput SummaryChanged
              ]
              []
        , label
              [ class "bold" ]
              [ text "Type" ]
        , fieldSelect
              Issue.types
              model.issue.type_
              Issue.typeToString
              (Issue.typeFromString >> TypeChanged)
        , label
              [ class "bold" ]
              [ text "Priority" ]
        , fieldSelect
              Issue.priorities
              model.issue.priority
              Issue.priorityToString
              (Issue.priorityFromString >> PriorityChanged)
        , div
            []
            [ label
                [ class "bold" ]
                [ text "Description" ]
            , button
                [ class "btn btn-primary ml4 black bg-aqua"
                , onClick ToggleMarkdownMode
                ]
                ( if model.markdownMode == ViewMarkdown
                    then
                        [ text "Edit", editIcon ]
                    else
                        [ text "View", viewIcon ]
                )
            ]
        , descriptionView model
        , button
            [ if not model.isEdited then (class "btn btn-primary black bg-silver") else (class "btn btn-primary")
            , disabled (not model.isEdited)
            , onClick <| if model.isNew then CreateIssue else SaveIssue
            ]
            [ text <| if model.isNew then "Create" else "Save" ]
        ]


fieldSelect : List a -> a -> (a -> String) -> (String -> Msg) -> Html Msg
fieldSelect options currentValue optionToString onInputMsg =
    let
      fieldOption v =
          option [ value <| optionToString v
                 , selected (v == currentValue)
                 ]
                 [ text <| optionToString v ]
    in
      select
          [ class "block col-4 mb1 field"
          , onInput <| onInputMsg
          ]
          (List.map fieldOption options)
