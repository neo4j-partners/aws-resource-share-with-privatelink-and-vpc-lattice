# AWS Resource Sharing and Consumption via Resource Access Manager (RAM)

This repository provides guidance and scripts for managing **Resource Sharing** between two personas in AWS using Resource Access Manager (RAM):  
1. **Resource Owners** - Share resources from their VPCs with other AWS accounts.  
2. **Consumers** - Accept and access shared resources in their accounts.

### AWS Services Involved  
- **VPC Lattice**: Simplifies connecting, securing, and monitoring service-to-service communications across VPCs and accounts. VPC Lattice is used to create a Service Network that manages access to shared resources and ensures secure connectivity.  
- **PrivateLink**: Enables secure access to services in a shared VPC over the AWS private network. This is used to create private endpoints in the Consumer’s VPC, allowing seamless access to shared resources.  


![alt text](https://raw.githubusercontent.com/neo4j-partners/aws-resource-share-with-privatelink-and-vpc-lattice/9d9d02fb262f7099631e8ee54bc8551e04f0d2f5/AWS_Neo4j_share_Resoiurces.jpg?token=GHSAT0AAAAAAC2Q5VVACBFVWRVJGSHPL3LIZZ75R5A)
---

## Overview  

### Personas  
- **Resource Owners**: Share resources from their VPCs with Consumers.  
- **Consumers**: Accept shared resources and access them from their accounts.  

### Key Steps for Resource Owners - setup-shared-resource-owner.sh
1. **Resource-Gateway**: Acts as a hub for sharing resources in the VPC. Multiple resources can be shared through a single gateway.  
2. **Resource-Configuration**: Defines the resource to be shared (e.g., IP address or domain name).  
   - **Single**: A standalone configuration for one resource.  
   - **Group**: A collection of multiple resource configurations.  
   - **Child**: Exists only as part of a Group configuration.  
3. **Sharing via RAM**: Invite a Consumer account to access shared resources using Resource Access Manager.  

### Key Steps for Consumers  - setup-shared-resource-consumer.sh
1. **Accept the Resource-Share**: Accept the Resource Owner's invitation in RAM.  
2. **Discover Shared Resources**: Validate the shared resources available.  
3. **Create a Service Network**: Organize and manage shared resources.  
4. **Associate Resources to Service Network**: Add Resource-Configurations to the Service Network.  
5. **Service Network Endpoint**: Create an endpoint in the Consumer's VPC for accessing shared resources.  
6. **Domain Name Construction**: Generate a domain name to access resources via the Service Network.

---
