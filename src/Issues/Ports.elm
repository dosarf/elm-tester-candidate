port module Issues.Ports exposing (..)

import Issues.Messages exposing (Msg(OnIssueDeletionConfirmation))

-- PORTS
-- based on https://guide.elm-lang.org/interop/javascript.html

port confirmIssueDeletion : String -> Cmd msg

port issueDeletionConfirmation : ((Bool, String) -> msg) -> Sub msg

-- SUBSCRIPTIONS

subscriptions : Sub Msg
subscriptions =
  issueDeletionConfirmation OnIssueDeletionConfirmation
