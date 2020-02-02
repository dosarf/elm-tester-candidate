package io.github.dosarf.tester.testercandidate.exporter;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;
import io.github.dosarf.tester.testercandidate.issuetracker.IssueService;
import io.github.dosarf.tester.testercandidate.user.User;
import io.github.dosarf.tester.testercandidate.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Optional;

// see https://spring.io/guides/gs/serving-web-content/
@Controller
public class ExportController {

    @Autowired
    private UserService userService;
    @Autowired
    private IssueService issueService;

    @GetMapping(value = "exportissues/user/{id}", produces = MediaType.TEXT_HTML_VALUE)
    public String exportIssuesCreatedBy(@PathVariable Long id, Model model) {
        Optional<User> userMaybe = userService.findById(id);

        if (userMaybe.isPresent()) {
            User creator = userMaybe.get();
            List<Issue> issues = issueService.findByCreator(creator);

            model.addAttribute("creator", creator);
            model.addAttribute("issues", issues);
            return "exportIssuesCreatedBy";
        }

        model.addAttribute("unknownUserId", id);
        return "exportIssuesUserNotFound";
    }
}
