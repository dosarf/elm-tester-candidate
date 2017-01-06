module Messages exposing (..)

import Issues.Messages

import Navigation exposing (Location)

type Msg =
    IssuesMsg Issues.Messages.Msg
  | OnLocationChange Location
