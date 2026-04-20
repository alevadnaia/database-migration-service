# Database Migration Service Managed MCP Extension

> **Preview:** This product is subject to the "Pre-GA Offerings Terms" in the
> General Service Terms section of the
> [Service Specific Terms](https://docs.cloud.google.com/terms/service-terms#1).
> Pre-GA products and features are available "as is" and might have limited
> support. For more information, see the
> [launch stage descriptions](https://cloud.google.com/products#product-launch-stages).

The Database Migration Service managed MCP extension lets you manage migration
jobs from your AI application. You can start, stop, resume, or delete migration
jobs with Database Migration Service remote MCP server.

## Why use the Database Migration Service managed MCP server?

Google and Google Cloud
[managed MCP servers](https://docs.cloud.google.com/mcp/overview) can be used in
your AI applications with enterprise-ready governance, security, and access
control.

## Before you begin

1.  In the Google Cloud console, on the
    [project selector page](https://console.cloud.google.com/projectselector2/home/dashboard),
    select or create a Google Cloud project.

    > **Note**: If you don't plan to keep the resources that you create in this
    > procedure, create a project instead of selecting an existing project.
    > After you finish these steps, you can delete the project, removing all
    > resources associated with the project.

2.  Get your administrator to grant you the
    [MCP Tool User role](https://docs.cloud.google.com/iam/docs/roles-permissions/mcp#mcp.toolUser)
    (`roles/mcp.toolUser`) on the Google Cloud project. If you created a new
    project, then you already have the required permissions.

3.  Ensure your administrator has enabled the
    [Database Migration Service API](https://console.cloud.google.com/marketplace/product/google/datamigration.googleapis.com)
    on the Google Cloud project.

## Configure authentication

This extension uses Google Application Default Credentials (ADC) to perform
authentication. To login with ADC, run the following command in your terminal:

```bash
gcloud auth application-default login
```

For additional details, see the
[ADC documentation](https://docs.cloud.google.com/docs/authentication/application-default-credentials#personal).

## Install the extension

To install the extension, run the following command in your terminal:

```bash
gemini extensions install https://github.com/gemini-cli-extensions/database-migration-service
```

## Available tools

To see a complete list of available tools and their schemas, see the
[Database Migration Service MCP reference](https://docs.cloud.google.com/database-migration/docs/reference/mcp).

## Sample use cases

The following are example use cases for the Database Migration Service MCP
server:

-   List, get, start, and delete migration jobs in your project.
-   List static IP addresses that Database Migration Service connects from to
    your source database during heterogeneous migrations.
-   Use the get_operation tool to poll the status of operations such as starting
    or deleting a migration job.

### Sample prompts

-   List all running migration jobs in project `PROJECT_ID` and location
    `LOCATION`.
-   List all migration jobs that encountered errors in project `PROJECT_ID` and
    location `LOCATION`.
-   What's the status of the migration job `MIGRATION_JOB_ID` in `LOCATION`?
-   Stop the migration job `MIGRATION_JOB_ID` in `LOCATION`.
-   Resume all stopped migration jobs `MIGRATION_JOB_ID` in `LOCATION`.

In the prompts, replace the following:

-   `PROJECT_ID` with your Google Cloud project identifier.
-   `LOCATION` with the location of the migration job.
-   `MIGRATION_JOB_ID` with your Database Migration Service migration job
    identifier.

## Optional security and safety configurations

MCP introduces new security risks and considerations due to the wide variety of
actions that you can take with MCP tools. To minimize and manage these risks,
Google Cloud offers defaults and customizable policies to control the use of MCP
tools in your Google Cloud organization or project.

For more information about MCP security and governance, see
[AI security and safety](https://docs.cloud.google.com/mcp/ai-security-safety).

## Quotas and limits

The Database Migration Service MCP server doesn't have its own quotas. There is
no limit on the number of call that can be made to the MCP server. You are still
subject to the quotas enforced by the APIs called by the MCP server tools.

## Reference and resources

*   Explore the
    [Database Migration Service remote MCP server reference documentation](https://docs.cloud.google.com/database-migration/docs/reference/mcp),
    which includes a list of all available tools, and the full input and output
    schema for each tool.
*   See the
    [Database Migration Service overview](https://docs.cloud.google.com/database-migration/docs).
*   Learn about
    [MCP security and governance](https://docs.cloud.google.com/mcp/ai-security-safety).
