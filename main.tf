# Code principale de l'application

# Groupe de sécurité pour nos deux instances
resource "aws_security_group" "demo_sg" {
  name        = "terraform-demo-sg"
  description = "Security for 2 Terraform instances (SSH, ICMP, HTTP open between them)"
  # vpc_id non spécifié -> utilisera le VPC par défaut

 

  # Règles entrantes (ingress)
  ingress {
    description      = "SSH depuis ce groupe"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    self             = true    # autorise le trafic provenant des instances avec ce même SG
  }
  ingress {
    description      = "HTTP depuis ce groupe"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    self             = true
  }
  ingress {
    description      = "Ping/ICMP depuis ce groupe"
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    self             = true
  }
  ingress {
    description      = "SSH depuis mon IP (gestion)"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # <--- ASTUCE : ici on ouvre à tous par simplicité. (Ne pas faire en prod)
}

 

  # Règles sortantes (egress)
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]  # tout le trafic sortant est autorisé (règle par défaut)
}
}

 

# Deux instances EC2 Amazon Linux 2
resource "aws_instance" "vm1" {
  ami                    = data.aws_ami.amzn2.id   # AMI Amazon Linux 2 (via data source ci-dessous)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  key_name               = var.key_name

 

  tags = {
    Name = "DemoVM-1"
  }
}

 

resource "aws_instance" "vm2" {
  ami                    = data.aws_ami.amzn2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.demo_sg.id]
  key_name               = var.key_name

 

  tags = {
    Name = "DemoVM-2"
  }
}


# (Optionnel) Data source pour trouver l'AMI (AMI équivalent d'une Image) Amazon Linux 2 automatiquement
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # filtre pour Amazon Linux 2 x86_64
  }
}
