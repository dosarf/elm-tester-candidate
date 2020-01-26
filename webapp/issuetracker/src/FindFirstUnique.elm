module FindFirstUnique exposing (findFirstUnique)

import Dict exposing (Dict)


type alias ItemStats comparable =
    { firstPosition : Int
    , item : comparable
    , unique : Bool
    }


foldler : comparable -> Dict comparable (ItemStats comparable) -> Dict comparable (ItemStats comparable)
foldler item dict =
    case Dict.get item dict of
        Nothing ->
            let
                firstPosition =
                    Dict.size dict
            in
            Dict.insert item (ItemStats firstPosition item True) dict

        Just currentStats ->
            Dict.insert item { currentStats | unique = False } dict


findFirstUnique : List comparable -> Maybe comparable
findFirstUnique list =
    let
        dict =
            List.foldl foldler Dict.empty list
    in
    Dict.filter (\item itemStats -> itemStats.unique) dict
        |> Dict.values
        |> List.sortBy .firstPosition
        |> List.head
        |> Maybe.map .item
