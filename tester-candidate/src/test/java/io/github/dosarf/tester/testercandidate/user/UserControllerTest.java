package io.github.dosarf.tester.testercandidate.user;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import org.springframework.test.web.servlet.ResultMatcher;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class UserControllerTest {

    @Autowired
    private MockMvc mvc;
    @Autowired
    private ObjectMapper objectMapper;


//    @Test
    @Order(0)
    public void no_users_before_creating_one() throws Exception {
        mvc.perform(MockMvcRequestBuilders.get("/user/").accept(MediaType.APPLICATION_JSON))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(MockMvcResultMatchers.content().json("[]"));
    }

    @Test
    @Order(1)
    public void create_user_succeeds() throws Exception {
        User user = new User("John", "Doe");
        String userJson = objectMapper.writeValueAsString(user);

        mvc.perform(MockMvcRequestBuilders.post("/user/").accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON).content(userJson))
                .andExpect(MockMvcResultMatchers.status().isCreated())
                .andExpect(MockMvcResultMatchers.jsonPath("firstName", Matchers.is("John")))
                .andExpect(MockMvcResultMatchers.jsonPath("lastName", Matchers.is("Doe")))
                .andExpect(MockMvcResultMatchers.jsonPath("id", Matchers.notNullValue()));
    }
}
