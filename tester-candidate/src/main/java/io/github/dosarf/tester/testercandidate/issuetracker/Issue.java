package io.github.dosarf.tester.testercandidate.issuetracker;

import io.github.dosarf.tester.testercandidate.user.User;

import javax.persistence.*;
import java.util.Objects;

// see https://spring.io/guides/gs/accessing-data-jpa/
@Entity
public class Issue {

    public static enum Priority {
        HIGH,
        MEDIUM,
        LOW
    }

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO, generator = "ISSUE_SEQ")
    private Long id;

    private String summary;
    private Priority priority;
    private String description;

    @ManyToOne
    @JoinColumn(name="creator_id")
    private User creator;

    protected Issue() {}

    public Issue(
            Long id,
            String summary,
            Priority priority,
            String description,
            User creator) {
        this.id = id;
        this.summary = summary;
        this.priority = priority;
        this.description = description;
        this.creator = creator;
    }

    public Issue(
            String summary,
            Priority priority,
            String description,
            User creator) {
        this(null, summary, priority, description, creator);
    }

    public Long getId() {
        return id;
    }

    public String getSummary() {
        return summary;
    }

    public Priority getPriority() {
        return priority;
    }

    public String getDescription() {
        return description;
    }

    public User getCreator() {
        return creator;
    }

    @Override
    public String toString() {
        return "Issue{" +
                "id=" + id +
                ", summary='" + summary + '\'' +
                ", priority=" + priority +
                ", description='" + description + '\'' +
                ", creator='" + creator + '\'' +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Issue issue = (Issue) o;
        return Objects.equals(id, issue.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}