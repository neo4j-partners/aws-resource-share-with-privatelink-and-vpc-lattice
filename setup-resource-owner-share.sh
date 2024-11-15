#!/bin/bash

# Set up environment variables
resource_owner_aws_account_id="159878781974"
resource_consumer_aws_account_id="368395742298"
aws_region="us-west-2"
vpc_id="vpc-07327499f3628a5ae"
subnet_id="subnet-006f7e00c5aa23923"
security_group_ids="sg-0dd65de03c721b8cc"
resource_gateway_name="neo4j-owner-rgw"
neo4j_resource_ip_addr="10.0.0.221"
neo4j_port_ranges="7474-7687"
resource_config_name="neo4j-rcgf"
resource_share_name="neo4j-db-share"

# Step 1: Create the Resource Gateway
create_response=$(aws vpc-lattice create-resource-gateway \
    --vpc-identifier "$vpc_id" \
    --subnet-ids "$subnet_id" \
    --security-group-ids "$security_group_ids" \
    --name "$resource_gateway_name" \
    --region "$aws_region")

resource_gateway_id=$(echo "$create_response" | jq -r '.id')

# Step 2: Wait for Resource Gateway to become ACTIVE
status=""
while [ "$status" != "ACTIVE" ]; do
    get_response=$(aws vpc-lattice get-resource-gateway \
        --resource-gateway-identifier "$resource_gateway_id" \
        --region "$aws_region")
    status=$(echo "$get_response" | jq -r '.status')
    sleep 20
done

# Step 3: Create the Resource Configuration
create_config_response=$(aws vpc-lattice create-resource-configuration \
    --type SINGLE \
    --resource-configuration-definition "{ \"ipResource\": { \"ipAddress\": \"$neo4j_resource_ip_addr\" } }" \
    --port-ranges "$neo4j_port_ranges" \
    --protocol TCP \
    --resource-gateway-identifier "$resource_gateway_id" \
    --name "$resource_config_name" \
    --region "$aws_region")

resource_config_id=$(echo "$create_config_response" | jq -r '.id')

# Step 4: Create the Resource Share
aws ram create-resource-share \
    --principals "$resource_consumer_aws_account_id" \
    --resource-arns "arn:aws:vpc-lattice:$aws_region:$resource_owner_aws_account_id:resourceconfiguration/$resource_config_id" \
    --name "$resource_share_name" \
    --region "$aws_region"

# Final message
echo "The Neo4j resource from the $neo4j_resource_ip_addr IP address is sent as a shared resource invitation to the AWS Account: $resource_consumer_aws_account_id"
