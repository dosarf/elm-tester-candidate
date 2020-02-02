module IssueTracker exposing (Model, Msg, init, tabList, update, view)

import Dict exposing (Dict)
import List.Extra as ListX

import Css exposing (backgroundColor, border3, cursor, hex, hover, pointer, px, solid)
import Html.Styled exposing (div, Html, span, text)
import Html.Styled.Attributes exposing (css, class)
import Html.Styled.Events exposing (onClick)
import Http
import FontAwesome

import User exposing (User)
import Issue exposing (Issue)
import EditingIssue

-- CONSTANTS

userIssuesUri : User -> String
userIssuesUri user =
    "../../user/" ++ String.fromInt user.id ++ "/issue"


usersUri : String
usersUri =
    "../../user/"


issueUpdateUri : Issue -> String
issueUpdateUri issue =
    "../" ++ String.fromInt issue.id


editIcon : Html Msg
editIcon =
    span
        [ class "ml1" ]
        [ FontAwesome.icon FontAwesome.edit |> Html.Styled.fromUnstyled ]


closeIcon : Html Msg
closeIcon =
    span
        [ class "ml1" ]
        [ FontAwesome.icon FontAwesome.windowClose |> Html.Styled.fromUnstyled ]

-- MODEL

type alias Model =
    { user : Maybe User
    , issues : Dict Int Issue
    , editingIssues : List EditingIssue.Model
    }


mainTab : Model -> Html Msg
mainTab model =
    model.user
        |> Maybe.map User.displayName
        |> Maybe.map (\displayName -> "Issues (" ++ displayName ++ ")")
        |> Maybe.withDefault "(no user)"
        |> (\txt -> span [ class "h3" ] [ text txt ])


issueEditorTab : Issue -> Html Msg
issueEditorTab issue =
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


tabList : Model -> List (Html Msg)
tabList model =
    let
        editorTabTexts =
            model.editingIssues
                |> List.map .issue
                |> List.map .id
                |> List.map (\issueId -> Dict.get issueId model.issues)
                |> List.map (\issueMaybe -> Maybe.map issueEditorTab issueMaybe |> Maybe.withDefault (text "(unknown)") )
    in
        mainTab model :: editorTabTexts



type Msg
    = IssuesDownloaded (Result Http.Error (List Issue))
    | IssueUpdated Int (Result Http.Error Issue)
    | UsersDownloaded (Result Http.Error (List User))
    | OpenIssueTab Int
    | CloseIssueTab Int
    | EditingIssueMsg EditingIssue.Msg


downloadUsersCmd : Cmd Msg
downloadUsersCmd =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = usersUri
        , body = Http.emptyBody
        , expect = Http.expectJson UsersDownloaded User.usersDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }


downloadIssuesOfCmd : User -> Cmd Msg
downloadIssuesOfCmd user =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = userIssuesUri user
        , body = Http.emptyBody
        , expect = Http.expectJson IssuesDownloaded Issue.issuesDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }

updateIssueCmd : Issue -> Cmd Msg
updateIssueCmd issue =
    Http.request
        { method = "PUT"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = issueUpdateUri issue
        , body = Http.jsonBody <| Issue.issueEncoder issue
        , expect = Http.expectJson (IssueUpdated issue.id) Issue.issueDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { user = Nothing
      , issues = Dict.empty
      , editingIssues = []
      }
    , downloadUsersCmd
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
                        ( { model
                          | issues = newIssues
                          }
                        , Cmd.none
                        )

        IssueUpdated issueId result ->
            case result of
                -- revert model.editingIssues, model.issues remains as is
                Err httpError ->
                    let
                        _ = Debug.log "ISSUE SAVE HTTP ERROR" <| httpErrorToString httpError
                        editingIssues =
                            Dict.get issueId model.issues
                                |> Maybe.map (\issue -> updateIssue issue model.editingIssues)
                                |> Maybe.withDefault model.editingIssues
                    in
                        ( { model | editingIssues = editingIssues }
                        , Cmd.none
                        )

                -- update model.issues as well as model.editingIssues
                Ok issue ->
                    let
                        _ =
                            Debug.log "Issue saved" issue
                    in
                        ( { model
                          | issues = Dict.insert issue.id issue model.issues
                          , editingIssues = updateIssue issue model.editingIssues
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
                        ( offlineModel
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
                          }
                        , firstUserMaybe
                            |> Maybe.map downloadIssuesOfCmd
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
                                |> Maybe.map (\issue -> [ EditingIssue.startEditingIssue issue ])
                                |> Maybe.withDefault []
                              )
            in
                ( { model
                  | editingIssues = editingIssues
                  }
                , Cmd.none
                )

        CloseIssueTab issueId ->
            ( { model
              | editingIssues = List.filter (\editingIssue -> editingIssue.issue.id /= issueId) model.editingIssues
              }
            , Cmd.none
            )

        EditingIssueMsg editingIssueMsg ->
            let
                editingIssueMaybe =
                    ListX.getAt editingIndex model.editingIssues

            in
                case editingIssueMaybe of
                    Nothing ->
                        ( model, Cmd.none )

                    Just editingIssue ->
                        let
                            editingIssues =
                                ListX.updateIf
                                    (\eI -> editingIssue.issue.id == eI.issue.id)
                                    (\eI -> EditingIssue.update editingIssueMsg eI)
                                    model.editingIssues

                            saveCmd : Cmd Msg
                            saveCmd =
                                if EditingIssue.shouldSaveIssue editingIssueMsg
                                    then
                                        updateIssueCmd editingIssue.issue
                                    else
                                        Cmd.none

                        in
                            ( { model | editingIssues = editingIssues }
                            , saveCmd
                            )


updateIssue : Issue -> List EditingIssue.Model -> List EditingIssue.Model
updateIssue issue editingIssues =
    ListX.updateIf
        (\editingIssue -> issue.id == editingIssue.issue.id)
        (EditingIssue.updateIssue issue)
        editingIssues


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
        |> ListX.getAt issueIndex
        |> Maybe.map EditingIssue.view
        |> Maybe.map (Html.Styled.map EditingIssueMsg)
        |> Maybe.withDefault (div [] [ text "(Select a tab, please!)" ])


view : Int -> Model -> Html Msg
view currentTab model =
    case currentTab of
        0 ->
            div
                []
                [ issuesView model ]
        _ ->
            editingIssueView (currentTab - 1) model
