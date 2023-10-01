resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.kuberoke.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.kuberoke.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prod.id
  rest_api_id   = aws_api_gateway_rest_api.kuberoke.id
  stage_name    = "kuberoke-${var.environment}-prod"
}

resource "aws_lambda_permission" "registrations" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_registration_handler.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_rest_api" "kuberoke" {
  body = jsonencode({
    "openapi" : "3.0.1",
    "info" : {
      "title" : "kuberoke-${var.environment}",
      "version" : "2023-09-26T19:48:16Z"
    },
    "paths" : {
      "/reservation" : {
        # "get" : {
        #   "responses" : {
        #     "200" : {
        #       "description" : "200 response",
        #       "headers" : {
        #         "Access-Control-Allow-Origin" : {
        #           "schema" : {
        #             "type" : "string"
        #           }
        #         }
        #       },
        #       "content" : {
        #         "application/json" : {
        #           "schema" : {
        #             "$ref" : "#/components/schemas/Empty"
        #           }
        #         }
        #       }
        #     }
        #   },
        #   "security" : [ {
        #     "api_key" : [ ]
        #   } ],
        #   "x-amazon-apigateway-integration" : {
        #     "httpMethod" : "POST",
        #     "uri" : "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:805392057246:function:APIGW-invite/invocations",
        #     "responses" : {
        #       "default" : {
        #         "statusCode" : "200",
        #         "responseParameters" : {
        #           "method.response.header.Access-Control-Allow-Origin" : "'*'"
        #         }
        #       }
        #     },
        #     "passthroughBehavior" : "when_no_match",
        #     "contentHandling" : "CONVERT_TO_TEXT",
        #     "type" : "aws_proxy"
        #   }
        # },
        "post" : {
          "responses" : {
            "200" : {
              "description" : "200 response",
              "headers" : {
                "Access-Control-Allow-Origin" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "httpMethod" : "POST",
            "uri" : "${aws_lambda_function.api_registration_handler.invoke_arn}",
            "responses" : {
              "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                  "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
              }
            },
            "passthroughBehavior" : "when_no_match",
            "contentHandling" : "CONVERT_TO_TEXT",
            "type" : "aws_proxy"
          }
        },
        "options" : {
          "responses" : {
            "200" : {
              "description" : "200 response",
              "headers" : {
                "Access-Control-Allow-Origin" : {
                  "schema" : {
                    "type" : "string"
                  }
                },
                "Access-Control-Allow-Methods" : {
                  "schema" : {
                    "type" : "string"
                  }
                },
                "Access-Control-Allow-Headers" : {
                  "schema" : {
                    "type" : "string"
                  }
                }
              },
              "content" : {
                "application/json" : {
                  "schema" : {
                    "$ref" : "#/components/schemas/Empty"
                  }
                }
              }
            }
          },
          "x-amazon-apigateway-integration" : {
            "responses" : {
              "default" : {
                "statusCode" : "200",
                "responseParameters" : {
                  "method.response.header.Access-Control-Allow-Methods" : "'GET,OPTIONS,POST'",
                  "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
                  "method.response.header.Access-Control-Allow-Origin" : "'*'"
                }
              }
            },
            "requestTemplates" : {
              "application/json" : "{\"statusCode\": 200}"
            },
            "passthroughBehavior" : "when_no_match",
            "type" : "mock"
          }
        }
      },
      # "/invite" : {
      #   "post" : {
      #     "responses" : {
      #       "200" : {
      #         "description" : "200 response",
      #         "content" : {
      #           "application/json" : {
      #             "schema" : {
      #               "$ref" : "#/components/schemas/Empty"
      #             }
      #           }
      #         }
      #       }
      #     },
      #     "security" : [ {
      #       "api_key" : [ ]
      #     } ],
      #     "x-amazon-apigateway-integration" : {
      #       "httpMethod" : "POST",
      #       "uri" : "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:805392057246:function:APIGW-invite/invocations",
      #       "responses" : {
      #         "default" : {
      #           "statusCode" : "200"
      #         }
      #       },
      #       "passthroughBehavior" : "when_no_match",
      #       "contentHandling" : "CONVERT_TO_TEXT",
      #       "type" : "aws_proxy"
      #     }
      #   },
      #   "options" : {
      #     "responses" : {
      #       "200" : {
      #         "description" : "200 response",
      #         "headers" : {
      #           "Access-Control-Allow-Origin" : {
      #             "schema" : {
      #               "type" : "string"
      #             }
      #           },
      #           "Access-Control-Allow-Methods" : {
      #             "schema" : {
      #               "type" : "string"
      #             }
      #           },
      #           "Access-Control-Allow-Headers" : {
      #             "schema" : {
      #               "type" : "string"
      #             }
      #           }
      #         },
      #         "content" : {
      #           "application/json" : {
      #             "schema" : {
      #               "$ref" : "#/components/schemas/Empty"
      #             }
      #           }
      #         }
      #       }
      #     },
      #     "x-amazon-apigateway-integration" : {
      #       "responses" : {
      #         "default" : {
      #           "statusCode" : "200",
      #           "responseParameters" : {
      #             "method.response.header.Access-Control-Allow-Methods" : "'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
      #             "method.response.header.Access-Control-Allow-Headers" : "'Content-Type,Authorization,X-Amz-Date,X-Api-Key,X-Amz-Security-Token'",
      #             "method.response.header.Access-Control-Allow-Origin" : "'*'"
      #           }
      #         }
      #       },
      #       "requestTemplates" : {
      #         "application/json" : "{\"statusCode\": 200}"
      #       },
      #       "passthroughBehavior" : "when_no_match",
      #       "type" : "mock"
      #     }
      #   }
      # }
    },
    "components" : {
      "schemas" : {
        "Empty" : {
          "title" : "Empty Schema",
          "type" : "object"
        }
      },
      "securitySchemes" : {
        "api_key" : {
          "type" : "apiKey",
          "name" : "x-api-key",
          "in" : "header"
        }
      }
    }
  })

  name = "kuberoke-${var.environment}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}