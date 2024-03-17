resource "aws_s3_bucket" "yahoo_bucket" {
  bucket = "yahoo-bucket-03182024"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.yahoo_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.yahoo.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.yahoo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_acl" "private" {
  depends_on = [aws_s3_bucket_ownership_controls.owner]

  bucket = aws_s3_bucket.yahoo_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.yahoo_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_policy" "allow_encrypted" {
  bucket = aws_s3_bucket.yahoo_bucket.id
  policy = data.aws_iam_policy_document.allow_encrypted.json
}

data "aws_iam_policy_document" "allow_encrypted" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.yahoo_bucket.arn}/*",
    ]
    condition {
      test = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = ["aws:kms"]
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "rule" {

  depends_on = [aws_s3_bucket_versioning.versioning_example]
  bucket = aws_s3_bucket.yahoo_bucket.id
  rule {
    id = "config"
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }
    status = "Enabled"
  }
}