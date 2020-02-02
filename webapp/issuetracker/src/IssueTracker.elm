module IssueTracker exposing (Model, Msg, init, tabTextList, update, view)

import User exposing (User, usersDecoder)

import Css exposing (backgroundColor, border3, borderColor, cursor, hex, hover, pointer, px, solid, width)
import Html.Styled exposing (button, div, form, Html, input, label, option, select, span, text, textarea)
import Html.Styled.Attributes exposing (css, class, rows, selected, value)
import Html.Styled.Events exposing (onClick, onInput)
import Mwc.Button
import Mwc.TextField
import Http
import Dict exposing (Dict)
import FontAwesome
import Issue exposing (Issue, issuesDecoder, priorityToString)
import EditingIssue

-- CONSTANTS

userIssuesUri : User -> String
userIssuesUri user =
    "../../user/" ++ (String.fromInt user.id) ++ "/issue"

usersUri : String
usersUri =
    "../../user/"


editIcon : Html Msg
editIcon =
    span
        [ class "ml1" ]
        [ (FontAwesome.icon FontAwesome.edit) |> Html.Styled.fromUnstyled ]


closeIcon : Html Msg
closeIcon =
    span
        [ class "ml1" ]
        [ (FontAwesome.icon FontAwesome.windowClose) |> Html.Styled.fromUnstyled ]

-- MODEL

type alias Model =
    { user : Maybe User
    , issues : Dict Int Issue
    , editingIssues : List EditingIssue.Model
    , editingIndex : Int
    }


mainTabText : Model -> Html Msg
mainTabText model =
    model.user
        |> Maybe.map User.displayName
        |> Maybe.map (\displayName -> "Issues (" ++ displayName ++ ")")
        |> Maybe.withDefault "(no user)"
        |> (\txt -> span [ class "h3" ] [ text txt ])


-- TODO rename this is not tab text
-- TODO the summary is to be cut to N chars for the tab text
issueEditorTabText : Issue -> Html Msg
issueEditorTabText issue =
    span
        [ class "h3" ]
        [ text <| Issue.title issue
        , span
            [ class "ml1"
            , onClick <| CloseIssueTab issue.id
            , css
                [ hover
                      [ cursor pointer
                      ]
                ]
            ]
            [ closeIcon ]
        ]


-- TODO rename this is not tab text
tabTextList : Model -> List (Html Msg)
tabTextList model =
    let
        editorTabTexts =
            model.editingIssues
                |> List.map .issue
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
    | EditingIssueMsg EditingIssue.Msg


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
      , editingIndex = 0
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
            [ Issue 12 "Do all" Issue.ENHANCEMENT Issue.LOW "'nuff said!" user
            , Issue 13 "Do nothing at all" Issue.DEFECT Issue.HIGH "yeah, baby" user
            ]
                |> issueListToDict
        , editingIssues = []
        , editingIndex = 0
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


update : Msg -> Int -> Model -> (Model, Cmd Msg)
update msg editingIndex model =
    case msg of
        IssuesDownloaded result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "ISSUES HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( { model | editingIndex = editingIndex }
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
                        ( { model
                          | issues = newIssues
                          , editingIndex = editingIndex
                          }
                        , Cmd.none
                        )

        UsersDownloaded result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "USERS HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( { offlineModel | editingIndex = editingIndex }
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
                        ( { model
                          | user = firstUserMaybe
                          , editingIndex = editingIndex
                          }
                        , firstUserMaybe
                            |> Maybe.map downloadIssuesOf
                            |> Maybe.withDefault Cmd.none
                        )

        OpenIssueTab issueId ->
            let
                alreadyEdited =
                    List.filter (\editingIssue -> issueId == editingIssue.issue.id) model.editingIssues
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
                                |> Maybe.map (\issue -> [ EditingIssue.Model False False issue ])
                                |> Maybe.withDefault []
                              )
            in
                ( { model
                  | editingIssues = editingIssues
                  , editingIndex = editingIndex
                  }
                , Cmd.none
                )

        CloseIssueTab issueId ->
            ( { model
              | editingIssues = List.filter (\editingIssue -> editingIssue.issue.id /= issueId) model.editingIssues
              , editingIndex = editingIndex
              }
            , Cmd.none
            )

        EditingIssueMsg editingIssueMsg ->
            ( { model | editingIndex = editingIndex }
            , Cmd.none
            )
        {-
            let
                currentEditingIssue =

                ( editingIssueModel, cmd ) =

            in
                ( { model
                  | editingIssueModel = editingIssueModel
                  , editingIndex = editingIndex
                  }
                , Cmd.map EditingIssueMsg cmd
                )
        -}


issueSummaryView : Issue -> Html Msg
issueSummaryView issue =
    div
        [ class "h3" ]
        [ text <| Issue.title issue
        , span
            [ css
                [ border3 (px 2) solid (hex "ffffff")
                , backgroundColor (hex "ffffff")
                , hover
                    [ cursor pointer ]
                ]
            , onClick <| OpenIssueTab issue.id
            ]
            [ editIcon ]
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
            [ class "p2 h2 bold" ]
            [ text "Issues" ]
        ,  div
              []
              (issuesListItems model)
        ]


editingIssueView : Int -> Model -> Html Msg
editingIssueView issueIndex model =
    model.editingIssues
        |> List.indexedMap Tuple.pair
        |> List.filter (\(index, issue) -> index == issueIndex)
        |> List.map Tuple.second
        |> List.head
        |> Maybe.map EditingIssue.view
        |> Maybe.map (Html.Styled.map EditingIssueMsg)
        |> Maybe.withDefault (div [] [ text "(select a tab)" ])


view : Int -> Model -> Html Msg
view currentTab model =
    case currentTab of
        0 ->
            div
                []
                [ issuesView model ]
        _ ->
            editingIssueView (currentTab - 1) model
