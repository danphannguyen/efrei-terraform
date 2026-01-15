# --- Amazon SNS ---
# Topic 1: Reçoit les notifications brutes de S3
resource "aws_sns_topic" "alerte_securite" {
  name = var.sns_topic_name
}

# Topic 2: Pour les emails formatés (envoyé par Lambda)
resource "aws_sns_topic" "alerte_securite_formatted" {
  name = "${var.sns_topic_name}-formatted"
}

# Abonnement email sur le topic FORMATÉ uniquement
resource "aws_sns_topic_subscription" "email_admin_formatted" {
  topic_arn = aws_sns_topic.alerte_securite_formatted.arn
  protocol  = "email"
  endpoint  = var.admin_email
}

# Autorisation : S3 doit avoir le droit de publier dans le topic brut
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerte_securite.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "s3.amazonaws.com" },
      Action    = "SNS:Publish",
      Resource  = aws_sns_topic.alerte_securite.arn,
      Condition = {
        ArnLike = { "aws:SourceArn" = aws_s3_bucket.coffre_fort_rh.arn }
      }
    }]
  })
}