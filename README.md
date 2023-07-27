# DevOps Galactic Mission: Operation Terraform
*Author: [Zhangir Kapishov](https://www.linkedin.com/in/zhangir-kapishov/)*

Welcome!

This repository is your gateway to the DevOps Galactic Mission. Here, you will find all the necessary resources and instructions to successfully complete the mission. Follow the steps and details provided below to reproduce my solution and embark on your own interstellar adventure.

I have carefully documented my journey and made sure to address any potential difficulties you may encounter along the way. Rest assured, my guide is designed to help you navigate through the mission smoothly and without any major obstacles.

I hope you find this guide enjoyable and informative. May your mission be a resounding success, and may the force of DevOps be with you!

---

## Table of Contents

1. [Mission Brief](#mission-brief)
2. [Mission Tools](#mission-tools)
3. [Task 1: Terraform - Establishing the Outpost](#task-1)
4. [Task 2: Docker - Building the Space Beacon](#task-2)
5. [Task 3: Helm - Deploying the Space Beacon](#task-3)
6. [Feedback](#feedback)

---

## Mission Brief

Greetings, Space Engineer! Welcome to the DevOps Galactic Mission: Operation Terraform. Your mission is to establish a Kubernetes outpost in your personal AWS Galaxy using Terraform and deploy the crucial "Space Beacon" microservice using Helm.

### Objective

Your objective is to deploy a Kubernetes cluster in your personal AWS Galaxy (account), and
then deploy a "Space Beacon" microservice using Helm.

---

## Mission Tools

1. Terraform: Infrastructure provisioning tool
2. Docker: Containerization platform
3. Helm: Package manager for Kubernetes
4. AWS EKS: Elastic Kubernetes Service
5. AWS VPC: Virtual Private Cloud
6. AWS ECR: Elastic Container Registry
7. GitHub repository: Mission control center

---

## Task 1

Terraform - Establishing the Outpost

### Description

Your first task is to lay the foundation of our outpost. Write a Terraform script that:
1. Creates a VPC in your AWS Galaxy with a single public subnet.
2. Sets up an EKS (Elastic Kubernetes Service) cluster in the VPC. To aid this task, you may
utilize the official EKS Terraform module.
3. Implements the necessary security measures (security groups, IAM roles, etc.) for the EKS
cluster.
4. Outputs the outpost coordinates (kubeconfig) to connect to the EKS cluster.

### Solution

1.  For creating a VPC with a single public subnet, a VPC module is used. [VPC Docs](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html). [VPC Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest).

#### Challenges and explanations

- When creating a cluster, you need to specify a VPC and at least two subnets in different Availability Zones. [Docs](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html).

```
azs             = ["eu-central-1a", "eu-central-1b"]  # Specify subnets from two different AZs

public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]      # Specify subnets from two different AZs
```

- Enable auto-assigning public IP addresses to EC2 instances.
```
map_public_ip_on_launch = true
```

2.  For creating an EKS cluster within the VPC, the EKS module is used. [VPC Docs](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html). [VPC Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest).

#### Challenges and explanations
- Enable all the available logs from the control plane for better troubleshooting the applications.

```
  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
```

- My choice of EC2 instance type is t2.micro, as it is part of a free tier. 

- I use EKS managed node instead of self-managed, because it simplifies the management and scaling of worker nodes in an EKS cluster, reducing operational overhead and allowing you to focus more on your applications. While in comparison to Fargate, Using AWS EKS-managed node groups provides more control and flexibility over the underlying infrastructure, enabling advanced customization options and allowing direct access to EC2 instances within the EKS cluster.

- My desired size of the EKS managed node group is 2 because 1 node of a type t2.micro is insufficient for system and space-beacon application pods. In this situation, the best practice is to use node autoscaling. [Karpenter Docs](https://karpenter.sh/docs/).

- Note, this k8s cluster setup is not production ready. It is used only for development purposes. To make it production ready, add at least:
  - Three worker nodes from different availability zones.
  - Configured monitoring with Prometheus, Alertmanager, and Grafana.


3. Security groups and IAM roles for security measurements are deployed within the EKS module.

4. In order to output the EKS cluster kubeconfig, eks-kubeconfig module is used. [Eks-kubeconfig Module Docs](https://registry.terraform.io/modules/hyperbadger/eks-kubeconfig/aws/latest) 

#### Challenges and explanations

- Module eks-kubeconfig should run after the completion of the EKS module.

```
depends_on = [module.eks]
```

- It is required to secure our kubeconfig output. Kubeconfig is not displayed in the console or stored in the Terraform state file. Either there will be an error.

```
sensitive = true
```

### Steps

1. Install terraform. [The Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

2. Create a user group "terraform" in AWS IAM. [The Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups_create.html). 

* As a best practice, AWS recommends attaching policies to a group instead of attaching a managed policy directly to a user. Then, add the user to the appropriate group.*

3. Assign the needed permissions to the user group "terraform". 

- Attach AWS-managed policies:
    - CloudWatchLogsFullAccess
    - IAMFullAccess
    - AWSKeyManagementServicePowerUser
    - AmazonVPCFullAccess
    - AmazonEKSClusterPolicy

- Create an inline policy. JSON is [here](policies/eksCreateCluster.json). *Replace 599151311607 with your Account ID*.

4. Create a user "terraform" in AWS IAM and add the user to an existing "terraform" user group. [The Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html).

5. Create an access key for user "terraform". [Docs](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

6. Clone the mission control center repository.

```
 git clone https://github.com/ZhangirK/DevOps-Galactic-Mission.git
```

7. Use your IAM credentials to authenticate the Terraform AWS provider. Set access key [Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build).

```
export AWS_ACCESS_KEY_ID=

export AWS_SECRET_ACCESS_KEY=
```

8. Navigate to the terraform directory.

```
cd $PATH/DevOps-Galactic-Mission/terraform  #replace $PATH with the location of the repository 
```

9. Initialize the terraform directory.

```
terraform init
```

10. Create infrastructure.

```
terraform apply --auto-approve
```

11. Redirect kubeconfig to the file.

```
terraform output kubeconfig > kubeconfig
```

---

## Task 2

Docker - Building the Space Beacon

### Description

Next, you need to construct our Space Beacon. Develop a Dockerfile for a simple application
using the language of your choice. The application should listen on port 80 and respond to HTTP
GET requests with "Greetings from the DevOps Squadron!".
Once the Docker image is built, push it to a container registry of your choice (e.g., Docker Hub,
AWS ECR, Google Container Registry).

### Solution

1.  I created a simple application in Python without any frameworks.
2. The lightweight Dockerfile is created. [Best practices Docs](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).

#### Challenges and explanations

- I used a lightweight official docker image with Python. Also, a specific tag is used instead of the latest.
- I added a non-root user for the security measurements. That is the reason I set the application port to 8080. Port 80 requires root priveleges to expose. However, in the next task my k8s service exposes 80 port.  
- I did not use a multistage in this case, because it will not affect to the size of an image.
- Additionally, the vulnerability and best practices image scanner is used. [Dockle](https://github.com/goodwithtech/dockle)

3. AWS ECR with a private repository is used as a main container registry. It is created via terraform module ecr. [AWS ECR Docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html). [ECR Module Docs](https://registry.terraform.io/modules/terraform-aws-modules/ecr/aws/latest).

### Steps

1. AWS ECR private repository is already deployed via terraform in Task 1. 

2. Install AWS CLI. [Installation Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

3. Create an access key for your account. It is not recommended to do it for the root user. Make sure your user has the needed permissions. [Docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-build).

4. Configure your profile in AWS CLI. [Configuring Docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

```
aws configure

AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE

AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

Default region name [None]: eu-central-1

Default output format [None]: json
```

5. Navigate to the directory with Dockerfile.

```
cd $PATH/DevOps-Galactic-Mission/app  #replace $PATH with the location of the repository
```

6. Install Docker. [Installation guide](https://docs.docker.com/engine/install/ubuntu/).

7. Authenticate your Docker client to the Amazon ECR registry to which you intend to push your image.

```
aws ecr get-login-password --region eu-central-1 | sudo docker login --username AWS --password-stdin your_aws_account_id.dkr.ecr.eu-central-1.amazonaws.com
```

*Do not run the aws command with sudo!*

8. Build the image.

```
sudo docker build -t your_aws_account_id.dkr.ecr.eu-central-1.amazonaws.com/private-force:0.1.0 .
```

9. Push the image.

```
sudo docker push your_aws_account_id.dkr.ecr.eu-central-1.amazonaws.com/private-force:0.1.0
```

---

## Task 3

Helm - Deploying the Space Beacon

### Description
With the Space Beacon ready, it's time to deploy. Create a Helm chart for the application. This
should include:
1. A deployment configuration for the Space Beacon (the Docker image you created in the
previous task).
2. A service to transmit our beacon signal.
3. Any additional elements that you consider vital for a production-grade deployment.
Explain your choices and their importance

### Solution

A custom Helm is created for this task. [Helm Docs](https://helm.sh/docs/). 

Command to create a custom Helm chart automatically

```
helm create space-beacon
```

This chart contains the following templates:
- deployment
- hpa
- ingress
- service
- serviceaccount

I also changed deployment.yaml, service.yaml and values file. 

deployment.yaml: 

```
ports:
  - name: http
    containerPort: {{ .Values.service.targetPort }}  #add an ability to customize the port
    protocol: TCP
```

service.yaml:

```
ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}  #add an ability to customize the port. The same as deployment port 
    protocol: TCP
    name: http
```

values file:

```
image:
  repository: 599151311607.dkr.ecr.eu-central-1.amazonaws.com/private-force  #the needed image repo
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: "0.1.0"
```

Note, this helm release is not production ready. It is used only for development purposes. To make it production ready, add at least:
- Three pod replicas.
- Configure Pod Distribution Budget.
- Configure PodAntiAffinity.
- Enable ingress with Cloudflare in order to securely expose applications to the internet.
- Enable hpa for pod autoscaling.
- Configure [KEDA](https://keda.sh/).
- Configure additional monitoring and alerting with Prometheus, Alertmanager, and Grafana. 
- Configure continuous logging with ELK.

### Steps

1. Install helm. [Installation Docs](https://helm.sh/docs/intro/install/).

2. Add kubeconfig of your cluster to ~/.kube/config. *remove the <<EOT EOT from the file*. The kubeconfig is outputted in the previous task.

3. Navigate to the helm directory.

```
cd $PATH/DevOps-Galactic-Missionn/helm  #replace $PATH with the location of the repository
```

4. Install a new release to your k8s cluster.

```
helm upgrade app ./space-beacon --install -n space --create-namespace --set image.repository=<your account id>.dkr.ecr.eu-central-1.amazonaws.com/private-force --set image.tag=0.1.0
```

5. Check the functionality of an application. Wait until the pod is running. 

```
kubectl port-forward -n space service/app-space-beacon 8080:80 &  #port-forward the service in the background

curl localhost:8080  #curl the app
```

---

## Feedback

The DevOps Galactic Mission: Operation Terraform was an exciting and beneficial experience for me. It provided a great opportunity to work with AWS and Terraform, allowing me to enhance my skills in infrastructure provisioning and management.

This mission was particularly valuable because it encouraged a learn-by-doing approach. It enabled me to gain practical experience with essential tools such as AWS, Terraform, Docker, and Helm, which are widely used in the industry.

The tasks were well-structured and covered crucial aspects of a deployment. Creating a VPC, setting up an EKS cluster, building a Docker image, and deploying the microservice using Helm helped me understand the end-to-end process of establishing a Kubernetes-based application.

The challenge also emphasized the importance of best practices, including security measures, efficiency, and scalability. This knowledge will undoubtedly be valuable in real-world scenarios, where adhering to best practices is vital for successful deployments.

Another important thing is that the mission does not restrict the Space Engineers to use or add any additional tools. Engineers are free to add CI/CD, Karpenter, and even expose the application to the internet. 

Overall, I thoroughly enjoyed the time spent on this mission and found it to be an engaging and educational experience. It has further solidified my interest in DevOps and my desire to continue learning and growing in this field.

Thank you for providing me with this opportunity, and I look forward to discussing my solution and experiences during the interview process:)

May the force of DevOps be with you!

Sincerely,

Zhangir Kapishov
