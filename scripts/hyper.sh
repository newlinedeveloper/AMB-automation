#!/bin/bash

# Set up environment variables
NETWORK_NAME="hyper-chain"
VOTING_POLICY="APPROVAL_THRESHOLD"
THRESHOLD_PERCENTAGE=51
MEMBER_NAME="example-member"
NODE_COUNT=2
NODE_TYPE="t3.micro"

# Create the network
aws managedblockchain create-network --name $NETWORK_NAME --framework hyperledger-fabric --voting-policy $VOTING_POLICY --approval-threshold-percentage $THRESHOLD_PERCENTAGE

# Create a member
aws managedblockchain create-member --network-id $(aws managedblockchain list-networks --name $NETWORK_NAME --query "Networks[0].Id" --output text) --member-name $MEMBER_NAME

# Create nodes
for i in $(seq 1 $NODE_COUNT); do
  aws managedblockchain create-node --network-id $(aws managedblockchain list-networks --name $NETWORK_NAME --query "Networks[0].Id" --output text) --member-id $(aws managedblockchain list-members --network-id $(aws managedblockchain list-networks --name $NETWORK_NAME --query "Networks[0].Id" --output text) --query "Members[0].Id" --output text) --node-type $NODE_TYPE
done

# Create a proposal to invite the member
aws managedblockchain create-proposal --network-id $(aws managedblockchain list-networks --name $NETWORK_NAME --query "Networks[0].Id" --output text) --member-id $(aws managedblockchain list-members --network-id $(aws managedblockchain list-networks --name $NETWORK_NAME --query "Networks[0].Id" --output text) --query "Members[0].Id" --output text) --actions Invitations=$MEMBER_NAME
