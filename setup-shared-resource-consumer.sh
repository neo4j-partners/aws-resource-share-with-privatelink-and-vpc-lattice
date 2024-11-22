
#!/bin/bash

echo "Here are the environment variables to consume a shared resource:"
aws_profile="aura-dev"
vpc_id="vpc-1234"
subnet_ids="subnet-1234 subnet-1234" 
security_group_id="sg-1234"
resource_gateway_id="rgw-1234"
resource_config_name="neo4j-rcgf"
aws_region="us-west-2"
service_network_name="neo4j-share-sn"

head -n 13 $0
echo
read -p "Press any key to continue... " -n1 -s

echo "Step 1: Get Resource Share Invitations"
echo
echo "Executing: AWS_PROFILE=$aws_profile aws ram get-resource-share-invitations --region $aws_region"
echo
read -p "Press any key to continue... " -n1 -s

invites=$(AWS_PROFILE=$aws_profile aws ram get-resource-share-invitations --region $aws_region)
pending_invite_arn=$(echo "$invites" | jq -r '.resourceShareInvitations[] | select(.status=="PENDING") | .resourceShareInvitationArn')

echo "Step 2: Accept the Resource Share Invitation"
echo
if [[ -n "$pending_invite_arn" ]]; then
    echo
    echo "Executing: AWS_PROFILE=$aws_profile aws ram accept-resource-share-invitation --resource-share-invitation-arn \"$pending_invite_arn\" --region $aws_region"
    echo
    read -p "Press any key to continue... " -n1 -s
    
    AWS_PROFILE=$aws_profile aws ram accept-resource-share-invitation --resource-share-invitation-arn "$pending_invite_arn" --region $aws_region
    echo "Resource share invitation accepted successfully."
else
    echo "No pending resource share invitation found. Proceeding with the assumption it was accepted via the AWS console."
fi

echo "Step 3: Create Service Network"
echo
echo "Executing: AWS_PROFILE=$aws_profile aws vpc-lattice create-service-network --name $service_network_name --region $aws_region"
echo
read -p "Press any key to continue... " -n1 -s

service_network_response=$(AWS_PROFILE=$aws_profile aws vpc-lattice create-service-network --name $service_network_name --region $aws_region)
neo4j_serv_nw_id=$(echo "$service_network_response" | jq -r '.id')
neo4j_serv_nw_arn=$(echo "$service_network_response" | jq -r '.arn')

echo "Step 4: List Resource Configurations and Filter for the Target Config"
echo
echo "Executing: AWS_PROFILE=$aws_profile aws vpc-lattice list-resource-configurations --region $aws_region"
echo
read -p "Press any key to continue... " -n1 -s

resource_configs=$(AWS_PROFILE=$aws_profile aws vpc-lattice list-resource-configurations --region $aws_region)
res_conf_id=$(echo "$resource_configs" | jq -r ".items[] | select(.resourceGatewayId==\"$resource_gateway_id\" and .name==\"$resource_config_name\") | .id")

echo "Step 5: Add Resource Configuration to the Service Network"
if [[ -n "$res_conf_id" ]]; then
    echo
    echo "Executing: AWS_PROFILE=$aws_profile aws vpc-lattice create-service-network-resource-association --resource-configuration-identifier $res_conf_id --service-network-identifier $neo4j_serv_nw_id --region $aws_region"
    echo
    read -p "Press any key to continue... " -n1 -s
    
    snra_response=$(AWS_PROFILE=$aws_profile aws vpc-lattice create-service-network-resource-association --resource-configuration-identifier "$res_conf_id" --service-network-identifier "$neo4j_serv_nw_id" --region $aws_region)
    snra_domain=$(echo "$snra_response" | jq -r '.dnsEntry.domainName')
    echo "SNRA Domain: " $snra_domain
else
    echo "Resource configuration ID not found. Please check the input parameters."
    exit 1
fi

echo "Step 6: Create VPC Service Network Endpoint"
echo
echo "Executing: AWS_PROFILE=$aws_profile aws ec2 create-vpc-endpoint --vpc-endpoint-type ServiceNetwork --vpc-id $vpc_id --subnet-ids $subnet_ids --service-network-arn $neo4j_serv_nw_arn --security-group-id $security_group_id --region $aws_region"
echo
read -p "Press any key to continue... " -n1 -s

vpc_endpoint_response=$(AWS_PROFILE=$aws_profile aws ec2 create-vpc-endpoint --vpc-endpoint-type ServiceNetwork --vpc-id "$vpc_id" --subnet-ids $subnet_ids --service-network-arn "$neo4j_serv_nw_arn" --security-group-id "$security_group_id" --region "$aws_region")
vpc_endpoint_id=$(echo "$vpc_endpoint_response" | jq -r '.VpcEndpoints[0].VpcEndpointId')

# Combine VPC Endpoint ID and Service Network Resource Association Domain
endpoint_domain="${vpc_endpoint_id}-${snra_domain}"
echo
echo "Endpoint Domain Name: $endpoint_domain"
