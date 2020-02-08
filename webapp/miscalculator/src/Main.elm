module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, table, text, tr, td)
import Html.Attributes exposing (class, colspan, readonly, rowspan, value)
import Html.Events exposing (onClick)
import Http

import CalculationRequest as CReq
import CalculationResponse as CRsp

-- CONSTANTS

calculatorUri : String
calculatorUri =
    "../../calculator/"


-- HTTP

calculateCmd : CReq.CalculationRequest -> Cmd Msg
calculateCmd calculationRequest =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Accept" "application/json" ]
        , url = calculatorUri
        , body = Http.jsonBody <| CReq.calculationRequestEncoder calculationRequest
        , expect = Http.expectJson CalculationResponseReceived CRsp.calculationResponseDecoder
        , timeout = Just <| 2.0 * 1000.0
        , tracker = Nothing
        }


-- MODEL, MSG, UPDATE, VIEW

type alias Model =
    { digits : List Int -- "534" will be represented as [4, 3, 5]
    , firstOperand : Maybe String
    , operator : Maybe CReq.Operator
    , erroneous : Bool
    }


init : () -> (Model, Cmd Msg)
init () =
    ( { digits = []
      , firstOperand = Nothing
      , operator = Nothing
      , erroneous = False
      }
    , Cmd.none
    )


type Msg
    = DigitPressed Int
    | OperatorPressed CReq.Operator
    | CalculatePressed
    | DecimalDotPressed
    | ClearPressed
    | CalculationResponseReceived (Result Http.Error CRsp.CalculationResponse)


maxDigitCount : Int
maxDigitCount =
    10


addDigitCuttingToMaxLength : Int -> List Int -> List Int
addDigitCuttingToMaxLength digit digits =
    List.take maxDigitCount <| digit :: digits


decimalDot : Int
decimalDot =
    -1

-- e.g. [5, 4, -1, 2] -> "2.45"
digitsToString : List Int -> String
digitsToString digits =
    let
        numberCharacterFromDigit : Int -> String
        numberCharacterFromDigit digit =
            if decimalDot == digit
                then
                    "."
                else
                    String.fromInt digit
    in
        List.foldr (\digit operandSofar -> operandSofar ++ numberCharacterFromDigit digit) "" digits


unicodeOfZero : Int
unicodeOfZero =
    Char.toCode '0'


-- e.g. "245" -> [5, 4, 2]
digitsFromString : String -> List Int
digitsFromString string =
    string
        |> String.toList
        |> List.reverse
        |> List.filter Char.isDigit -- deliberate bug: discard decimal dot
        |> List.map Char.toCode
        |> List.map (\unicode -> unicode - unicodeOfZero)


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
        DigitPressed digit ->
            -- deliberate bug: starting operand with '0' are OK
            -- deliberate bug: pressing a digit does not clear an error status
            ( { model | digits = addDigitCuttingToMaxLength digit model.digits }
            , Cmd.none
            )

        OperatorPressed operator ->
            -- deliberate bug: most calculators would interpret the second '+'
            -- in the sequence of '1 + 2 + 3' as a cue to calculate 1 + 2, and then
            -- continue with adding something that will be entered afterwards
            ( { model
              | firstOperand = Just <| digitsToString model.digits
              , digits = []
              , operator = Just operator
              }
            , Cmd.none
            )

        CalculatePressed ->
            let
                request =
                    -- deliberate bug: no verification if operator is defined or
                    -- the required arity of operands already exists
                    CReq.CalculationRequest
                        ( model.operator
                          |> Maybe.withDefault CReq.SQUARE
                        )
                        ( model.firstOperand
                          |> Maybe.map (\firstOperand -> firstOperand :: [ digitsToString model.digits ])
                          |> Maybe.withDefault [ digitsToString model.digits ]
                        )
                cmd =
                    calculateCmd request
            in
                ( model
                , cmd
                )

        DecimalDotPressed ->
            -- deliberate bug: there can be as many decimal dots as you like
            ( { model | digits = addDigitCuttingToMaxLength decimalDot model.digits }
            , Cmd.none
            )

        ClearPressed ->
            init ()


        CalculationResponseReceived result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "CALCULATION HTTP ERROR" <| httpErrorToString httpError
                    in
                        ( { model | erroneous = True }
                        , Cmd.none
                        )

                Ok calculationResponse ->
                    let
                        _ =
                            Debug.log "CALCULATION HTTP SUCCESS" <| calculationResponse
                    in
                        ( { model
                          | digits = digitsFromString calculationResponse.result
                          , firstOperand = Nothing
                          , erroneous = False
                          , operator = Nothing
                          }
                        , Cmd.none
                        )


-- https://en.wikipedia.org/wiki/Mathematical_operators_and_symbols_in_Unicode
multiplicationSign : String
multiplicationSign =
    "\u{2217}"


divisionSign : String
divisionSign =
    "\u{00f7}"


squareRootSign : String
squareRootSign =
    "\u{221a}"


dotSign : String
dotSign =
    "\u{2219}"


powerSign : String
powerSign =
    "\u{2227}"


view : Model -> Html Msg
view model =
    let
        displayedValue =
            if model.erroneous
                then
                    "Err"
                else
                    digitsToString model.digits
    in
        div
            []
            [ table
                []
                [ tr
                    []
                    [ td
                        [ colspan 4 ]
                        [ input
                            [ readonly True
                            , value displayedValue
                            , class "displayBox"
                            ]
                            []
                        ]
                    ]
                , tr
                    []
                    [ td [] [ button [ onClick <| OperatorPressed CReq.SQUARE_ROOT ] [ text squareRootSign ] ]
                    , td [] [ button [ onClick <| OperatorPressed CReq.POWER ] [ text powerSign ] ]
                    , td [] [ button [ onClick <| DecimalDotPressed ] [ text dotSign ] ]
                    , td [] [ button [ onClick <| ClearPressed ] [ text "C" ] ]
                    ]
                , tr
                    []
                    [ td [] [ button [ onClick <| DigitPressed 7 ] [ text "7" ] ]
                    , td [] [ button [ onClick <| DigitPressed 8 ] [ text "8" ] ]
                    , td [] [ button [ onClick <| DigitPressed 9 ] [ text "9" ] ]
                    , td [] [ button [ onClick <| OperatorPressed CReq.MULTIPLY ] [ text multiplicationSign ] ]
                    ]
                , tr
                    []
                    [ td [] [ button [ onClick <| DigitPressed 4 ] [ text "4" ] ]
                    , td [] [ button [ onClick <| DigitPressed 5 ] [ text "5" ] ]
                    , td [] [ button [ onClick <| DigitPressed 6 ] [ text "6" ] ]
                    , td [] [ button [ onClick <| OperatorPressed CReq.DIVIDE ] [ text divisionSign ] ]
                    ]
                , tr
                    []
                    [ td [] [ button [ onClick <| DigitPressed 1 ] [ text "1" ] ]
                    , td [] [ button [ onClick <| DigitPressed 2 ] [ text "2" ] ]
                    , td [] [ button [ onClick <| DigitPressed 3 ] [ text "3" ] ]
                    , td [ rowspan 2 ] [ button [ onClick <| CalculatePressed ] [ text "=" ] ]
                    ]
                , tr
                    []
                    [ td [] [ button [ onClick <| DigitPressed 0 ] [ text "0" ] ]
                    , td [] [ button [ onClick <| OperatorPressed CReq.ADD ] [ text "+" ] ]
                    , td [] [ button [ onClick <| OperatorPressed CReq.SUBTRACT ] [ text "-" ] ]
                    ]
                ]
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
