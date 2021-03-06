package io.github.dosarf.tester.testercandidate.issuetracker;

import io.github.dosarf.tester.testercandidate.user.User;
import io.github.dosarf.tester.testercandidate.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;
import org.springframework.web.servlet.view.RedirectView;

import java.net.URI;
import java.util.Objects;
import java.util.Optional;

@Controller
@RequestMapping("/issue")
public class IssueTrackerController {

    @Autowired
    private IssueService issueService;
    @Autowired
    private UserService userService;


    @GetMapping("/spa")
    public RedirectView redirect(RedirectAttributes attributes) {
        return new RedirectView("spa/index.html");
    }

    @GetMapping("/spa/")
    public RedirectView redirect2(RedirectAttributes attributes) {
        return new RedirectView("index.html");
    }


    @GetMapping("/{id}")
    public ResponseEntity<Issue> issue(@PathVariable Long id) {

        Optional<Issue> issueMaybe = issueService.findById(id);

        return issueMaybe
                .map(issue -> ResponseEntity.ok(issue))
                .orElseGet(() -> ResponseEntity
                        .status(HttpStatus.NOT_FOUND)
                        .build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Issue> update(
            @PathVariable Long id,
            @RequestBody Issue issue) {
        User creatorFromRequest = issue.getCreator();
        if (Objects.isNull(creatorFromRequest)) {
            return ResponseEntity
                    .badRequest()
                    .body(issue);
        }

        Optional<User> creatorMaybe = userService.findById(creatorFromRequest.getId());
        if (!creatorMaybe.isPresent()) {
            return ResponseEntity
                    .notFound()
                    .build();
        }

        User creator = creatorMaybe.get();

        Optional<Issue> issueMaybe = issueService.findById(id);

        if (!issueMaybe.isPresent()) {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .build();
        }

        Issue loadedIssue = issueMaybe.get();
        loadedIssue.setSummary(issue.getSummary());
        loadedIssue.setType(issue.getType());
        loadedIssue.setPriority(issue.getPriority());
        loadedIssue.setDescription(issue.getDescription());
        loadedIssue.setCreator(creator);

        Issue persistedIssue = issueService.save(loadedIssue);

        if (Objects.isNull(persistedIssue)) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .build();
        } else {
            return ResponseEntity
                    .ok(persistedIssue);
        }
    }

    @PostMapping("/")
    public ResponseEntity<Issue> create(@RequestBody Issue issue) {
        User creatorFromRequest = issue.getCreator();
        if (Objects.isNull(creatorFromRequest)) {
            return ResponseEntity
                    .badRequest()
                    .body(issue);
        }

        Optional<User> creatorMaybe = userService.findById(creatorFromRequest.getId());
        if (!creatorMaybe.isPresent()) {
            return ResponseEntity
                    .notFound()
                    .build();
        }

        User creator = creatorMaybe.get();

        Issue copy = new Issue(
                issue.getSummary(),
                issue.getType(),
                issue.getPriority(),
                issue.getDescription(),
                creator);

        Issue persistedIssue = issueService.save(copy);

        if (Objects.isNull(persistedIssue)) {
            return ResponseEntity.notFound().build();
        } else {
            URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                    .path("/{id}")
                    .buildAndExpand(persistedIssue.getId())
                    .toUri();

            return ResponseEntity
                    .created(uri)
                    .body(persistedIssue);
        }
    }

    @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Iterable<Issue>>  listAll() {
        Iterable<Issue> issues = issueService.findAll();

        return ResponseEntity
                .ok(issues);
    }

}
