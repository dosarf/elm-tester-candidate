module IssueTracker exposing (Model, Msg, init, tabText, update, view)

import User exposing (User, usersDecoder)

import Css exposing (backgroundColor, border3, borderColor, hex, hover, px, solid, width)
import Html.Styled exposing (Html, div, label, li, span, text, ul)
import Html.Styled.Attributes exposing (css)
import Mwc.Button
import Mwc.TextField
import Http
import Issue exposing (Issue, issuesDecoder)


userIssuesUri : User -> String
userIssuesUri user =
    "../../user/" ++ (String.fromInt user.id) ++ "/issue"

usersUri : String
usersUri =
    "../../user/"

type alias Model =
    { user : Maybe User
    , issues : List Issue
    }

tabText : Model -> String
tabText model =
    model.user
        |> Maybe.map User.displayName
        |> Maybe.map (\displayName -> "Issues (" ++ displayName ++ ")")
        |> Maybe.withDefault "(no user)"

type Msg
    = IssuesDownloaded (Result Http.Error (List Issue))
    | UsersDownloaded (Result Http.Error (List User))


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
      , issues = []
      }
    , downloadUsers
    )


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
                    in
                        ( { model | issues = issues }
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


editIcon : String
editIcon =
    "\u{270E}"


closeIcon : String
closeIcon =
    "\u{274C}"


issueSummaryView : Issue -> Html Msg
issueSummaryView issue =
    span
        []
        [ text <| (String.fromInt issue.id) ++ ": " ++ issue.summary
        , span
            [ css
                [ border3 (px 2) solid (hex "ffffff")
                , backgroundColor (hex "ffffff")
                , hover
                    [ borderColor (hex "55af6a")
                    , backgroundColor (hex "55af6a")
                    ]
                ]
            ]
            [ text editIcon]
        ]



issuesListItems: Model -> List(Html Msg)
issuesListItems model =
    model.issues
        |> List.map (\issue -> li [] [ issueSummaryView issue ])


issuesView : Model -> Html Msg
issuesView model =
    div
        []
        [ label [] [ text "Issues: " ]
        ,  ul
              []
              (issuesListItems model)
        ]


view : Model -> Html Msg
view model =
    div
        []
        [ issuesView model ]
