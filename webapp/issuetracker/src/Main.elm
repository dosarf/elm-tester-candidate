module Main exposing (main)

import Browser
import Css exposing (Color, border3, borderColor, borderRadius, display, height, hex, hover, inlineBlock, padding, px, rgb, solid, vw, width)
import Html.Styled exposing (Html, div, header, h1, main_, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css, src)
import IssueTracker
import Mwc.Button
import Mwc.Tabs
import Mwc.TextField
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
            ( { model | currentTab = newTab }
            , Cmd.none
            )

        IssueTrackerMsg issueTrackerMsg ->
            let
                editingIndex = model.currentTab - 1
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
            IssueTracker.tabTextList model.issueTrackerModel
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
    case model.currentTab of
        _ ->
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
