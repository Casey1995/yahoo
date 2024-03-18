#Eventbridge rule schedule
resource "aws_cloudwatch_event_rule" "every_10_minutes" {
  name                = "Every10MinutesRule"
  schedule_expression = "rate(10 minutes)"
  tags = merge(var.map_tags, {"Name" = "Every10MinutesRule"})
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_10_minutes" {
  rule      = aws_cloudwatch_event_rule.every_10_minutes.name
  target_id = "UploadToS3Every10Minutes"
  arn       = aws_lambda_function.uploader.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uploader.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_10_minutes.arn
}

#Lambda functions
data "archive_file" "uploader" {
  type        = "zip"
  source_dir = "../modules/scripts/uploader"
  output_path = "objectUp.zip"
}

resource "aws_lambda_function" "uploader" {
  function_name = "UploadToS3Every10Minutes"
  handler       = "objectUploader.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_upload_role.arn
  filename      = "objectUp.zip"
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.yahoo_bucket.id
      KMS_KEY_ID = aws_kms_key.yahoo.key_id
    }
  }
  tracing_config {
    mode = "Active"
  }
  tags = merge(var.map_tags, {"Name" = "UploadToS3Every10Minutes"})
}

#Latest Lambda functions
data "archive_file" "latest" {
  type        = "zip"
  source_dir = "../modules/scripts/fetcher"
  output_path = "latest.zip"
}

resource "aws_lambda_function" "latest" {
  function_name = "GetMostRecentS3Object"
  handler       = "latestFetcher.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_fetch_role.arn
  filename      = "latest.zip"
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.yahoo_bucket.id
      KMS_KEY_ID = aws_kms_key.yahoo.key_id
    }
  }
  tracing_config {
    mode = "Active"
  }
  tags = merge(var.map_tags, {"Name" = "GetMostRecentS3Object"})
}

#Auth Lambda functions
data "archive_file" "auth" {
  type        = "zip"
  source_dir = "../modules/scripts/auth1"
  output_path = "auth.zip"
}

resource "aws_lambda_function" "auth" {
  function_name = "lambdaAuthorizer"
  handler       = "auth.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_auth_role.arn
  filename      = "auth.zip"
  tracing_config {
    mode = "Active"
  }
  tags = merge(var.map_tags, {"Name" = "Authorizer lambda"})
}