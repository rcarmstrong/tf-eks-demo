# Create the EKS cluster
resource "aws_eks_cluster" "eks_demo" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    security_group_ids = [
      aws_security_group.control_plane_sg.id
    ]
    
    subnet_ids = [
      aws_subnet.public_subnet_01.id,
      aws_subnet.public_subnet_02.id,
      aws_subnet.private_subnet_01.id,
      aws_subnet.private_subnet_02.id
    ]
  }
}

# Create a node group with 4 (2 per subnet) t3.micro instances
resource "aws_eks_node_group" "eks_demo_node_group" {
  cluster_name    = aws_eks_cluster.eks_demo.name
  node_group_name = "test-nodes"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  instance_types  = ["t3.micro"]

  # Launch nodes in the private subnets
  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id
  ]

  scaling_config {
    desired_size = 4
    max_size     = 4
    min_size     = 4
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryReadOnly,
  ]
}
