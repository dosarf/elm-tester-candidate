module FindFirstUniqueTab exposing (Model, Msg, initialModel, update, view)

import Css exposing (px, width)
import FindFirstUnique exposing (findFirstUnique)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import List.Extra exposing (interweave, removeAt)
import Mwc.Chips
import Mwc.TextField


type alias Model =
    { input : String
    , words : List String
    , firstUnique : Maybe String
    }


initialModel : Model
initialModel =
    { input = "world"
    , words = [ "hello" ]
    , firstUnique = Just "hello"
    }


type Msg
    = Typing String
    | RemoveWord Int


update : Msg -> Model -> Model
update msg model =
    case msg of
        Typing input ->
            let
                splitInput =
                    String.split " " input

                addNewWord =
                    List.length splitInput > 1
            in
            if addNewWord then
                let
                    newWords =
                        List.append model.words (List.take 1 splitInput)
                in
                { model
                    | input = ""
                    , words = newWords
                    , firstUnique = findFirstUnique newWords
                }

            else
                { model | input = input }

        RemoveWord index ->
            let
                newWords =
                    removeAt index model.words
            in
            { model
                | words = newWords
                , firstUnique = findFirstUnique newWords
            }


view : Model -> Html Msg
view model =
    div
        [ css [ width (px 300) ] ]
        [ div
            []
            [ Mwc.TextField.view
                [ Mwc.TextField.value <| model.input
                , Mwc.TextField.onInput Typing
                ]
            ]
        , div
            []
            [ text <| firstUniqueLabel model.firstUnique ]
        , div
            []
            (words2Chips model.words)
        ]


firstUniqueLabel : Maybe String -> String
firstUniqueLabel firstUnique =
    case firstUnique of
        Nothing ->
            "No unique item found."

        Just unique ->
            "First unique item: " ++ unique


word2Chip : Int -> String -> Html Msg
word2Chip index string =
    Mwc.Chips.view
        [ Mwc.Chips.label string
        , Mwc.Chips.removeClick <| RemoveWord index
        ]


words2Chips : List String -> List (Html Msg)
words2Chips words =
    let
        chips =
            List.indexedMap word2Chip words

        separators =
            List.repeat (List.length words - 1) <| text " "
    in
    interweave chips separators
