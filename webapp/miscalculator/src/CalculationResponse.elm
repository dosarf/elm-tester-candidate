module CalculationResponse exposing (CalculationResponse, calculationResponseDecoder)

import Json.Decode as Decode
import CalculationRequest as CR


type alias CalculationResponse =
    { request : CR.CalculationRequest
    , result : String
    }


calculationResponseDecoder : Decode.Decoder CalculationResponse
calculationResponseDecoder =
    Decode.map2 CalculationResponse
        (Decode.field "request" CR.calculationRequestDecoder)
        (Decode.field "result" Decode.string)
