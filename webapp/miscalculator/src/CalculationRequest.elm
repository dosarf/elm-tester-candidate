module CalculationRequest exposing (Operator(..), CalculationRequest, calculationRequestDecoder, calculationRequestEncoder)


import Json.Decode as Decode
import Json.Encode as Encode

type Operator
    = ADD
    | SUBTRACT
    | MULTIPLY
    | DIVIDE
    | POWER
    | SQUARE
    | SQUARE_ROOT


type alias CalculationRequest =
    { operator : Operator
    , operands : List String
    }


operatorDecoder : Decode.Decoder Operator
operatorDecoder =
    Decode.string
        |> Decode.andThen (\str ->
            case str of
                "ADD" ->
                    Decode.succeed ADD
                "SUBTRACT" ->
                    Decode.succeed SUBTRACT
                "MULTIPLY" ->
                    Decode.succeed MULTIPLY
                "DIVIDE" ->
                    Decode.succeed DIVIDE
                "POWER" ->
                    Decode.succeed POWER
                "SQUARE" ->
                    Decode.succeed SQUARE
                "SQUARE_ROOT" ->
                    Decode.succeed SQUARE_ROOT
                whatEver ->
                    Decode.fail <| "Unknown operator: " ++ whatEver
        )


operatorToString : Operator -> String
operatorToString operator =
    case operator of
        ADD ->
            "ADD"
        SUBTRACT ->
            "SUBTRACT"
        MULTIPLY ->
            "MULTIPLY"
        DIVIDE ->
            "DIVIDE"
        POWER ->
            "POWER"
        SQUARE ->
            "SQUARE"
        SQUARE_ROOT ->
            "SQUARE_ROOT"


calculationRequestDecoder : Decode.Decoder CalculationRequest
calculationRequestDecoder =
    Decode.map2 CalculationRequest
        (Decode.field "operator" operatorDecoder)
        (Decode.field "operands" (Decode.list Decode.string))


calculationRequestEncoder : CalculationRequest -> Encode.Value
calculationRequestEncoder calculationRequest =
    Encode.object
        [ ("operator", Encode.string (operatorToString calculationRequest.operator))
        , ("operands", Encode.list Encode.string calculationRequest.operands)
        ]
