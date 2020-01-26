package io.github.dosarf.tester.testercandidate.calculator;

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
        } catch (Calculator.Exc |RuntimeException e) {
            // BUGGY ON PURPOSE: no distinction between bad request and internal error
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(CalculationResponse.failure(request, e.getMessage()));
        }
    }

}
