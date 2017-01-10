module Issues.Update exposing (..)

import Issues.Messages exposing (Msg(..))
import Issues.Models exposing (Model, Issue, IssueId, IssueMetadata, emptyIssue, createIssue)
import Issues.Commands exposing (saveIssue, discardIssue)
import Issues.Ports exposing (confirmIssueDiscard, alertBackendError)

import Navigation


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    OnFetchAllIssues (Ok allIssues) ->
      ( { model | issues = allIssues }, Cmd.none )

    OnFetchAllIssues (Err httpError) ->
      ( model, alertBackendError "Could not load issues from backend" )

    OnSaveIssue (Ok issue) ->
      ( updateModelIssues model issue, Cmd.none )

    OnSaveIssue (Err httpError) ->
      ( model, alertBackendError "Could not save issue to backend" )

    OnFetchIssueConfig (Ok issueConfig) ->
      ( { model | issueConfig = issueConfig }, Cmd.none )

    OnFetchIssueConfig (Err httpError) ->
      ( model, alertBackendError "Could not load basic data from backend" )

    OnDeleteIssue (Ok responseString) ->
      ( removeDesignatedIssueFromModel model, Cmd.none )

    OnDeleteIssue (Err httpError) ->
      ( { model | issueIdToRemove = Nothing }, alertBackendError "Could not delete issue from backend" )

    OnIssueDiscardConfirmation (True, issueId) ->
      ( { model | issueIdToRemove = Just issueId }, discardIssue model issueId)

    OnIssueDiscardConfirmation (False, issueId) ->
      ( model, Cmd.none)

    CreateIssue ->
      let
        newIssue =
          createIssue model
      in
        ( { model | editedIssue = newIssue, hasChanged = True }
        , Navigation.newUrl ("#issues/" ++ newIssue.id)
        )

    ConfirmDiscardIssue issueId ->
      ( model, confirmIssueDiscard issueId )

    ShowIssue issueId ->
      ( { model
          | editedIssue = editedIssue model issueId
          , hasChanged = False
          , editingDescription = False
        }
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

    EditDescription ->
      ( { model | editingDescription = True }, Cmd.none )

    ViewDescription ->
      ( { model | editingDescription = False }, Cmd.none )



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


removeDesignatedIssueFromModel : Model -> Model
removeDesignatedIssueFromModel model =
  case model.issueIdToRemove of
    Just issueIdToRemove ->
      { model
        | issues = List.filter (\issue -> issue.id /= issueIdToRemove) model.issues
        , issueIdToRemove = Nothing
      }
    Nothing ->
      model
