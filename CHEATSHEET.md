# Commande Terraform
terraform init          # Initialise le projet terraform
terraform plan          # Vérifie les modifications avant de les appliquer
terraform apply         # Applique les modifications
terraform destroy       # Permet de tout supprimer pour ne pas payer inutilement

# Commande permettant de vérifier les types d'instance disponible selon desfiltres (exemple t3.micro)
aws ec2 describe-instance-types --filters "Name=free-tier-eligible,Values=true" --region eu-north-1

Rechercher les lignes de type :
```
"InstanceType": "c7i-flex.large",
```

# Se connecter en SSH à l'une des deux VM (test du port 22)
Attention la clé RSA terraform doit avoir des permissions particulère : 
`chmod 400 terraform-key.pem`

Sinon on peut se connecter via : 
VM1 : `ssh -i terraform-key.pem ec2-user@13.60.233.118`
VM2 : `ssh -i terraform-key.pem ec2-user@16.171.166.203`

# Ping une des deux VM (test du port ICMP)
Utilisation des IP privées car les VM sont sur le même réseau
Depuis la VM1 : `ping 172.31.44.45`
Depuis la VM2 : `ping 172.31.32.217`

# Testez HTTP (port 80) :
1) Depuis la VM1 pour lancer un serveur : `python3 -m http.server 80`
2) Depuis la VM2 ping pour vérifier : `curl http://172.31.32.217`

1) Test de la VM2 pour lancer un serveur : `python3 -m http.server 80`
2) Depuis la VM1 ping pour vérifier : `curl http://172.31.44.45`