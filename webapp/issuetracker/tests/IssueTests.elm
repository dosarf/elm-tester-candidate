module IssueTests exposing (testSuite)

import Dict exposing (Dict)
import Expect
import User exposing (User)
import Issue exposing (Issue, Priority, issueDecoder, issuesDecoder, issueEncoder)
import Test exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode

userJson : String
userJson =
    """{"id":42,"firstName":"John","lastName":"Doe"}"""

user : User
user =
    User 42 "John" "Doe"

issueJson =
    """{"id":24,"summary":"Implement all","priority":"LOW","description":"'nuff said!","creator":""" ++ userJson ++ "}"

issue : Issue
issue =
    Issue 24 "Implement all" Issue.LOW "'nuff said!" user

testSuite =
    describe "Issue test cases"
        [ test "issueDecoder works correctly" <|
            \() ->
                let
                    decodedIssue = Decode.decodeString issueDecoder issueJson
                in
                    Expect.equal decodedIssue (Ok issue)
        , test "issueEncoder works correctly" <|
            \() ->
                let
                    encodedIssue = Encode.encode 0 (issueEncoder issue)
                in
                    Expect.equal encodedIssue issueJson
        , test "issuesDecoder works correctly" <|
            \() ->
                let
                    issuesJson =
                        "[" ++ issueJson ++ "]"
                    decodedIssues =
                        Decode.decodeString issuesDecoder issuesJson
                in
                    Expect.equal decodedIssues <| Ok [ issue ]
        ]
