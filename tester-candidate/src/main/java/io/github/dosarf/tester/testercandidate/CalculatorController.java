package io.github.dosarf.tester.testercandidate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CalculatorController {

    @Autowired
    private Calculator calculator;

    @RequestMapping(
            value = "/calculator",
            method = RequestMethod.POST,
            consumes = MediaType.APPLICATION_JSON_VALUE,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<CalculationResponse> calculate(@RequestBody CalculationRequest request) {

        try {
            Number result = calculator.calculate(
                    request.operator,
                    request.operands);

            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(CalculationResponse.success(request, result));
        } catch (Calculator.Exc e) {
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(CalculationResponse.failure(request, e.getMessage()));
        } catch (RuntimeException e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(CalculationResponse.failure(request, e.getMessage()));
        }
    }

}
