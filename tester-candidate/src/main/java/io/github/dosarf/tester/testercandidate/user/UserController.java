package io.github.dosarf.tester.testercandidate.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.net.URI;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

// see https://www.baeldung.com/spring-boot-json
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

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

    @GetMapping("/")
    public ResponseEntity<Iterable<User>>  listAll() {
        Iterable<User> users = userService.findAll();

        return ResponseEntity
                .ok(users);
    }
}
