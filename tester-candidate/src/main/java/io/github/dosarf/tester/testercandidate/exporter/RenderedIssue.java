package io.github.dosarf.tester.testercandidate.exporter;

import io.github.dosarf.tester.testercandidate.issuetracker.Issue;

public class RenderedIssue {

    private final Issue issue;
    private final String renderedDescription;

    public RenderedIssue(
            Issue issue,
            String renderedDescription) {
        this.issue = issue;
        this.renderedDescription = renderedDescription;
    }

    public Long getId() {
        return issue.getId();
    }

    public String getSummary() {
        return issue.getSummary();
    }

    public Issue.Type getType() { return issue.getType(); }

    public Issue.Priority getPriority() {
        return issue.getPriority();
    }

    public String getDescription() {
        return issue.getDescription();
    }

    public String getRenderedDescription() { return renderedDescription; }

    @Override
    public String toString() {
        return "RenderedIssue{" +
                "issue=" + issue +
                ", renderedDescription='" + renderedDescription + '\'' +
                '}';
    }
}
