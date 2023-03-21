# Datasource for grabbing the latest Ubuntu 18.04 AMI
data "aws_ssm_parameter" "ubuntu_1804_ami_id" {
  name = "/aws/service/canonical/ubuntu/server/18.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# Server
resource "aws_instance" "server" {
  # count = 3 # Use the count meta-argument to make many
  # ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  ami = "ami-08fdec01f5df9998f"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.private.id]
  subnet_id                   = aws_subnet.private[0].id
  associate_public_ip_address = true
  key_name                    = var.ec2_key_pair_name

  tags = { "Name" = "${local.project_tag}-server" }

  user_data = base64encode(templatefile("${path.module}/files/server.sh", {
    SERVICE_NAME = "service"
  }))
}

resource "aws_instance" "alt_server" {
  # count = 3 # Use the count meta-argument to make many
  # ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  ami = "ami-08fdec01f5df9998f"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = var.alt_ec2_key_pair_name

  tags = { "Name" = "${local.project_tag}-server" }

  user_data = base64encode(templatefile("${path.module}/files/server.sh", {
    SERVICE_NAME = "service"
  }))
}

# The Boundary Worker Elastic IP
resource "aws_eip" "boundary_worker" {
  vpc = true

  tags = { "Name" = "${local.project_tag}-boundary-eip" }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip_association" "boundary_worker" {
  instance_id = aws_instance.boundary_worker.id
  allocation_id = aws_eip.boundary_worker.id
}

resource "aws_instance" "boundary_worker" {
  # count = 3 # Use the count meta-argument to make many
  ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  # ami = "ami-08fdec01f5df9998f"
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.boundary.id]
  subnet_id                   = aws_subnet.public[0].id
  # associate_public_ip_address = true
  key_name                    = var.ec2_key_pair_name

  tags = { "Name" = "${local.project_tag}-boundary-server" }

  user_data = base64encode(templatefile("${path.module}/files/boundary.sh", {
    CLUSTER_ID = var.boundary_cluster_id
    WORKER_PUBLIC_IP = aws_eip.boundary_worker.public_ip
    # CONTROLLER_TOKEN = random_id.boundary_worker_token.id
  }))
}