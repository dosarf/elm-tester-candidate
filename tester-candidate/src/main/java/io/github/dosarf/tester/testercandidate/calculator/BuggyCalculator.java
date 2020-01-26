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
        // BUGGY ON PURPOSE
        // - operand count is not sanitized (binary operators need exactly one operand, etc)
        // - operand type (can be converted to number?) is not checked either at this point
        switch (operator) {
            case ADD:
                return String.format("%s + %s", operands[0], operands[1]);
            case SUBTRACT:
                // BUGGY ON PURPOSE: instead of a - b, calculates b - a
                return String.format("%s - %s", operands[1], operands[0]);
            case MULTIPLY:
                return String.format("%s * %s", operands[0], operands[1]);
            case DIVIDE:
                // BUGGY ON PURPOSE: instead of a/b, calculates b/a
                return String.format("%s / %s", operands[1], operands[0]);
            case SQUARE:
                return String.format("Math.pow(%s, 2)", operands[0]);
            case SQUARE_ROOT:
                // BUGGY ON PURPOSE: (among other things) turns negative operand into positive ones
                // before taking square root
                return String.format("Math.sqrt(%s)", operands[0].replace("-", ""));
            case POWER:
                // BUGGY ON PURPOSE: (among other things) turns negative exponent into positive one
                return String.format("Math.pow(%s, %s)", operands[0], operands[1].replace("-", ""));
            default:
                throw new Calculator.Exc(null, "unknown operator");

        }
    }
}
