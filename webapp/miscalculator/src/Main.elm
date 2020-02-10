module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, table, text, tr, td)
import Html.Attributes exposing (class, colspan, id, readonly, rowspan, style, value)
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


unicodeOfDot : Int
unicodeOfDot =
    Char.toCode '.'

-- e.g. "245" -> [5, 4, 2]
digitsFromString : String -> List Int
digitsFromString string =
    string
        |> String.toList
        |> List.reverse
        |> List.map Char.toCode
        |> List.map (\unicode ->
            if unicode == unicodeOfDot
                then
                    decimalDot
                else
                    unicode - unicodeOfZero
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

        calcButton : Msg -> String -> Html Msg
        calcButton msg txt =
            button
                [ class "calculator"
                , onClick msg
                ]
                [ text txt ]

        calcButton2 : Msg -> String -> Html Msg
        calcButton2 msg txt =
            button
                [ id "calculate"
                , class "calculator"
                , onClick msg
                ]
                [ text txt ]
    in
        div
            [ class "block mx-auto mt2"
            , style "width" "50%"
            ]
            [ table
                [ class "calculator" ]
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
                    [ td [] [ calcButton (OperatorPressed CReq.SQUARE_ROOT) squareRootSign ]
                    , td [] [ calcButton (OperatorPressed CReq.POWER) powerSign ]
                    , td [] [ calcButton (DecimalDotPressed) dotSign ]
                    , td [] [ calcButton ClearPressed "C" ]
                    ]
                , tr
                    []
                    [ td [] [ calcButton (DigitPressed 7) "7" ]
                    , td [] [ calcButton (DigitPressed 8) "8" ]
                    , td [] [ calcButton (DigitPressed 9) "9" ]
                    , td [] [ calcButton (OperatorPressed CReq.MULTIPLY) multiplicationSign ]
                    ]
                , tr
                    []
                    [ td [] [ calcButton (DigitPressed 4) "4" ]
                    , td [] [ calcButton (DigitPressed 5) "5" ]
                    , td [] [ calcButton (DigitPressed 6) "6" ]
                    , td [] [ calcButton (OperatorPressed CReq.DIVIDE) divisionSign ]
                    ]
                , tr
                    []
                    [ td [] [ calcButton (DigitPressed 1) "1" ]
                    , td [] [ calcButton (DigitPressed 2) "2" ]
                    , td [] [ calcButton (DigitPressed 3) "3" ]
                    , td [ rowspan 2 ] [ calcButton2 CalculatePressed "=" ]
                    ]
                , tr
                    []
                    [ td [] [ calcButton (DigitPressed 0) "0" ]
                    , td [] [ calcButton (OperatorPressed CReq.ADD) "+" ]
                    , td [] [ calcButton (OperatorPressed CReq.SUBTRACT) "-" ]
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
