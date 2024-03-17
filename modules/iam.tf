resource "aws_iam_role" "lambda_upload_role" {
  name = "lambda_upload_role"
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
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.yahoo_bucket.arn}",
      "${aws_s3_bucket.yahoo_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "upload_policy" {
  name        = "lambda-policy"
  description = "A lambda policy"
  policy      = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.lambda_upload_role.name
  policy_arn = aws_iam_policy.upload_policy.arn
}

############################################################

resource "aws_iam_role" "lambda_fetch_role" {
  name = "lambda_fetch_role"
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

data "aws_iam_policy_document" "fetch" {
  statement {
    sid = ""
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
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

resource "aws_iam_policy" "fetch_policy" {
  name        = "fetch-policy"
  description = "A lambda fetch policy"
  policy      = data.aws_iam_policy_document.fetch.json
}

resource "aws_iam_role_policy_attachment" "fetch-attach" {
  role       = aws_iam_role.lambda_fetch_role.name
  policy_arn = aws_iam_policy.fetch_policy.arn
}

resource "aws_iam_role" "lambda_auth_role" {
  name = "lambda_auth_role"
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

data "aws_iam_policy_document" "auth" {
  statement {
    sid = ""
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    effect = "Allow"
    resources = [
      "${aws_dynamodb_table.rate_limit.arn}"
    ]
  }
  statement {
    sid = ""
    actions = [
      "cloudwatch:PutMetricData"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:cloudwatch:*"
    ]
  }
}

resource "aws_iam_policy" "auth_policy" {
  name        = "auth-policy"
  description = "A lambda auth policy"
  policy      = data.aws_iam_policy_document.auth.json
}

resource "aws_iam_role_policy_attachment" "auth-attach" {
  role       = aws_iam_role.lambda_auth_role.name
  policy_arn = aws_iam_policy.auth_policy.arn
}