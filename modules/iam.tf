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
      # Statement = [
      #   {
      #     Action = [
      #       "s3:PutObject",
      #       "s3:PutObjectAcl",
      #       "s3:GetObject",
      #       "s3:GetObjectAcl",
      #       "s3:ListBucket"
      #     ]
      #     Resource = [
      #       "${aws_s3_bucket.yahoo_bucket.arn}",
      #       "${aws_s3_bucket.yahoo_bucket.arn}/*"
      #     ]
      #     Effect = "Allow"
      #   },
      # ]
      # Statement = [
      #   {
      #     Action = [
      #       "kms:Encrypt",
      #       "kms:Decrypt",
      #       "kms:GenerateDataKey",
      #       "kms:Describe*",
      #       "kms:List*",
      #     ]
      #     Resource = [
      #       "${aws_kms_key.yahoo.key_id}"
      #     ]
      #     Effect = "Allow"
      #   },
      # ]
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

data "aws_iam_policy_document" "lambda" {
  statement {
    sid = ""
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:Describe*",
      "kms:List*",
    ]
    effect = "Allow"
    resources = [
      "${aws_kms_key.yahoo.arn}"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket"
    ]
    effect = "Allow"

    resources = [
      "${aws_s3_bucket.yahoo_bucket.arn}",
      "${aws_s3_bucket.yahoo_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "A lambda policy"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}