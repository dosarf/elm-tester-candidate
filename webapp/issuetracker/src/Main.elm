module Main exposing (main)

import Browser
import Css exposing (Color, border3, borderColor, borderRadius, display, height, hex, hover, inlineBlock, padding, px, rgb, solid, width)
import FindFirstUniqueTab
import Html.Styled exposing (Html, div, header, img, main_, map, text, toUnstyled)
import Html.Styled.Attributes exposing (css, src)
import IncrementDecrementTab
import Mwc.Button
import Mwc.Tabs
import Mwc.TextField


type alias Model =
    { currentTab : Int
    , incDecModel : IncrementDecrementTab.Model
    , findFirstUniqueModel : FindFirstUniqueTab.Model
    }


initialModel : Model
initialModel =
    { currentTab = 0
    , incDecModel = IncrementDecrementTab.initialModel
    , findFirstUniqueModel = FindFirstUniqueTab.initialModel
    }


type Msg
    = SelectTab Int
    | IncDecMsg IncrementDecrementTab.Msg
    | FindFirstUniqueMsg FindFirstUniqueTab.Msg


update : Msg -> Model -> Model
update msg model =
    case msg of
        SelectTab newTab ->
            { model | currentTab = newTab }

        IncDecMsg incDecMsg ->
            { model | incDecModel = IncrementDecrementTab.update incDecMsg model.incDecModel }

        FindFirstUniqueMsg findFirstUniqueMsg ->
            { model | findFirstUniqueModel = FindFirstUniqueTab.update findFirstUniqueMsg model.findFirstUniqueModel }


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
                    [ text "Inc/Dec"
                    , text "Find 1st unique"
                    ]
                ]
            , tabContentView model
            ]
        ]


tabContentView : Model -> Html Msg
tabContentView model =
    case model.currentTab of
        0 ->
            map IncDecMsg (IncrementDecrementTab.view model.incDecModel)

        _ ->
            map FindFirstUniqueMsg (FindFirstUniqueTab.view model.findFirstUniqueModel)


main =
    Browser.sandbox
        { init = initialModel
        , view = view >> toUnstyled
        , update = update
        }
