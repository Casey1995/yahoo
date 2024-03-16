resource "aws_kms_key" "yahoo" {
  description = "S3 object encryption key"
}

resource "aws_kms_alias" "yahoo" {
  name          = "alias/yahoo-key-alias"
  target_key_id = aws_kms_key.yahoo.key_id
}

##################################
#SecretsManager 
#################################
data "aws_secretsmanager_secret" "secret_token" {
  name = "cloudfront_secret_token"
  depends_on = [ aws_secretsmanager_secret.secret ]
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secret_token.id
  depends_on = [ aws_secretsmanager_secret.secret ]
}


#The secret will be updated manually via the console to avoid the risk of exposure.
resource "aws_secretsmanager_secret" "secret" {
  name = "cloudfront_secret_token"
  description = "cloudfront secret token"
  kms_key_id = aws_kms_key.yahoo.id
  tags = merge(var.map_tags, {"Name" = "CloudFront Secret"})
}