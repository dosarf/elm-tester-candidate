module View exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)

import Issues.ListView
import Issues.EditView
import Issues.Models exposing (IssueId)
import Routing exposing (Route(..))

import Html exposing (Html, div, text)

view : Model -> Html Msg
view model =
  div []
      [ page model ]

page : Model -> Html Msg
page model =
  case model.route of
    IssuesRoute ->
      Html.map IssuesMsg (Issues.ListView.view model.issuesModel)

    IssueRoute issueId ->
      issueEditPage model issueId

    NotFoundRoute ->
      notFoundView

issueEditPage : Model -> IssueId -> Html Msg
issueEditPage model issueId =
  let maybeIssue =
    model.issuesModel.editedIssue :: model.issuesModel.issues
      |> List.filter (\issue -> issue.id == issueId)
      |> List.head
  in
    case maybeIssue of
      Just issue ->
        Html.map IssuesMsg (Issues.EditView.view model.issuesModel)

      Nothing ->
        notFoundView

notFoundView : Html Msg
notFoundView =
  div []
      [ text "Issue not found" ]
