package io.github.dosarf.tester.testercandidate.issuetracker;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.dosarf.tester.testercandidate.user.User;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

import java.util.stream.Stream;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class IssueTrackerControllerTest {

    @Autowired
    private MockMvc mvc;
    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @Order(0)
    public void create_user_just_to_warm_up() throws Exception {
        User user = new User("John", "Doe");
        String userJson = objectMapper.writeValueAsString(user);

        User createdUser = new User(1L, "John", "Doe");
        String createdUserJson = objectMapper.writeValueAsString(createdUser);

        mvc.perform(MockMvcRequestBuilders.post("/user/").accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON).content(userJson))
                .andExpect(MockMvcResultMatchers.status().isCreated());
    }

    @Test
    @Order(1)
    public void create_issue() throws Exception {
        User creator = new User(1L, "John", "Doe");

        Issue issue = new Issue(
                "test-summary",
                Issue.Type.ENHANCEMENT,
                Issue.Priority.MEDIUM,
                "test-description",
                creator);

        String issueJson = objectMapper.writeValueAsString(issue);

        mvc.perform(MockMvcRequestBuilders.post("/issue/").accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON).content(issueJson))
                .andExpect(MockMvcResultMatchers.status().isCreated())
                .andExpect(MockMvcResultMatchers.jsonPath("summary", Matchers.is("test-summary")))
                .andExpect(MockMvcResultMatchers.jsonPath("type", Matchers.is("ENHANCEMENT")))
                .andExpect(MockMvcResultMatchers.jsonPath("priority", Matchers.is("MEDIUM")))
                .andExpect(MockMvcResultMatchers.jsonPath("description", Matchers.is("test-description")))
                .andExpect(MockMvcResultMatchers.jsonPath("creator.firstName", Matchers.is("John")))
                .andExpect(MockMvcResultMatchers.jsonPath("creator.lastName", Matchers.is("Doe")))
                .andExpect(MockMvcResultMatchers.jsonPath("id", Matchers.notNullValue()));
    }

    @Test
    @Order(2)
    public void list_all() throws Exception {
        mvc.perform(MockMvcRequestBuilders.get("/issue/").accept(MediaType.APPLICATION_JSON))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.jsonPath("[0].summary", Matchers.is("test-summary")));
    }

    @Test
    @Order(3)
    public void list_all_created_by() throws Exception {
        // TODO there's got to be a seriously better way than this
        String[] responseJson = new String[1];

        mvc.perform(MockMvcRequestBuilders.get("/user/").accept(MediaType.APPLICATION_JSON))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andDo(result -> responseJson[0] = result.getResponse().getContentAsString());

        User[] users = objectMapper.readValue(responseJson[0], User[].class);

        Long userId = Stream
                .of(users)
                .filter(u -> "John".equals(u.getFirstName()))
                .map(User::getId)
                .findFirst()
                .orElseThrow(() -> new AssertionError("failure"));

        mvc.perform(MockMvcRequestBuilders.get("/user/" + userId + "/issue").accept(MediaType.APPLICATION_JSON))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.jsonPath("[0].summary", Matchers.is("test-summary")));
    }
}
