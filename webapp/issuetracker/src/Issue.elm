module Issue exposing (
    Issue,
    Type(..), types, typeFromString, typeToString,
    Priority(..), priorities, priorityFromString, priorityToString,
    title, issueDecoder, issuesDecoder, issueEncoder)

import User exposing (User, userEncoder, userDecoder)

import Json.Decode as Decode
import Json.Encode as Encode


type Type
    = DEFECT
    | ENHANCEMENT


types : List Type
types = [ DEFECT, ENHANCEMENT ]


typeDecoder : Decode.Decoder Type
typeDecoder =
    Decode.string
        |> Decode.andThen (\str ->
            case str of
                "DEFECT" ->
                    Decode.succeed DEFECT
                "ENHANCEMENT" ->
                    Decode.succeed ENHANCEMENT
                whatEver ->
                    Decode.fail <| "Unknown priority: " ++ whatEver
        )


typeToString : Type -> String
typeToString type_ =
    case type_ of
        DEFECT ->
            "DEFECT"
        ENHANCEMENT ->
            "ENHANCEMENT"


type Priority
    = HIGH
    | MEDIUM
    | LOW


typeFromString : String -> Type
typeFromString string =
    case string of
        "DEFECT" ->
            DEFECT
        _ ->
            ENHANCEMENT


priorities : List Priority
priorities = [ HIGH, MEDIUM, LOW ]


priorityDecoder : Decode.Decoder Priority
priorityDecoder =
    Decode.string
        |> Decode.andThen (\str ->
            case str of
                "HIGH" ->
                    Decode.succeed HIGH
                "MEDIUM" ->
                    Decode.succeed MEDIUM
                "LOW" ->
                    Decode.succeed LOW
                whatEver ->
                    Decode.fail <| "Unknown priority: " ++ whatEver
        )


priorityToString : Priority -> String
priorityToString priority =
    case priority of
        HIGH ->
            "HIGH"
        MEDIUM ->
            "MEDIUM"
        LOW ->
            "LOW"


priorityFromString : String -> Priority
priorityFromString string =
    case string of
        "HIGH" ->
            HIGH
        "MEDIUM" ->
            MEDIUM
        _ ->
            LOW


type alias Issue =
  { id : Int
  , summary : String
  , type_ : Type
  , priority : Priority
  , description : String
  , creator : User
  }


title : Issue -> String
title issue =
    "#" ++ (String.fromInt issue.id) ++ " " ++ issue.summary


issueDecoder : Decode.Decoder Issue
issueDecoder =
    Decode.map6 Issue
        (Decode.field "id" Decode.int)
        (Decode.field "summary" Decode.string)
        (Decode.field "type" typeDecoder)
        (Decode.field "priority" priorityDecoder)
        (Decode.field "description" Decode.string)
        (Decode.field "creator" userDecoder)


issueEncoder : Issue -> Encode.Value
issueEncoder issue =
    Encode.object
        [ ( "id", Encode.int issue.id )
        , ( "summary", Encode.string issue.summary )
        , ( "type", Encode.string (typeToString issue.type_))
        , ( "priority", Encode.string (priorityToString issue.priority))
        , ( "description", Encode.string issue.description )
        , ( "creator", userEncoder issue.creator )
        ]


issuesDecoder : Decode.Decoder (List Issue)
issuesDecoder =
    Decode.list issueDecoder
