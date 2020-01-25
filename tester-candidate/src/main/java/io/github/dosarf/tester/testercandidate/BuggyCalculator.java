package io.github.dosarf.tester.testercandidate;

import org.springframework.stereotype.Component;

@Component
public class BuggyCalculator implements Calculator {

    @Override
    public Number calculate(CalculationRequest.Operator operator, String[] operands) throws Exc {
        return 0L;
    }
}
