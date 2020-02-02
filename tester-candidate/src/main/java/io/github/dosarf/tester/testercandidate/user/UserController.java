package io.github.dosarf.tester.testercandidate.user;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;
import io.github.dosarf.tester.testercandidate.issuetracker.IssueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.Objects;
import java.util.Optional;

// see https://www.baeldung.com/spring-boot-json
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;
    @Autowired
    private IssueService issueService;


    @GetMapping("/{id}")
    public ResponseEntity<User> user(@PathVariable Long id) {

        Optional<User> userMaybe = userService.findById(id);

        return userMaybe
                .map(user -> ResponseEntity
                        .status(HttpStatus.OK)
                        .body(user))
                .orElseGet(() -> ResponseEntity
                        .status(HttpStatus.NOT_FOUND)
                        .build());
    }

    @PostMapping("/")
    public ResponseEntity<User> create(@RequestBody User user) {
        User copy = new User(user.getFirstName(), user.getLastName());
        User persisted = userService.save(copy);

        if (Objects.isNull(persisted)) {
            return ResponseEntity.notFound().build();
        } else {
            URI uri = ServletUriComponentsBuilder.fromCurrentRequest()
                    .path("/{id}")
                    .buildAndExpand(persisted.getId())
                    .toUri();

            return ResponseEntity
                    .created(uri)
                    .body(persisted);
        }
    }

    @GetMapping(value = "/", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Iterable<User>> listAll() {
        Iterable<User> users = userService.findAll();

        return ResponseEntity
                .ok(users);
    }


    @GetMapping(value = "/{id}/issue", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Iterable<Issue>> listIssuesCreatedBy(@PathVariable Long id) {
        Optional<User> userMaybe = userService.findById(id);

        return userMaybe
                .map(creator -> issueService.findByCreator(creator))
                .map(issues -> (Iterable<Issue>)issues)
                .map(issues -> ResponseEntity
                        .status(HttpStatus.OK)
                        .body(issues))
                .orElseGet(() -> ResponseEntity
                        .status(HttpStatus.NOT_FOUND)
                        .build());
    }

}
