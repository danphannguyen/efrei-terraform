# Fonction Lambda pour formatter les messages SNS S3
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content  = <<EOF
import json
import boto3
import os
from datetime import datetime

def lambda_handler(event, context):
    # Extraire le message S3 du SNS
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    s3_event = sns_message['Records'][0]

    # Extraire les informations importantes
    bucket_name = s3_event['s3']['bucket']['name']
    object_key = s3_event['s3']['object']['key']
    object_size = s3_event['s3']['object']['size']
    event_time = s3_event['eventTime']
    event_name = s3_event['eventName']
    source_ip = s3_event.get('requestParameters', {}).get('sourceIPAddress', 'N/A')
    user_agent = s3_event.get('userAgent', 'N/A')

    # Formatter la date
    dt = datetime.fromisoformat(event_time.replace('Z', '+00:00'))
    formatted_time = dt.strftime('%d/%m/%Y %H:%M:%S UTC')

    # Créer un message HTML lisible
    html_message = f"""
    <html>
    <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">
            <h2 style="color: #d32f2f; margin-top: 0;">🚨 Alerte Sécurité - Upload de Document</h2>
            <p style="color: #666; margin-bottom: 0;">Un document sensible a été déposé dans le coffre-fort RH</p>
        </div>

        <div style="background-color: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <h3 style="color: #1976d2; margin-top: 0;">📄 Détails du document</h3>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold; width: 150px;">Nom du fichier:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{object_key}</td>
                </tr>
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">Taille:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{object_size:,} bytes ({object_size/1024/1024:.2f} MB)</td>
                </tr>
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">Bucket:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{bucket_name}</td>
                </tr>
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">Action:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{event_name.replace('ObjectCreated:', 'Création - ')}</td>
                </tr>
            </table>
        </div>

        <div style="background-color: #fff; border: 1px solid #ddd; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
            <h3 style="color: #1976d2; margin-top: 0;">🔍 Informations de sécurité</h3>
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold; width: 150px;">Date/Heure:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{formatted_time}</td>
                </tr>
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">IP source:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{source_ip}</td>
                </tr>
                <tr>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee; font-weight: bold;">User Agent:</td>
                    <td style="padding: 8px 0; border-bottom: 1px solid #eee;">{user_agent[:50]}{'...' if len(user_agent) > 50 else ''}</td>
                </tr>
            </table>
        </div>

        <div style="background-color: #e8f5e8; border: 1px solid #4caf50; border-radius: 8px; padding: 20px;">
            <h3 style="color: #2e7d32; margin-top: 0;">✅ Chiffrement activé</h3>
            <p style="margin-bottom: 0; color: #2e7d32;">
                Ce document est automatiquement chiffré avec AWS KMS pour garantir sa confidentialité.
            </p>
        </div>

        <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; font-size: 12px;">
            <p style="margin: 0;">
                <strong>Coffre-fort RH Sécurisé</strong> - Surveillance automatique des dépôts de documents<br>
                Généré automatiquement par AWS Lambda - Ne pas répondre à cet email
            </p>
        </div>
    </body>
    </html>
    """

    # Créer un message texte brut aussi (fallback)
    text_message = f"""
🚨 ALERTE SÉCURITÉ - UPLOAD DE DOCUMENT

Un document sensible a été déposé dans le coffre-fort RH.

📄 DÉTAILS DU DOCUMENT:
- Nom du fichier: {object_key}
- Taille: {object_size:,} bytes ({object_size/1024/1024:.2f} MB)
- Bucket: {bucket_name}
- Action: {event_name.replace('ObjectCreated:', 'Création - ')}

🔍 INFORMATIONS DE SÉCURITÉ:
- Date/Heure: {formatted_time}
- IP source: {source_ip}
- User Agent: {user_agent[:50]}{'...' if len(user_agent) > 50 else ''}

✅ CHIFFREMENT: Activé avec AWS KMS

---
Coffre-fort RH Sécurisé - Surveillance automatique
Généré par AWS Lambda
    """.strip()

    # Publier le message formaté vers le topic SNS FORMATÉ
    sns_client = boto3.client('sns')
    
    # Récupérer le topic formaté depuis les variables d'environnement
    formatted_topic_arn = os.environ.get('FORMATTED_TOPIC_ARN')
    
    sns_client.publish(
        TopicArn=formatted_topic_arn,
        Subject='🚨 Alerte Sécurité - Document déposé dans le coffre-fort RH',
        Message=text_message,
        MessageStructure='string'
    )

    # Pour les emails HTML, on peut aussi envoyer directement
    # Mais SNS email ne supporte pas nativement HTML, donc on garde le texte formaté

    return {
        'statusCode': 200,
        'body': 'Message formaté et renvoyé'
    }
EOF
    filename = "lambda_function.py"
  }
}

# Rôle IAM pour la fonction Lambda
resource "aws_iam_role" "lambda_sns_formatter" {
  name = "lambda-sns-formatter-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attacher la policy de base pour CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_sns_formatter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy pour permettre à Lambda de publier sur les deux topics SNS
resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "lambda-sns-publish-policy"
  role = aws_iam_role.lambda_sns_formatter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sns:Publish"
      Resource = [
        aws_sns_topic.alerte_securite.arn,
        aws_sns_topic.alerte_securite_formatted.arn
      ]
    }]
  })
}

# Fonction Lambda
resource "aws_lambda_function" "sns_formatter" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "sns-message-formatter"
  role            = aws_iam_role.lambda_sns_formatter.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerte_securite.arn
      FORMATTED_TOPIC_ARN = aws_sns_topic.alerte_securite_formatted.arn
    }
  }
}

# Permission pour que SNS puisse invoquer la Lambda
resource "aws_lambda_permission" "sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sns_formatter.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alerte_securite.arn
}

# Abonnement de la Lambda au topic SNS BRUT (pour traitement)
resource "aws_sns_topic_subscription" "lambda_formatter" {
  topic_arn = aws_sns_topic.alerte_securite.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.sns_formatter.arn
}

# Note: L'abonnement email est maintenant dans sns.tf sur le topic formaté