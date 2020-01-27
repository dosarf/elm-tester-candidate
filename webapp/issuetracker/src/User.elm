module User exposing (User, displayName, userDecoder, usersDecoder, userEncoder)

import Json.Decode as Decode
import Json.Encode as Encode


type alias User =
  { id : Int
  , firstName : String
  , lastName : String
  }


displayName : User -> String
displayName user =
    user.lastName ++ ", " ++ user.firstName


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map3 User
        (Decode.field "id" Decode.int)
        (Decode.field "firstName" Decode.string)
        (Decode.field "lastName" Decode.string)


userEncoder : User -> Encode.Value
userEncoder user =
    Encode.object
        [ ( "id", Encode.int user.id )
        , ( "firstName", Encode.string user.firstName )
        , ( "lastName", Encode.string user.lastName )
        ]


usersDecoder : Decode.Decoder (List User)
usersDecoder =
    Decode.list userDecoder
