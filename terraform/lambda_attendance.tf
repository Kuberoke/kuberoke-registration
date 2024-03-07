resource "aws_iam_role" "api_attendance_handler" {
  name               = "kuberoke-${var.environment}-api-attendance-lambda-role"
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

resource "aws_iam_policy" "api_attendance_handler" {
  name   = "kuberoke-${var.environment}-api-attendance-lambda-policy"
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
            "Resource": "arn:aws:logs:${local.region_name}:${local.account_id}:log-group:/aws/lambda/${aws_lambda_function.api_attendance_handler.function_name}:*"
        },
        {
            "Action": [
                "dynamodb:UpdateItem",
                "dynamodb:Scan"
            ],
            "Effect": "Allow",
            "Resource": "${aws_dynamodb_table.kuberoke.arn}"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_attendance_handler" {
  role       = aws_iam_role.api_attendance_handler.name
  policy_arn = aws_iam_policy.api_attendance_handler.arn
}

data "archive_file" "api_attendance_handler" {
  type        = "zip"
  source_dir  = "${path.root}/../src/lambda/attendance"
  output_path = "${path.root}/../src/lambda/build/attendance_lambda_function.zip"
}

resource "aws_lambda_function" "api_attendance_handler" {
  filename         = "${path.root}/../src/lambda/build/attendance_lambda_function.zip"
  function_name    = "kuberoke-${var.environment}-api-attendance"
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.api_attendance_handler.arn
  source_code_hash = data.archive_file.api_attendance_handler.output_base64sha256

  environment {
    variables = {
      TABLENAME              = aws_dynamodb_table.kuberoke.name    
    }
  }
}