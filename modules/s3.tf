resource "aws_s3_bucket" "yahoo_bucket" {
  bucket = "yahoo-bucket-03182024"
}

# resource "aws_s3_bucket_policy" "ssl_encrypt" {
#     bucket = "${aws_s3_bucket.yahoo_bucket.id}"
#     policy = <<EOF
#     {
#         "Version": "2012-10-17",
#         "Statement" [
#             "Effect": "Deny",
#             "Principal": "*",
#             "Action": "s3:PutObject",
#             "Resource": "${aws_s3_bucket.yahoo_bucket.arn}/*",
#             "Condition": {
#                 "StringNotEquals": {
#                     "s3:x-amz-server-side-encryption": "aws:kms"
#                 }
#             }
#         ]
#     }
#     EOF
# }

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