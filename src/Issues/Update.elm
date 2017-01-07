module Issues.Update exposing (..)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Model, Issue, IssueId, IssueMetadata, emptyIssue, createIssue)
import Issues.Commands exposing (saveIssue)

import Navigation


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    OnFetchAllIssues (Ok allIssues) ->
      ( { model | issues = allIssues }, Cmd.none )

    -- TODO show error to user in this case!
    OnFetchAllIssues (Err httpError) ->
      ( model, Cmd.none )

    OnSaveIssue (Ok issue) ->
      ( updateModelIssues model issue, Cmd.none )

    -- TODO show error to user in this case!
    OnSaveIssue (Err httpError) ->
      ( model, Cmd.none )

    OnFetchIssueMetadata (Ok issueMetadata) ->
      ( { model | issueMetadata = issueMetadata }, Cmd.none )

    -- TODO show error to user in this case!
    OnFetchIssueMetadata (Err httpError) ->
      ( model, Cmd.none )

    CreateIssue ->
      let
        newIssue =
          createIssue model
      in
        ( { model | editedIssue = newIssue, hasChanged = True }
        , Navigation.newUrl ("#issues/" ++ newIssue.id)
        )

    ShowIssue issueId ->
      ( { model | editedIssue = editedIssue model issueId, hasChanged = False }
      , Navigation.newUrl ("#issues/" ++ issueId)
      )

    ShowIssues ->
      ( model, Navigation.newUrl "#issues" )

    ApplyIssueChanges ->
      let
        maybeExistingIssue =
          model.issues
            |> List.filter (\issue -> issue.id == model.editedIssue.id)
            |> List.head
      in
        case maybeExistingIssue of
          Just existingIssue ->
            ( model, saveIssue False model.editedIssue )

          Nothing ->
            ( model, saveIssue True model.editedIssue )

    {- TODO there is a lot of verbose, repetitive boilerplate in
       (Summary, Type, Priority, Description)Changed message handling
       Is this a sign that Issue editing should be a sub-sub-component?
    -}
    SummaryChanged newSummary ->
      let
        issue = model.editedIssue
        updatedIssue = { issue | summary = newSummary }
      in
        ( { model | editedIssue = updatedIssue, hasChanged = True }, Cmd.none )

    TypeChanged newType ->
      let
        issue = model.editedIssue
        updatedIssue = { issue | type_ = newType }
      in
        ( { model | editedIssue = updatedIssue, hasChanged = True }, Cmd.none )

    PriorityChanged newPriority ->
      let
        issue = model.editedIssue
        updatedIssue = { issue | priority = newPriority }
      in
        ( { model | editedIssue = updatedIssue, hasChanged = True }, Cmd.none )

    DescriptionChanged newDescription ->
      let
        issue = model.editedIssue
        updatedIssue = { issue | description = newDescription }
      in
        ( { model | editedIssue = updatedIssue, hasChanged = True }, Cmd.none )


editedIssue : Model -> IssueId -> Issue
editedIssue model issueId =
  let maybeIssue =
    model.issues
      |> List.filter (\issue -> issue.id == issueId)
      |> List.head
  in
    case maybeIssue of
      Just issue ->
        issue

      Nothing ->
        emptyIssue


updateModelIssues : Model -> Issue -> Model
updateModelIssues model issue =
  let
    updatedExistingIssues =
      List.map (\oldIssue -> if oldIssue.id == issue.id then issue else oldIssue) model.issues
    newlyCreatedIssue =
      model.issues
        |> List.filter (\oldIssue -> oldIssue.id == issue.id)
        |> List.isEmpty
    updatedIssues =
      if newlyCreatedIssue then
        List.append updatedExistingIssues [ issue ]
      else
        updatedExistingIssues
  in
    { model | issues = updatedIssues, hasChanged = False }