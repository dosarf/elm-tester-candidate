module Main exposing (main)

import Browser
import Css exposing (Color, border3, borderColor, borderRadius, display, height, hex, hover, inlineBlock, padding, px, rgb, solid, width)
import FindFirstUniqueTab
import Html.Styled exposing (Html, div, header, img, main_, map, text, toUnstyled)
import Html.Styled.Attributes exposing (css, src)
import IncrementDecrementTab
import IssueTracker
import Mwc.Button
import Mwc.Tabs
import Mwc.TextField


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
                ( issueTrackerModel, cmd ) =
                    IssueTracker.update issueTrackerMsg model.issueTrackerModel
            in
                ( { model | issueTrackerModel = issueTrackerModel }
                , Cmd.map IssueTrackerMsg cmd
                )


{-| A plain old record holding a couple of theme colors.
-}
theme : { secondary : Color, primary : Color }
theme =
    { primary = hex "55af6a"
    , secondary = rgb 250 240 230
    }


{-| A logo image, with inline styles that change on hover.
-}
logo : Html msg
logo =
    img
        [ src "assets/free-logo.png"
        , css
            [ display inlineBlock
            , height (px 53)
            , width (px 128)
            , padding (px 20)
            , border3 (px 5) solid (rgb 120 120 120)
            , hover
                [ borderColor theme.primary
                , borderRadius (px 10)
                ]
            ]
        ]
        []


view : Model -> Html Msg
view model =
    main_ []
        [ header
            []
            [ div
                []
                [ logo ]
            ]
        , div
            [ css [ width (px 400) ] ]
            [ Mwc.Tabs.view
                [ Mwc.Tabs.selected model.currentTab
                , Mwc.Tabs.onClick SelectTab
                , Mwc.Tabs.tabText
                    [ text <| IssueTracker.tabText model.issueTrackerModel
                    ]
                ]
            , tabContentView model
            ]
        ]


tabContentView : Model -> Html Msg
tabContentView model =
    case model.currentTab of
        _ ->
            map IssueTrackerMsg (IssueTracker.view model.issueTrackerModel)


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
