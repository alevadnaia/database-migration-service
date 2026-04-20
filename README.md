# Android Management API MCP Extension

The Android Management API MCP extension enables AI agents to programmatically
access enterprise mobility data. It allows for natural language queries about
device fleets, automated auditing of policy compliance, and the integration of
device management data into broader automated workflows.

## Why use the Android Management API MCP server?

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
    [Android Management API](https://console.cloud.google.com/marketplace/product/google/androidmanagement.googleapis.com)
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
gemini extensions install https://github.com/gemini-cli-extensions/android-management-api
```

## Available tools

To see a complete list of available tools and their schemas, see the
[Android Management API MCP reference](https://developers.google.com/android/management/reference/mcp).

## Sample use cases

The following are sample use cases for the Android Management API MCP server:

-   Natural Language Queries: Ask complex questions about your device fleet
    without writing code—for example, "Which of my devices are not compliant
    with the latest security patch?"
-   Automated Audits: Periodically fetch data and compile reports on device
    status and policy adherence.
-   Intelligent Alerting: Monitor fleet data to flag anomalies or potential
    issues based on real-time insights.

### Sample prompts

You can use the following sample prompts to get information about Android
Management API resources:

-   List the devices in enterprise `ENTERPRISE_ID`.
-   Get details for device `DEVICE_ID` in enterprise `ENTERPRISE_ID`.
-   Show the policy details for policy `POLICY_NAME`.
-   Which applications are available in enterprise `ENTERPRISE_ID`?

In the prompts, replace the following:

-   `ENTERPRISE_ID`: the resource name of the enterprise—for example,
    enterprises/LC012345.
-   `DEVICE_ID`: the resource name of the device.
-   `POLICY_NAME`: the resource name of the policy.

## Optional security and safety configurations

MCP introduces new security risks and considerations due to the wide variety of
actions that you can take with MCP tools. To minimize and manage these risks,
Google Cloud offers defaults and customizable policies to control the use of MCP
tools in your Google Cloud organization or project.

For more information about MCP security and governance, see
[AI security and safety](https://docs.cloud.google.com/mcp/ai-security-safety).

## Quotas and limits

The Android Management API MCP server doesn't have its own quotas. There is no
limit on the number of call that can be made to the MCP server. You are still
subject to the quotas enforced by the APIs called by the MCP server tools.

## Reference and resources

*   Explore the
    [Android Management API MCP server reference documentation](https://developers.google.com/android/management/reference/mcp),
    which includes a list of all available tools, and the full input and output
    schema for each tool.
*   See the
    [Android Management API overview](https://developers.google.com/android/management).
*   Learn about
    [MCP security and governance](https://docs.cloud.google.com/mcp/ai-security-safety).
