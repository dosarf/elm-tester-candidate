package io.github.dosarf.tester.testercandidate.calculator;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.script.ScriptEngine;
import javax.script.ScriptException;

@Component
public class BuggyCalculator implements Calculator {

    @Autowired
    private ScriptEngine scriptEngine;

    @Override
    public Number calculate(CalculationRequest.Operator operator, String[] operands) throws Exc {
        String expression = getExpression(operator, operands);
        try {
            return (Number)scriptEngine.eval(expression);
        } catch (ScriptException e) {
            throw new Calculator.Exc(e, e.getMessage());
        }
    }

    private String getExpression(CalculationRequest.Operator operator, String[] operands) throws Exc {
        switch (operator) {
            case ADD:
                return String.format("%s + %s", operands[0], operands[1]);
            case SUBTRACT:
                return String.format("%s - %s", operands[0], operands[1]);
            case MULTIPLY:
                return String.format("%s * %s", operands[0], operands[1]);
            case DIVIDE:
                return String.format("%s / %s", operands[0], operands[1]);
            case SQUARE:
                return String.format("Math.pow(%s, 2)", operands[0]);
            case SQUARE_ROOT:
                return String.format("Math.sqrt(%s)", operands[0]);
            case POWER:
                return String.format("Math.pow(%s, %s)", operands[0], operands[1]);
            default:
                throw new Calculator.Exc(null, "unknown operator");

        }
    }
}
