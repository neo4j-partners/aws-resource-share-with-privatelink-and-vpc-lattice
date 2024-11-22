#!/bin/bash

echo "Here are the environment variables to share a resource:"

resource_owner_aws_account_id="xxxx1974"
resource_consumer_aws_account_id="xxxx2298"
aws_region="us-west-2"
vpc_id="vpc-01234"
subnet_id="subnet-01234"
security_group_ids="sg-01234"
resource_gateway_name="neo4j-owner-rgw"
neo4j_resource_ip_addr="10.0.0.221"
neo4j_port_ranges="7474-7687"
resource_config_name="neo4j-rcgf"
resource_share_name="neo4j-db-share"

head -n 15 $0
echo
read -p "Press any key to continue... " -n1 -s

echo "Step 1: Create the Resource Gateway"

echo "Executing: aws vpc-lattice create-resource-gateway \
    --vpc-identifier \"$vpc_id\" \
    --subnet-ids \"$subnet_id\" \
    --security-group-ids \"$security_group_ids\" \
    --name \"$resource_gateway_name\" \
    --region \"$aws_region\""
echo
read -p "Press any key to continue... " -n1 -s

create_response=$(aws vpc-lattice create-resource-gateway \
    --vpc-identifier "$vpc_id" \
    --subnet-ids "$subnet_id" \
    --security-group-ids "$security_group_ids" \
    --name "$resource_gateway_name" \
    --region "$aws_region")

resource_gateway_id=$(echo "$create_response" | jq -r '.id')

echo "Step 2: Wait for Resource Gateway to become ACTIVE"
status=""

echo "Executing: aws vpc-lattice get-resource-gateway \
        --resource-gateway-identifier "$resource_gateway_id" \
        --region "$aws_region""
echo        
read -p "Press any key to continue... " -n1 -s       

while [ "$status" != "ACTIVE" ]; do
    get_response=$(aws vpc-lattice get-resource-gateway \
        --resource-gateway-identifier "$resource_gateway_id" \
        --region "$aws_region")
    status=$(echo "$get_response" | jq -r '.status')
    sleep 20
done

echo "Step 3: Create the Resource Configuration"
echo "Executing: aws vpc-lattice create-resource-configuration \
    --type SINGLE \
    --resource-configuration-definition "{ \"ipResource\": { \"ipAddress\": \"$neo4j_resource_ip_addr\" } }" \
    --port-ranges "$neo4j_port_ranges" \
    --protocol TCP \
    --resource-gateway-identifier "$resource_gateway_id" \
    --name "$resource_config_name" \
    --region "$aws_region""
echo
read -p "Press any key to continue... " -n1 -s
echo
create_config_response=$(aws vpc-lattice create-resource-configuration \
    --type SINGLE \
    --resource-configuration-definition "{ \"ipResource\": { \"ipAddress\": \"$neo4j_resource_ip_addr\" } }" \
    --port-ranges "$neo4j_port_ranges" \
    --protocol TCP \
    --resource-gateway-identifier "$resource_gateway_id" \
    --name "$resource_config_name" \
    --region "$aws_region")

resource_config_id=$(echo "$create_config_response" | jq -r '.id')

echo "Step 4: Create the Resource Share"
echo
echo "Executing: aws ram create-resource-share \
    --principals "$resource_consumer_aws_account_id" \
    --resource-arns "arn:aws:vpc-lattice:$aws_region:$resource_owner_aws_account_id:resourceconfiguration/$resource_config_id" \
    --name "$resource_share_name" \
    --region "$aws_region""
echo    
read -p "Press any key to continue... " -n1 -s
echo
aws ram create-resource-share \
    --principals "$resource_consumer_aws_account_id" \
    --resource-arns "arn:aws:vpc-lattice:$aws_region:$resource_owner_aws_account_id:resourceconfiguration/$resource_config_id" \
    --name "$resource_share_name" \
    --region "$aws_region"

# Final message
echo "The Neo4j resource from the $neo4j_resource_ip_addr IP address is sent as a shared resource invitation to the AWS Account: $resource_consumer_aws_account_id"
