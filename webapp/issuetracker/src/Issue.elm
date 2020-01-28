module Issue exposing (Issue, Priority(..), title, issueDecoder, issuesDecoder, issueEncoder, priorities, priorityFromString, priorityToString)

import User exposing (User, userEncoder, userDecoder)

import Json.Decode as Decode
import Json.Encode as Encode

type Priority
    = HIGH
    | MEDIUM
    | LOW


priorities : List Priority
priorities = [ HIGH, MEDIUM, LOW ]


type alias Issue =
  { id : Int
  , summary : String
  , priority : Priority
  , description : String
  , creator : User
  }


title : Issue -> String
title issue =
    (String.fromInt issue.id) ++ " " ++ issue.summary


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


issueDecoder : Decode.Decoder Issue
issueDecoder =
    Decode.map5 Issue
        (Decode.field "id" Decode.int)
        (Decode.field "summary" Decode.string)
        (Decode.field "priority" priorityDecoder)
        (Decode.field "description" Decode.string)
        (Decode.field "creator" userDecoder)


issueEncoder : Issue -> Encode.Value
issueEncoder issue =
    Encode.object
        [ ( "id", Encode.int issue.id )
        , ( "summary", Encode.string issue.summary )
        , ( "priority", Encode.string (priorityToString issue.priority))
        , ( "description", Encode.string issue.description )
        , ( "creator", userEncoder issue.creator )
        ]


issuesDecoder : Decode.Decoder (List Issue)
issuesDecoder =
    Decode.list issueDecoder
