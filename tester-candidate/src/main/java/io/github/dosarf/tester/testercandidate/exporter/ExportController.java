package io.github.dosarf.tester.testercandidate.exporter;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;
import io.github.dosarf.tester.testercandidate.issuetracker.IssueService;
import io.github.dosarf.tester.testercandidate.user.User;
import io.github.dosarf.tester.testercandidate.user.UserService;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

// see https://spring.io/guides/gs/serving-web-content/
@Controller
public class ExportController {

    @Autowired
    private UserService userService;
    @Autowired
    private IssueService issueService;
    @Autowired
    private IssueRenderer issueRenderer;

    @GetMapping(value = "exportissues/user/{id}", produces = MediaType.TEXT_HTML_VALUE)
    public String exportIssuesCreatedBy(@PathVariable Long id, Model model) {
        Optional<User> userMaybe = userService.findById(id);

        if (userMaybe.isPresent()) {
            User creator = userMaybe.get();
            List<RenderedIssue> issues = issueService
                    .findByCreator(creator)
                    .stream()
                    .map(issueRenderer::render)
                    .collect(Collectors.toList());

            model.addAttribute("creator", creator);
            model.addAttribute("issues", issues);

            return "exportIssuesCreatedBy";
        }

        model.addAttribute("unknownUserId", id);
        return "exportIssuesUserNotFound";
    }

}
