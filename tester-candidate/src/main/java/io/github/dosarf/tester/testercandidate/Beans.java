package io.github.dosarf.tester.testercandidate;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

@Configuration
public class Beans {
    @Bean
    public ScriptEngine scriptEngine() {
        ScriptEngineManager mgr = new ScriptEngineManager();
        ScriptEngine engine = mgr.getEngineByName("JavaScript");
        return engine;
    }
}
