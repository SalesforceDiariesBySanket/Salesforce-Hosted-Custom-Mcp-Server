# Salesforce Hosted Custom MCP Server

This repository contains Salesforce Model Context Protocol (MCP) Server definitions, External Service Registrations, and related Apex Classes for building and deploying custom MCP servers on Salesforce.

## Overview

This project demonstrates how to:
- Define custom MCP servers in Salesforce
- Create External Service Registrations to expose Apex methods and APIs
- Build Aura-enabled Apex classes for agent integration
- Integrate prompt templates with MCP tools
- Leverage Flow, REST APIs, Named Queries, and Invocable Apex

## Repository Structure

### MCP Server Definitions
Metadata files that define Model Context Protocol servers in Salesforce.

### External Service Registrations
Definitions for exposing Salesforce services to external MCP clients.

### Apex Classes
Core implementation classes for MCP tools.

### Prompt Templates
GenAI prompt templates for content generation.

## Key Concepts

### MCP Server Definition
A metadata type that defines which tools and resources are available through a Model Context Protocol server.

### External Service Registration
Connects Salesforce to external APIs or services by defining schemas and operations.

### Apex MCP Tools
Methods exposed as MCP tools for Agentforce agents via @AuraEnabled or @InvocableMethod annotations.

## Getting Started

See GETTING_STARTED.md for detailed setup instructions.

## Deployment

```bash
sfdx force:source:deploy -p . -u myorg
```

## Resources

- [Salesforce MCP Documentation](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/)
- [Agentforce Developer Guide](https://developer.salesforce.com/docs/ai/agentforce/)
- [External Service Registrations](https://developer.salesforce.com/docs/platforms/Connect/concepts/external-service-registrations.htm)

## Author

Salesforce Diaries by Sanket
