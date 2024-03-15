resource "aws_kms_key" "yahoo" {
  description = "S3 object encryption key"
}

resource "aws_kms_alias" "yahoo" {
  name          = "alias/yahoo-key-alias"
  target_key_id = aws_kms_key.yahoo.key_id
}