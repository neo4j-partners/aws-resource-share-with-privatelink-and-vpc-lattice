# AWS Resource Sharing and Consumption via Resource Access Manager (RAM)

This repository provides guidance and scripts for managing **Resource Sharing** between two personas in AWS using Resource Access Manager (RAM):  
1. **Resource Owners** - Share resources from their VPCs with other AWS accounts.  
2. **Consumers** - Accept and access shared resources in their accounts.

---

## Overview  

### Personas  
- **Resource Owners**: Share resources from their VPCs with Consumers.  
- **Consumers**: Accept shared resources and access them from their accounts.  

### Key Steps for Resource Owners  
1. **Resource-Gateway**: Acts as a hub for sharing resources in the VPC. Multiple resources can be shared through a single gateway.  
2. **Resource-Configuration**: Defines the resource to be shared (e.g., IP address or domain name).  
   - **Single**: A standalone configuration for one resource.  
   - **Group**: A collection of multiple resource configurations.  
   - **Child**: Exists only as part of a Group configuration.  
3. **Sharing via RAM**: Invite a Consumer account to access shared resources using Resource Access Manager.  

### Key Steps for Consumers  
1. **Accept the Resource-Share**: Accept the Resource Owner's invitation in RAM.  
2. **Discover Shared Resources**: Validate the shared resources available.  
3. **Create a Service Network**: Organize and manage shared resources.  
4. **Associate Resources to Service Network**: Add Resource-Configurations to the Service Network.  
5. **Service Network Endpoint**: Create an endpoint in the Consumer's VPC for accessing shared resources.  
6. **Domain Name Construction**: Generate a domain name to access resources via the Service Network.

---
