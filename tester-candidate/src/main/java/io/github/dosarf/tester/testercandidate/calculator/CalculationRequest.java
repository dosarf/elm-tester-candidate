package io.github.dosarf.tester.testercandidate.calculator;

public class CalculationRequest {
    public static enum Operator {
        ADD,
        SUBTRACT,
        MULTIPLY,
        DIVIDE,
        POWER,
        SQUARE,
        SQUARE_ROOT
    }

    public Operator operator;
    public String[] operands;

    public CalculationRequest() {}

    public CalculationRequest(
            Operator operator,
            String ... operands) {
        this.operator = operator;
        this.operands = operands;
    }
}
