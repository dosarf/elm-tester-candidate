module Issue exposing (
    Issue,
    Type(..),
    firstNewIssueId, nextNewIssueId, isNewIssue,
    newIssue, types, typeFromString, typeToString,
    Priority(..), priorities, priorityFromString, priorityToString,
    changeSummary, changeType, changePriority, changeDescription,
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
                    Decode.fail <| "Unknown type: " ++ whatEver
        )


typeToString : Type -> String
typeToString type_ =
    case type_ of
        DEFECT ->
            "DEFECT"
        ENHANCEMENT ->
            "ENHANCEMENT"


typeFromString : String -> Type
typeFromString string =
    case string of
        "DEFECT" ->
            DEFECT
        _ ->
            ENHANCEMENT


type Priority
    = HIGH
    | MEDIUM
    | LOW


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


-- TODO consider turning this Int into an opaque type, like NewIssueIdGenerator or something
{- IDs of a newly created issue (i.e. not yet persisted) matters only from the point of
   view of identifying correctly which new issue is being edited, in case there are multiple
   such NEW issues are being created.
-}
firstNewIssueId : Int
firstNewIssueId =
    -1

nextNewIssueId : Int -> Int
nextNewIssueId newIssueId =
    newIssueId - 1


isNewIssue : Issue -> Bool
isNewIssue issue =
    issue.id < 0


defaultDescription : String
defaultDescription = """
## Your description here

Using _awesome_ **Markdown** notation, similar to what
[GitHub](https://help.github.com/en/github/writing-on-github/basic-writing-and-formatting-syntax) supports.

- With one, or
- more bullets.

You can even `include` code snippets here, thusly:
```
int ever = 1;

for (;ever;) {
  twirl(thumb);
}
```
"""


newIssue : Int -> User -> Issue
newIssue id user =
    { id = id
    , summary = "Your summary here"
    , type_ = ENHANCEMENT
    , priority = LOW
    , description = defaultDescription
    , creator = user
    }

changeSummary : String -> Issue -> Issue
changeSummary summary issue =
    { issue | summary = summary }


changeType : Type -> Issue -> Issue
changeType type_ issue =
    { issue | type_ = type_ }


changePriority : Priority -> Issue -> Issue
changePriority priority issue =
    { issue | priority = priority }


changeDescription : String -> Issue -> Issue
changeDescription description issue =
    { issue | description = description }


title : Issue -> String
title issue =
    "#" ++ String.fromInt issue.id ++ " " ++ issue.summary


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
