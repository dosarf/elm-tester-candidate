module IssueTracker exposing (Model, Msg, init, tabTextList, update, view)

import User exposing (User, usersDecoder)

import Css exposing (backgroundColor, border3, borderColor, hex, hover, px, solid, width)
import Html.Styled exposing (button, div, form, Html, input, label, option, select, span, text, textarea)
import Html.Styled.Attributes exposing (css, class, rows, selected, value)
import Html.Styled.Events exposing (onClick, onInput)
import Mwc.Button
import Mwc.TextField
import Http
import Issue exposing (Issue, issuesDecoder, priorityToString)
import Dict exposing (Dict)

-- CONSTANTS

userIssuesUri : User -> String
userIssuesUri user =
    "../../user/" ++ (String.fromInt user.id) ++ "/issue"

usersUri : String
usersUri =
    "../../user/"


editIcon : String
editIcon =
    "\u{270E}"


closeIcon : String
closeIcon =
    "\u{274C}"

-- MODEL

type alias EditingIssue =
    { id : Int
    , isEdited : Bool
    , isNew : Bool
    , issue : Issue
    }

type alias Model =
    { user : Maybe User
    , issues : Dict Int Issue
    , editingIssues : List EditingIssue
    }

mainTabText : Model -> Html Msg
mainTabText model =
    model.user
        |> Maybe.map User.displayName
        |> Maybe.map (\displayName -> "Issues (" ++ displayName ++ ")")
        |> Maybe.withDefault "(no user)"
        |> text


issueEditorTabText : Issue -> Html Msg
issueEditorTabText issue =
    span
        []
        [ text <| Issue.title issue
        , text " "
        , span
            [ onClick <| CloseIssueTab issue.id
            , css
                [ hover
                      [ borderColor (hex "55af6a")
                      , backgroundColor (hex "55af6a")
                      ]
                ]
            ]
            [ text closeIcon ]
        ]


tabTextList : Model -> List (Html Msg)
tabTextList model =
    let
        editorTabTexts =
            model.editingIssues
                |> List.map .id
                |> List.map (\issueId -> Dict.get issueId model.issues)
                |> List.map (\issueMaybe -> Maybe.map issueEditorTabText issueMaybe |> Maybe.withDefault (text "(unknown)") )
    in
        [ mainTabText model ] ++ editorTabTexts



type Msg
    = IssuesDownloaded (Result Http.Error (List Issue))
    | UsersDownloaded (Result Http.Error (List User))
    | OpenIssueTab Int
    | CloseIssueTab Int
    | PriorityChanged Int Issue.Priority


downloadUsers : Cmd Msg
downloadUsers =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = usersUri
        , body = Http.emptyBody
        , expect = Http.expectJson UsersDownloaded usersDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }


downloadIssuesOf : User -> Cmd Msg
downloadIssuesOf user =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = userIssuesUri user
        , body = Http.emptyBody
        , expect = Http.expectJson IssuesDownloaded issuesDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { user = Nothing
      , issues = Dict.empty
      , editingIssues = []
      }
    , downloadUsers
    )


issueListToDict : List Issue -> Dict Int Issue
issueListToDict issues =
    issues
        |> List.map (\issue -> (issue.id, issue))
        |> Dict.fromList


-- for testing
offlineModel : Model
offlineModel =
    let
        user =
            User 42 "John" "Doe"
    in
        { user = Just user
        , issues =
            [ Issue 12 "Do all" Issue.LOW "'nuff said!" user
            , Issue 13 "Do nothing at all" Issue.HIGH "yeah, baby" user
            ]
                |> issueListToDict
        , editingIssues = []
        }


