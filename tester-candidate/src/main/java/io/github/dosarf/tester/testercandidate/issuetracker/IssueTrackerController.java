package io.github.dosarf.tester.testercandidate.issuetracker;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.view.RedirectView;

@Controller
@RequestMapping("/issuetracker")
public class IssueTrackerController {

    @GetMapping("/spa")
    public RedirectView redirect(RedirectAttributes attributes) {
        return new RedirectView("spa/index.html");
    }

    @GetMapping("/spa/")
    public RedirectView redirect2(RedirectAttributes attributes) {
        return new RedirectView("index.html");
    }
}
