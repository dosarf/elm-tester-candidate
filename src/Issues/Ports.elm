port module Issues.Ports exposing (..)

import Issues.Messages exposing (Msg(OnIssueDiscardConfirmation))

-- PORTS
-- based on https://guide.elm-lang.org/interop/javascript.html

port confirmIssueDiscard : String -> Cmd msg

port issueDiscardConfirmation : ((Bool, String) -> msg) -> Sub msg

port alertBackendError : String -> Cmd msg

-- SUBSCRIPTIONS

subscriptions : Sub Msg
subscriptions =
  issueDiscardConfirmation OnIssueDiscardConfirmation
