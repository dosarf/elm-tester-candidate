package io.github.dosarf.tester.testercandidate.calculator;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.github.dosarf.tester.testercandidate.calculator.CalculationRequest;
import io.github.dosarf.tester.testercandidate.calculator.CalculationResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;

import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class CalculatorControllerTests {

	@Autowired
	private MockMvc mvc;
	@Autowired
	private ObjectMapper objectMapper;

	@Test
	public void getResult() throws Exception {
		CalculationRequest request = new CalculationRequest(CalculationRequest.Operator.ADD, "2", "3");
		String requestStr = objectMapper.writeValueAsString(request);

		CalculationResponse response = CalculationResponse.success(request, 5);
		String responseStr = objectMapper.writeValueAsString(response);

		mvc.perform(MockMvcRequestBuilders.post("/calculator").accept(MediaType.APPLICATION_JSON).contentType(MediaType.APPLICATION_JSON).content(requestStr))
				.andExpect(MockMvcResultMatchers.status().isOk())
				.andExpect(MockMvcResultMatchers.content().json(responseStr));
	}
}
