module EditingIssue exposing (Model, Msg(..), update, view)

import Html.Styled exposing (button, div, Html, input, label, option, select, text, textarea)
import Html.Styled.Attributes exposing (class, rows, selected, value)
import Html.Styled.Events exposing (onInput)
import Issue exposing (Issue)


type alias Model =
    { isEdited : Bool
    , isNew : Bool
    , issue : Issue
    }

type Msg
    = PriorityChanged Int Issue.Priority
    | TypeChanged Int Issue.Type


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        TypeChanged issueId type_ ->
            ( model, Cmd.none )

        PriorityChanged issueId priority ->
            ( model, Cmd.none )


-- https://basscss.com/v7/docs/base-forms/
view : Model -> Html Msg
view model =
    div [ class "ml2 sm-col-6" ]
        [ div
            []
            [ div
                [ class "p2 h2 bold" ]
                [ text <| "Issue #" ++ String.fromInt model.issue.id ]
            ]
        , label
              []
              [ text "Summary" ]
        , input
              [ class "block col-12 mb1 field"
              , value model.issue.summary
              -- , onInput SummaryChanged
              ]
              []
        , label
              []
              [ text "Type" ]
        , fieldSelect
              Issue.types
              model.issue.type_
              Issue.typeToString
              (Issue.typeFromString >> TypeChanged model.issue.id)
        , label
              []
              [ text "Priority" ]
        , fieldSelect
              Issue.priorities
              model.issue.priority
              Issue.priorityToString
              (Issue.priorityFromString >> PriorityChanged model.issue.id)
        , label
            []
            [ text "Description" ]
        , textarea
            [ class "block col-12 mb1 field"
            , rows 20
            , value model.issue.description
            -- , onInput DescriptionChanged
            ]
            []
        , button
            [ class "btn btn-primary"
            -- , onClick
            ]
            [ text "Save" ]
        , button
            [ class "btn btn-primary black bg-gray"
            -- , onClick
            ]
            [ text "Cancel" ]
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
