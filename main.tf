provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

data "archive_file" "cwl_zip" {
  type        = "zip"
  output_path = "./cwl/cwl.zip"

  source_file = "./cwl/code/build/bootstrap"
}

resource "aws_lambda_function" "cwl" {
  function_name = "cw-log-retention-go"
  handler       = "bootstrap"
  role          = aws_iam_role.cwl_go_lambda_role.arn

  runtime          = "provided.al2"
  timeout          = 120
  memory_size      = 128
  architectures   = ["arm64"]
  filename         = data.archive_file.cwl_zip.output_path
  source_code_hash = data.archive_file.cwl_zip.output_base64sha256

  environment {
    variables = {
      REGION    = var.region
    }
  }
  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "every_12_hours" {
  name                = "cw-log-retention-go-12-hours"
  schedule_expression = "rate(12 hours)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "cwl_go_lambda_target" {
  arn  = aws_lambda_function.cwl.arn
  rule = aws_cloudwatch_event_rule.every_12_hours.name
}

resource "aws_lambda_permission" "cwl_go_lamabda_perms" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cwl.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_12_hours.arn
}
