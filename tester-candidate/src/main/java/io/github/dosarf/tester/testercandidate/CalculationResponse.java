package io.github.dosarf.tester.testercandidate;

public class CalculationResponse {
    public CalculationRequest request;
    public String result;

    public CalculationResponse() {}

    public CalculationResponse(
            CalculationRequest request,
            String result) {
        this.request = request;
        this.result = result;
    }

    public static <T> CalculationResponse success(
            CalculationRequest request,
            T result) {
        return new CalculationResponse(request, result.toString());
    }

    public static CalculationResponse failure(CalculationRequest request, String errorDetails) {
        return new CalculationResponse(
                request,
                String.format("ERROR: %s", errorDetails));
    }
}