httpErrorToString : Http.Error -> String
httpErrorToString httpError =
    case httpError of
        Http.BadUrl url ->
            "BadUrl: " ++ url
        Http.Timeout ->
            "Timeout"
        Http.NetworkError ->
            "Network error"
        Http.BadStatus code ->
            "Bad status" ++ (String.fromInt code)
        Http.BadBody body ->
            "BadBody: " ++ body


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        IssuesDownloaded result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "ISSUES HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( model
                        , Cmd.none
                        )

                Ok issues ->
                    let
                        _ =
                            Debug.log "Issues downloaded" issues
                        newIssues =
                            issues
                                |> issueListToDict
                    in
                        ( { model | issues = newIssues }
                        , Cmd.none
                        )

        UsersDownloaded result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "USERS HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( offlineModel
                        -- model
                        , Cmd.none
                        )

                Ok users ->
                    let
                        _ =
                            Debug.log "Users downloaded" users
                        firstUserMaybe =
                            List.head users
                    in
                        ( { model | user = firstUserMaybe }
                        , firstUserMaybe
                            |> Maybe.map downloadIssuesOf
                            |> Maybe.withDefault Cmd.none
                        )

        OpenIssueTab issueId ->
            let
                alreadyEdited =
                    List.filter (\issue -> issueId == issue.id) model.editingIssues
                        |> List.head
                        |> Maybe.map (\_ -> True)
                        |> Maybe.withDefault False
                editingIssues =
                    if alreadyEdited
                        then
                            model.editingIssues
                        else
                            model.editingIssues
                            ++ ( Dict.get issueId model.issues
                                |> Maybe.map (\issue -> [ EditingIssue issueId False False issue ])
                                |> Maybe.withDefault []
                              )
            in
                ( { model | editingIssues = editingIssues }
                , Cmd.none
                )

        CloseIssueTab issueId ->
            ( { model | editingIssues = List.filter (\issue -> issue.id /= issueId) model.editingIssues }
            , Cmd.none
            )

        PriorityChanged issueId priority ->
            ( model, Cmd.none )


issueSummaryView : Issue -> Html Msg
issueSummaryView issue =
    span
        []
        [ text <| Issue.title issue
        , span
            [ css
                [ border3 (px 2) solid (hex "ffffff")
                , backgroundColor (hex "ffffff")
                , hover
                    [ borderColor (hex "55af6a")
                    , backgroundColor (hex "55af6a")
                    ]
                ]
            , onClick <| OpenIssueTab issue.id
            ]
            [ text editIcon ]
        ]



issuesListItems: Model -> List(Html Msg)
issuesListItems model =
    model.issues
        |> Dict.toList
        |> List.sortBy Tuple.first
        |> List.map Tuple.second
        |> List.map (\issue -> div [] [ issueSummaryView issue ])


issuesView : Model -> Html Msg
issuesView model =
    div
        [ class "ml2 sm-col-6" ]
        [ div
            [ class "p2 bold white bg-blue" ]
            [ text "Issues" ]
        ,  div
              []
              (issuesListItems model)
        ]

-- https://basscss.com/v7/docs/base-forms/
issueEditorView : EditingIssue -> Html Msg
issueEditorView editingIssue =
    div [ class "ml2 sm-col-6" ]
        [ div
            []
            [ div
                [ class "p2 bold white bg-blue" ]
                [ text <| "Issue #" ++ (String.fromInt editingIssue.id) ]
            ]
        , label
              []
              [ text "Summary" ]
        , input
              [ class "block col-12 mb1 field"
              , value editingIssue.issue.summary
              -- , onInput SummaryChanged
              ]
              []
        , label
              []
              [ text "Priority" ]
        , fieldSelect
              Issue.priorities
              editingIssue.issue.priority
              Issue.priorityToString
              (Issue.priorityFromString >> (PriorityChanged editingIssue.id))
        , label
            [ ]
            [ text "Description" ]
        , textarea
            [ class "block col-12 mb1 field"
            , rows 20
            , value editingIssue.issue.description
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


editingIssueView : Int -> Model -> Html Msg
editingIssueView issueIndex model =
    model.editingIssues
        |> List.indexedMap Tuple.pair
        |> List.filter (\(index, issue) -> index == issueIndex)
        |> List.map Tuple.second
        |> List.head
        |> Maybe.map issueEditorView
        |> Maybe.withDefault (div [] [ text "Issue not found" ])


view : Int -> Model -> Html Msg
view currentTab model =
    case currentTab of
        0 ->
            div
                []
                [ issuesView model ]
        _ ->
            editingIssueView (currentTab - 1) model
