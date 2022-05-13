package com.camunda.example.worker;

import lombok.extern.slf4j.Slf4j;
import org.camunda.bpm.client.spring.annotation.ExternalTaskSubscription;
import org.camunda.bpm.client.task.ExternalTask;
import org.camunda.bpm.client.task.ExternalTaskHandler;
import org.camunda.bpm.client.task.ExternalTaskService;
import org.camunda.bpm.client.variable.ClientValues;
import org.camunda.bpm.client.variable.value.JsonValue;
import org.camunda.bpm.engine.variable.VariableMap;
import org.camunda.bpm.engine.variable.Variables;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Slf4j
@Component
@ExternalTaskSubscription("rest")
public class RESTWorker implements ExternalTaskHandler {

  @Override
  public void execute(ExternalTask task, ExternalTaskService externalTaskService) {

    try {
      var data = task.getAllVariables();
      log.info("Received process data: {}", data.toString());
      String url = task.getVariable("url");

      //call REST service and wai for response
      WebClient.ResponseSpec responseSpec = WebClient.create().get().uri(url).retrieve();
      String responseBody = responseSpec.bodyToMono(String.class).block();

      log.info("url {} returned:\n {} ", url, responseBody);
      JsonValue jsonValue = ClientValues.jsonValue(responseBody);

      VariableMap variables = Variables.createVariables();
      variables.put("response", jsonValue);
      externalTaskService.complete(task, variables);

      log.info("{} task with instance id {} for process instance {} completed.", task.getActivityId(),
          task.getActivityInstanceId(), task.getProcessInstanceId());
    } catch (Exception e) {
      log.warn("Completion of task {} failed: {}", task.getId(), e.getMessage());
      int retries = 0;
      if (task.getRetries() != null && task.getRetries() > 0) retries = task.getRetries() - 1;
      log.info("Setting retries of task {} to {}", task.getId(), retries);
      externalTaskService.handleFailure(task.getId(), e.getMessage(), e.getMessage(), retries, 2000);
    }
  }
}
