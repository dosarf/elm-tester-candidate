module UserTests exposing (testSuite)

import Dict exposing (Dict)
import Expect
import User exposing (User, userDecoder, userEncoder)
import Test exposing (..)

import Json.Decode as Decode
import Json.Encode as Encode

userJson : String
userJson =
    """{"id":42,"firstName":"John","lastName":"Doe"}"""

user : User
user =
    User 42 "John" "Doe"

testSuite =
    describe "User test cases"
        [ test "userDecoder works correctly" <|
            \() ->
                let
                    decodedUser = Decode.decodeString userDecoder userJson
                in
                    Expect.equal decodedUser (Ok user)
        , test "userEncoder works correctly" <|
            \() ->
                let
                    encodedUser = Encode.encode 0 (userEncoder user)
                in
                    Expect.equal encodedUser userJson
        ]
