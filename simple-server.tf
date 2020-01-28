resource "aws_instance" "simple-server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = var.key_pair
    iam_instance_profile = aws_iam_instance_profile.simple-main-profile.id
    vpc_security_group_ids = [aws_security_group.simple-server-sg.id]
    user_data = templatefile("${path.module}/scripts/simple-install.sh", {
        AWS_ACCESS_KEY = var.aws_access_key,
        AWS_SECRET_KEY = var.aws_secret_key,
        AWS_REGION = var.aws_region
    })

    tags = {
        Name = "kevin-simple-server"
    }
}

resource "aws_security_group" "simple-server-sg" {
    name = "simple-server-sg"
    description = "Simple server security group"
    vpc_id = data.aws_vpc.primary-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
       from_port = 5822
       to_port = 5822
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

data "aws_iam_policy_document" "simple-assume-role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "simple-main-access-doc" {
  statement {
    sid       = "FullAccess"
    effect    = "Allow"
    resources = ["*"]

    actions = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "ec2messages:GetMessages",
        "ssm:UpdateInstanceInformation",
        "ssm:ListInstanceAssociations",
        "ssm:ListAssociations",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:BatchGetImage",
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
        "s3:*"
    ]
  }
}

resource "aws_iam_role" "simple-main-access-role" {
  name               = "simple-access-role"
  assume_role_policy = data.aws_iam_policy_document.simple-assume-role.json
}

resource "aws_iam_role_policy" "simple-main-access-policy" {
  name   = "simple-access-policy"
  role   = aws_iam_role.simple-main-access-role.id
  policy = data.aws_iam_policy_document.simple-main-access-doc.json
}

resource "aws_iam_instance_profile" "simple-main-profile" {
  name = "simple-access-profile"
  role = aws_iam_role.simple-main-access-role.name
}
