module Issues.Update exposing (..)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Model, EditedIssue, IssueId)

import Navigation

update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    OnFetchAllIssues (Ok allIssues) ->
      ( { model | issues = allIssues }, Cmd.none )

    -- TODO show error to user in this case!
    OnFetchAllIssues (Err httpError) ->
      ( model, Cmd.none )

    ShowIssue issueId ->
      ( { model | editedIssue = editedIssue model issueId }
      , Navigation.newUrl ("#issues/" ++ issueId)
      )

    ShowIssues ->
      ( model, Navigation.newUrl "#issues" )

editedIssue : Model -> IssueId -> EditedIssue
editedIssue model issueId =
  let maybeIssue =
    model.issues
      |> List.filter (\issue -> issue.id == issueId)
      |> List.head
  in
    case maybeIssue of
      Just issue ->
        EditedIssue issue.type_ issue.priority issue.summary issue.description

      Nothing ->
        EditedIssue "" "" "" ""
