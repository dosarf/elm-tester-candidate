package io.github.dosarf.tester.testercandidate.exporter;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;
import org.commonmark.node.Node;
import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
public class IssueRendererTest {

    private static final String MARKDOWN = "sometext";
    private static final String RENDERED = "<p>sometext</p>";

    @Mock
    private Parser markdownParser;
    @Mock
    private HtmlRenderer markdownHtmlRenderer;

    @InjectMocks
    private IssueRenderer issueRenderer;

    private Issue issue = new Issue(42L, null, null, null, MARKDOWN, null);

    @Mock
    private Node descriptionDocument;

    @Test
    void delegates_rendering_to_markdownParser_and_markdownRenderer() {
        when(markdownParser.parse(MARKDOWN)).thenReturn(descriptionDocument);
        when(markdownHtmlRenderer.render(descriptionDocument)).thenReturn(RENDERED);

        RenderedIssue renderedIssue = issueRenderer.render(issue);

        assertThat(renderedIssue.getId()).isEqualTo(issue.getId());
        assertThat(renderedIssue.getRenderedDescription()).isEqualTo(RENDERED);
    }
}
