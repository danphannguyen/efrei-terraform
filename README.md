# Terraform AWS Project

## Prérequis

- [Terraform](https://www.terraform.io/downloads) installé
- [AWS CLI](https://aws.amazon.com/cli/) installé
- Un compte AWS avec les permissions nécessaires

## Configuration AWS

### 1. Créer des clés d'accès AWS (si vous n'en avez pas)

#### a. Accéder à la console IAM AWS
- Rendez-vous sur https://console.aws.amazon.com/iam/
- Connectez-vous à votre compte AWS

#### b. Créer un utilisateur IAM
1. Dans le menu de gauche, cliquez sur **"Users"**
2. Cliquez sur **"Create user"**
3. Entrez un nom d'utilisateur (ex: `terraform-user`)
4. Cliquez sur **"Next"**

#### c. Attacher les permissions
1. Sélectionnez **"Attach policies directly"**
2. Recherchez et cochez ces policies :
   - `AmazonEC2FullAccess` (pour les instances EC2)
   - `AmazonS3FullAccess` (pour S3)
   - `AmazonSNSFullAccess` (pour SNS)
   - `AmazonKMSFullAccess` (pour KMS)
4. Cliquez sur **"Next"** puis **"Create user"**

#### d. Générer les clés d'accès
1. Dans la liste des utilisateurs, cliquez sur votre nouvel utilisateur
2. Allez dans l'onglet **"Security credentials"**
3. Dans la section **"Access keys"**, cliquez sur **"Create access key"**
4. Sélectionnez **"Command Line Interface (CLI)"**
5. Cochez la case de confirmation
6. Cliquez sur **"Create access key"**
7. **⚠️ IMPORTANT** : Copiez immédiatement :
   - **Access Key ID** (ex: `AKIAIOSFODNN7EXAMPLE`)
   - **Secret Access Key** (ex: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)

> **🔒 Sécurité** : Ces clés donnent accès à votre compte AWS. Ne les partagez jamais !

#### e. Bonnes pratiques de sécurité
- **Ne stockez jamais** les clés dans le code ou Git
- Utilisez des **profils nommés** pour différents environnements :
  ```bash
  aws configure --profile dev
  aws configure --profile prod
  ```
- **Faites tourner** régulièrement vos clés d'accès
- Utilisez **IAM Roles** quand possible au lieu des clés

### 2. Configurer les credentials AWS

```bash
aws configure
```

Entrez les informations suivantes :
- **AWS Access Key ID** : Votre clé d'accès (AKIA...)
- **AWS Secret Access Key** : Votre clé secrète
- **Default region name** : `eu-north-1` (ou votre région préférée)
- **Default output format** : `json`

### 3. Vérifier la configuration

```bash
aws sts get-caller-identity
```

Vous devriez voir vos informations de compte AWS.

#### Note sur les clés RSA et AWS
AWS utilise différents types de clés selon le contexte :

- **Clés SSH RSA** : Pour se connecter aux instances EC2 (voir section 4)
- **Clés KMS RSA** : Pour le chiffrement (gérées automatiquement par AWS KMS)
- **Clés d'API AWS** : Utilisent HMAC-SHA256, pas RSA directement

Si vous voulez utiliser des certificats RSA pour l'authentification IAM, consultez la documentation AWS sur les certificats X.509.

### 4. Créer une paire de clés SSH pour les instances EC2

#### a. Méthode recommandée : Via la console AWS (plus simple)

1. **Accéder à la console EC2** :
   - Rendez-vous sur https://console.aws.amazon.com/ec2/
   - Dans le menu de gauche, cliquez sur **"Key Pairs"**

2. **Créer une nouvelle paire de clés** :
   - Cliquez sur **"Create key pair"**
   - **Name** : `terraform-key`
   - **Key pair type** : `RSA`
   - **Private key file format** : `.pem`
   - Cliquez sur **"Create key pair"**

3. **Télécharger automatiquement la clé** :
   - AWS génère et télécharge automatiquement le fichier `terraform-key.pem`
   - Ce fichier contient votre **clé privée RSA**

#### b. Sécuriser et organiser la clé

```bash
# Déplacer la clé téléchargée 
mv ~/Downloads/terraform-key.pem ~/your-path

# Changer les permissions (TRÈS IMPORTANT pour SSH)
chmod 400 ~/Documents/terraform-keys/terraform-key.pem

# Vérifier les permissions
ls -la ~/Documents/terraform-keys/terraform-key.pem
# Doit afficher : -r-------- (400)
```

#### c. Alternative : Génération locale puis import

Si vous préférez générer la clé localement :

```bash
# Créer un dossier pour les clés
mkdir -p ~/.ssh/aws-keys
cd ~/.ssh/aws-keys

# Générer une paire de clés RSA 2048 bits
ssh-keygen -t rsa -b 2048 -f terraform-key -C "terraform-aws-key"

# Importer la clé publique dans AWS
aws ec2 import-key-pair \
  --key-name "terraform-key" \
  --public-key-material fileb://terraform-key.pub

# Sécuriser la clé privée
chmod 400 terraform-key
```

#### d. Tester la connexion SSH

```bash
# Après déploiement Terraform, récupérer l'IP publique
terraform output vm1_public_ip

# Se connecter à l'instance
ssh -i ~/path-to-you-key ec2-user@<IP_PUBLIQUE_VM1>

# Exemple concret :
ssh -i ~/Documents/terraform-keys/terraform-key.pem ec2-user@54.123.45.67
```

#### e. Bonnes pratiques pour les clés SSH

- **Ne partagez jamais** votre clé privée (`.pem`)
- Utilisez des **clés différentes** par environnement :
  - `terraform-key-dev.pem` pour développement
  - `terraform-key-prod.pem` pour production
- **Faites tourner** régulièrement vos clés SSH (tous les 3-6 mois)
- Stockez les clés dans un **gestionnaire de mots de passe** sécurisé
- **Sauvegardez** vos clés dans un endroit sûr (cloud sécurisé, disque externe)

## Vérifier la configuration complète
Avant de vérifier la configuration complète, assurez vous d'avoir modifier le fichier "variables_template.tf" et de l'avoir renommer "variables.tf"

### 1. Initialiser Terraform

```bash
terraform init
```

### 2. Planifier le déploiement

```bash
terraform plan
```

### 3. Appliquer la configuration

```bash
terraform apply
```

Tapez `yes` pour confirmer.

## Test du projet
Si vous lancé le projet pour la première fois, un mail de confirmation de souscription devrait arrivé dans votre boite mail (il peut se trouver dans les spams)

### 1. Upload d'un fichier
Vous pouvez upload un fichier via le GUI (S3 > Votre bucket > Section "Chiffrement") ou en ligne de commande : 
```bash
aws s3 cp <votre-fichier> s3://<nom-du-bucket>/
```


### 2. Vérifier la réception du mail

- Consultez votre boîte mail configurée
- Un email de notification devrait être reçu après l'upload

### 3. Vérifier le chiffrement du fichier
Vous pouvez vérifier via le GUI S3 > Votre bucket > Votre fichier > Section "Chiffrement" ou en ligne de commande
```bash
aws s3api head-object --bucket <nom-du-bucket> --key <nom-du-fichier>
```

Vérifiez que le champ `ServerSideEncryption` est présent (ex: `AES256` ou `aws:kms`).

## Nettoyage

Pour supprimer toutes les ressources créées :

```bash
terraform destroy
```

Tapez `yes` pour confirmer.