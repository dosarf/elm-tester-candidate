package io.github.dosarf.tester.testercandidate.calculator;

public interface Calculator {

    class Exc extends Exception {

        public Exc(Throwable t, String format, Object ... args) {
            super(String.format(format, args), t);
        }
    }

    Number calculate(CalculationRequest.Operator operator, String[] operands) throws Exc;
}
