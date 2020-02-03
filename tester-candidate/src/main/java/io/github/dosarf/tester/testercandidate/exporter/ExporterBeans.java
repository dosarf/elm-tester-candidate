package io.github.dosarf.tester.testercandidate.exporter;

import org.commonmark.parser.Parser;
import org.commonmark.renderer.html.HtmlRenderer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ExporterBeans {

    @Bean
    public Parser markdownParser() {
        return Parser.builder().build();
    }

    @Bean
    public HtmlRenderer markdownHtmlRenderer() {
        return HtmlRenderer.builder().build();
    }
}
