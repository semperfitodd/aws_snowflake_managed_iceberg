terraform {
  backend "s3" {
    bucket = "bsc.sandbox.terraform.state"
    key    = "aws_snowflake_managed_iceberg"
    region = "us-east-2"
  }
}