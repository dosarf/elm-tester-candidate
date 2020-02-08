module CalculationResponseTests exposing (testSuite)

import Expect
import CalculationRequest as CReq
import CalculationResponse as CRsp
import Test exposing (..)

import Json.Decode as Decode


calculationResponseJson : String
calculationResponseJson =
    """{"request":{"operator":"MULTIPLY","operands":["12","42"]},"result":"504"}"""


calculationResponse : CRsp.CalculationResponse
calculationResponse =
    CRsp.CalculationResponse
        (CReq.CalculationRequest
            CReq.MULTIPLY
            [ "12", "42" ]
        )
        "504"


testSuite =
    describe "CalculationResponse test cases"
        [ test "calculationResponseDecoder" <|
            \() ->
                let
                    decodedCalculationResponse = Decode.decodeString CRsp.calculationResponseDecoder calculationResponseJson
                in
                    Expect.equal decodedCalculationResponse (Ok calculationResponse)
        ]
