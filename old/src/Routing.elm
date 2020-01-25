module Routing exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)
-- import UrlParser exposing (Parser, top, (</>), s, string, map, oneOf, parseHash)

import Issues.Models exposing (IssueId)


type Route =
    IssuesRoute
  | IssueRoute IssueId
  | NotFoundRoute

matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map IssuesRoute top
    , map IssueRoute (s "issues" </> string)
    , map IssuesRoute (s "issues")
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route

    Nothing ->
      NotFoundRoute
