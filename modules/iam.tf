resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })

  inline_policy {
    name = "s3_access_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:ListBucket"
          ]
          Resource = [
            "${aws_s3_bucket.yahoo_bucket.arn}",
            "${aws_s3_bucket.yahoo_bucket.arn}/*"
          ]
          Effect = "Allow"
        },
      ]
      Statement = [
        {
          Action = [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:GenerateDataKey",
            "kms:Describe*",
            "kms:List*",
          ]
          Resource = [
            "${aws_kms_key.yahoo.key_id}"
          ]
          Effect = "Allow"
        },
      ]
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = [
            "arn:aws:logs:*:*:*"
          ]
          Effect = "Allow"
        },
      ]
    })
  }
}