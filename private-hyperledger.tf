
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}


# Configure the backend for remote state storage
terraform {
  backend "s3" {
    bucket = "my-tfstate-bucket"
    key    = "example/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_managedblockchain_network" "hyper_chain" {
  name      = "hyper-chain"
  framework = "HYPERLEDGER_FABRIC"
  voting_policy {
    approval_threshold_policy {
      threshold_percentage = 51
    }
  }
}

resource "aws_managedblockchain_member" "hyper_chain_member" {
  network_id  = aws_managedblockchain_network.hyper_chain.id
  member_name = "hyper-chain-member"
  member_configuration {
    vpc_endpoint_service_name = "com.amazonaws.us-east-1.managedblockchain"
  }
}

resource "aws_managedblockchain_node" "hyper_chain_node" {
  network_id = aws_managedblockchain_network.hyper_chain.id
  member_id  = aws_managedblockchain_member.hyper_chain_member.id
  node_type  = "t3.micro"
  count      = 2
}

resource "aws_managedblockchain_proposal" "hyper_chain_proposal" {
  network_id = aws_managedblockchain_network.hyper_chain.id
  member_id  = aws_managedblockchain_member.hyper_chain_member.id
  actions {
    invite_members {
      member_name = "hyper-chain-team-member"
    }
  }
}
