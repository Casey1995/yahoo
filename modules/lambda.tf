#Eventbridge rule schedule
resource "aws_cloudwatch_event_rule" "every_10_minutes" {
  name                = "every-10-minutes"
  schedule_expression = "rate(10 minutes)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda_every_10_minutes" {
  rule      = aws_cloudwatch_event_rule.every_10_minutes.name
  target_id = "UploadToS3Every10Minutes"
  arn       = aws_lambda_function.uploader.arn
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
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = "objectUp.zip"
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.yahoo_bucket.id
      KMS_KEY_ID = aws_kms_key.yahoo.key_id
    }
  }
}

data "archive_file" "latest" {
  type        = "zip"
  source_file = "latestFetcher.py"
  output_path = "latest.zip"
}

resource "aws_lambda_function" "latest" {
  function_name = "GetMostRecentS3Object"
  handler       = "latestFetcher.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = "latest.zip"
  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.yahoo_bucket.id
      KMS_KEY_ID = aws_kms_key.yahoo.key_id
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uploader.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_10_minutes.arn
}