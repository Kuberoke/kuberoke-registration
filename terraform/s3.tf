resource "aws_s3_bucket" "frontend_origin" {
  bucket = "kuberoke-${var.environment}-frontend-origin"
}