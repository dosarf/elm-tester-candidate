module FindFirstUniqueTests exposing (testSuite)

import Dict exposing (Dict)
import Expect
import FindFirstUnique exposing (findFirstUnique)
import Test exposing (..)


testSuite =
    describe "findFirstUnique test cases"
        [ test "single item list yields that item as unique" <|
            \() ->
                Just "hello"
                    |> Expect.equal (findFirstUnique [ "hello" ])
        , test "empty list yields nothing" <|
            \() ->
                Nothing
                    |> Expect.equal (findFirstUnique [])
        , test "list with no unique item yields nothing unique" <|
            \() ->
                Nothing
                    |> Expect.equal (findFirstUnique [ "a", "b", "b", "a" ])
        , test "list with one unique item yields that unique" <|
            \() ->
                Just "b"
                    |> Expect.equal (findFirstUnique [ "a", "b", "a" ])
        , test "list with multiple unique items yields the first unique one" <|
            \() ->
                Just "b"
                    |> Expect.equal (findFirstUnique [ "a", "b", "a", "c" ])
        , test "same as last test but for integers" <|
            \() ->
                Just 42
                    |> Expect.equal (findFirstUnique [ 13, 42, 13, 29 ])
        ]
