module Main exposing (main)

import Browser
import Css exposing (vw, width)
import Html.Styled exposing (Html, div, header, h1, main_, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css)
import IssueTracker
import Mwc.Tabs
import FontAwesome


type alias Model =
    { currentTab : Int
    , issueTrackerModel : IssueTracker.Model
    }


init : () -> ( Model, Cmd Msg)
init () =
    let
        ( issueTrackerModel, issueTrackerCmd ) =
            IssueTracker.init ()
    in
        ( { currentTab = 0
          , issueTrackerModel = issueTrackerModel
          }
        , Cmd.map IssueTrackerMsg issueTrackerCmd
        )


type Msg
    = SelectTab Int
    | IssueTrackerMsg IssueTracker.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab newTab ->
            let
                _ =
                    Debug.log "NEW TAB" newTab
                -- after closing an issue, it sort of gets selected
                isStrayTab =
                    IssueTracker.editingIssueCount model.issueTrackerModel < newTab
            in
                ( { model | currentTab = if isStrayTab then 0 else newTab }
                , Cmd.none
                )

        IssueTrackerMsg issueTrackerMsg ->
            let
                editingIndex =
                    model.currentTab - 1
                ( issueTrackerModel, cmd ) =
                    IssueTracker.update issueTrackerMsg editingIndex model.issueTrackerModel
            in
                ( { model | issueTrackerModel = issueTrackerModel }
                , Cmd.map IssueTrackerMsg cmd
                )


{-| A logo image, with inline styles that change on hover.
-}
logo : Html msg
logo =
    h1
        [ class "px3 py1" ]
        [ text "IssueTracker" ]


view : Model -> Html Msg
view model =
    let
        tabTexts =
            IssueTracker.tabList model.issueTrackerModel
                |> List.map (Html.Styled.map IssueTrackerMsg)
    in
        main_ []
            [ FontAwesome.useCss |> Html.Styled.fromUnstyled
            , header
                []
                [ div
                    []
                    [ logo ]
                ]
            , div
                [ css [ width (vw 100) ] ]
                [ Mwc.Tabs.view
                    [ Mwc.Tabs.selected model.currentTab
                    , Mwc.Tabs.onClick SelectTab
                    , Mwc.Tabs.tabText tabTexts
                    ]
                , tabContentView model
                ]
            ]


tabContentView : Model -> Html Msg
tabContentView model =
    Html.Styled.map IssueTrackerMsg (IssueTracker.view model.currentTab model.issueTrackerModel)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

main =
    Browser.element
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
