module IssueTracker exposing (Model, Msg, init, update, view)

import User exposing (User, usersDecoder)

import Css exposing (px, width)
import Html.Styled exposing (Html, div, label, text)
import Html.Styled.Attributes exposing (css)
import Mwc.Button
import Mwc.TextField
import Http
-- import Result exposing
import Issue exposing (Issue, issuesDecoder)


issuesUri : String
issuesUri =
    "../"

usersUri : String
usersUri =
    "../../user/"

type alias Model =
    { user : Maybe User
    }


type Msg
    = IssuesDownloaded (Result Http.Error (List Issue))
    | UsersDownloaded (Result Http.Error (List User))
    | Nop


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


downloadIssues : Cmd Msg
downloadIssues =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = issuesUri
        , body = Http.emptyBody
        , expect = Http.expectJson IssuesDownloaded issuesDecoder
        , timeout = Just <| 10.0 * 1000.0
        , tracker = Nothing
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { user = Nothing
      }
    , downloadUsers
    )


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
                        ( model
                        , Cmd.none
                        )

        UsersDownloaded result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "USERS HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( model
                        , Cmd.none
                        )

                Ok users ->
                    let
                        _ =
                            Debug.log "Users downloaded" users
                    in
                        ( { model | user = List.head users }
                        , Cmd.none
                        )


        Nop ->
            ( model
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    div
        []
        [ label [] [ text (model.user |> Maybe.map User.displayName |> Maybe.withDefault "no user defined" ) ]
        ]
