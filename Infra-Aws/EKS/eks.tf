




resource "aws_iam_role" "eks_role" {
  name = "${var.environment}-eks-role"
  assume_role_policy = <<EOF
{

  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::835258370354:user/umair-azam"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_role.name
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_role.name
}


resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}



resource "aws_security_group" "eks_sg" {
  name        = "eks-security-group"
  description = "Security group for EKS cluster"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
 }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-eks-security-group"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.environment}-cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids  # Replace with your public subnet ID
  }
  depends_on = [aws_security_group.eks_sg]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.environment}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_role.arn
  subnet_ids      = var.subnet_ids  # Replace with your public subnet ID
  scaling_config {
    desired_size = 2  # Adjust the desired size as needed
    min_size     = 1
    max_size     = 3
  }
    depends_on = [
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.ecr_read_only_policy,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_eks_cluster.eks_cluster
  ]

}




# data "aws_eks_cluster_auth" "cluster_auth" {
#   name = aws_eks_cluster.eks_cluster
# }

# resource "local_file" "kubeconfig" {
#   content  = data.aws_eks_cluster_auth.cluster_auth.kubeconfig[0]
#   filename = "${path.module}/kubeconfig"
# }

# docker push 835258370354.dkr.ecr.eu-north-1.amazonaws.com/sb-repo/:latest
# docker tag space_beacon:latest 835258370354.dkr.ecr.eu-north-1.amazonaws.com/sb-repo:latest
# aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin 835258370354.dkr.ecr.eu-north-1.amazonaws.com

