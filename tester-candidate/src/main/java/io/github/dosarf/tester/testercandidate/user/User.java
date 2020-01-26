package io.github.dosarf.tester.testercandidate.user;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;

import javax.persistence.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

// see https://spring.io/guides/gs/accessing-data-jpa/
@Entity
public class User {
    @Id
    @GeneratedValue(strategy= GenerationType.AUTO, generator = "USER_SEQ")
    private Long id;

    private String firstName;
    private String lastName;
    @OneToMany
    private List<Issue> createdIssues;

    protected User() {}

    public User(String firstName, String lastName) {
        this(null, firstName, lastName);
    }

    public User(Long id, String firstName, String lastName) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        createdIssues = new ArrayList<>();
    }

    public Long getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public List<Issue> getCreatedIssues() {
        return createdIssues;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}
