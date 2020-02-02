package io.github.dosarf.tester.testercandidate.issuetracker;

import io.github.dosarf.tester.testercandidate.user.User;

import javax.persistence.*;
import java.util.Objects;

// see https://spring.io/guides/gs/accessing-data-jpa/
@Entity
public class Issue {

    public static enum Type {
        DEFECT,
        ENHANCEMENT
    }

    public static enum Priority {
        HIGH,
        MEDIUM,
        LOW
    }

    @Id
    @GeneratedValue(strategy= GenerationType.AUTO, generator = "ISSUE_SEQ")
    private Long id;

    private String summary;
    private Type type;
    private Priority priority;
    private String description;

    @ManyToOne
    @JoinColumn(name="creator_id")
    private User creator;

    protected Issue() {}

    public Issue(
            Long id,
            String summary,
            Type type,
            Priority priority,
            String description,
            User creator) {
        this.id = id;
        this.summary = summary;
        this.type = type;
        this.priority = priority;
        this.description = description;
        this.creator = creator;
    }

    public Issue(
            String summary,
            Type type,
            Priority priority,
            String description,
            User creator) {
        this(null, summary, type, priority, description, creator);
    }

    public Long getId() {
        return id;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public Type getType() { return type; }

    public void setType(Type type) {
        this.type = type;
    }

    public Priority getPriority() {
        return priority;
    }

    public void setPriority(Priority priority) {
        this.priority = priority;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public User getCreator() {
        return creator;
    }

    public void setCreator(User creator) {
        this.creator = creator;
    }

    @Override
    public String toString() {
        return "Issue{" +
                "id=" + id +
                ", summary='" + summary + '\'' +
                ", type=" + type +
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
