module CalculationRequestTests exposing (testSuite)

import Expect
import CalculationRequest as CR
import Test exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode


calculationRequestJson : String
calculationRequestJson =
    """{"operator":"MULTIPLY","operands":["12","42"]}"""


calculationRequest : CR.CalculationRequest
calculationRequest =
    CR.CalculationRequest
        CR.MULTIPLY
        [ "12", "42" ]


testSuite =
    describe "CalculationRequest test cases"
        [ test "calculationRequestEncoder" <|
            \() ->
                let
                    encodedCalculationRequest = Encode.encode 0 (CR.calculationRequestEncoder calculationRequest)
                in
                    Expect.equal encodedCalculationRequest calculationRequestJson
        , test "calculationRequestDecoder" <|
            \() ->
                let
                    decodedCalculationRequest = Decode.decodeString CR.calculationRequestDecoder calculationRequestJson
                in
                    Expect.equal decodedCalculationRequest (Ok calculationRequest)
        ]
