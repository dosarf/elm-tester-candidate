package io.github.dosarf.tester.testercandidate.exporter;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class IssueRenderer {
    @Autowired
    private Parser markdownParser;
    @Autowired
    private HtmlRenderer markdownHtmlRenderer;

    public RenderedIssue render(Issue issue) {
        return new RenderedIssue(
                issue,
                renderDescription(issue.getDescription()));
    }

    private String renderDescription(String description) {
        Node descriptionDocument = markdownParser.parse(description);
        return markdownHtmlRenderer.render(descriptionDocument);
    }
}
