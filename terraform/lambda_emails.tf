resource "aws_iam_role" "email_handler" {
  name               = "kuberoke-${var.environment}-email-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "email_handler" {
  name   = "kuberoke-${var.environment}-email-lambda-policy"
  policy = <<EOF
{
    "Statement": [
        {
            "Action": "logs:CreateLogGroup",
            "Effect": "Allow",
            "Resource": "arn:aws:logs:${local.region_name}:${local.account_id}:*"
        },
        {
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:${local.region_name}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.email_handler.function_name}:*"
        },
        {
            "Action": [
                "dynamodb:DescribeStream",
                "dynamodb:GetRecords",
                "dynamodb:GetShardIterator",
                "dynamodb:ListStreams"
            ],
            "Effect": "Allow",
            "Resource": [
              "${aws_dynamodb_table.kuberoke.arn}/stream/*"
            ]
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "email_handler" {
  role       = aws_iam_role.email_handler.name
  policy_arn = aws_iam_policy.email_handler.arn
}

data "archive_file" "email_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/dynamoStreamhandler"
  output_path = "${path.root}/../src/lambda/build/emails_lambda_function.zip"
}

resource "aws_lambda_function" "email_handler" {
  filename         = "${path.root}/../src/lambda/build/emails_lambda_function.zip"
  function_name    = "kuberoke-${var.environment}-emails"
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role             = aws_iam_role.email_handler.arn
  source_code_hash = data.archive_file.email_handler.output_base64sha256
  timeout          = 90

  environment {
    variables = {
      SENDGRID_API_KEY = var.sendgrid_api_key
    }
  }
}

resource "aws_lambda_event_source_mapping" "email_handler" {
  event_source_arn  = aws_dynamodb_table.kuberoke.stream_arn
  function_name     = aws_lambda_function.email_handler.arn
  starting_position = "LATEST"

  batch_size                         = 1
  maximum_batching_window_in_seconds = 60
}
