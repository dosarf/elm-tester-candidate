package io.github.dosarf.tester.testercandidate.calculator;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

@Configuration
public class CalculatorBeans {
    @Bean
    public ScriptEngine scriptEngine() {
        ScriptEngineManager mgr = new ScriptEngineManager();
        ScriptEngine engine = mgr.getEngineByName("JavaScript");
        return engine;
    }
}
