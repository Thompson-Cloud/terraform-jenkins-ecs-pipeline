data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-instance-profile"
  role = "techpathway-jenkins-role"
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
apt update -y
apt install -y openjdk-21-jre git docker.io curl unzip npm

systemctl enable docker
systemctl start docker

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

mkdir -p /opt/jenkins
wget -O /opt/jenkins/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war

nohup java -jar /opt/jenkins/jenkins.war --httpPort=8080 > /var/log/jenkins.log 2>&1 &
EOF

  depends_on = [
    aws_internet_gateway.main,
    aws_route_table_association.public
  ]

  tags = {
    Name = "${var.project_name}-jenkins-server"
  }
}