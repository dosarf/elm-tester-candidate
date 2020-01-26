package io.github.dosarf.tester.testercandidate.issuetracker;

import io.github.dosarf.tester.testercandidate.user.User;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface IssueService extends CrudRepository<Issue, Long> {
    List<Issue> findByCreator(User creator);
}
