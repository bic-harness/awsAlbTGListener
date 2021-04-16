# awsAlbTGListener

##### Repository that contains a script for Harness to automate the creation of Target Groups, Listeners and Listener rules based on the ALB setup and naming convention.

The script should be leveraged as a Shell Script step in your Harness Workflow, before the **ECS Service Setup** step as the `ALB_ARN` and the `TG_ARN` Environment Variables will be utilized by that step.

#### How To Use

1. Replace the AWS Access & Secret keys placeholders with corresponding Secret Names from your Harness Secrets Manager. 
1. Specify the desired AWS Region instead of it's placeholder.
1. Add a Shell Script step to your workflow and paste the adjusted script there.
1. Add the below Script Outputs to the Shell Script step.
1. Ensure the **Publish output in the context** checkbox is ticket and that you use **arns** as the variable name and select **Workflow** as the context.
1. Add the two Workflow Variables mentioned below to your Workflow and ensure they are populated accordingly when triggering the deployment.
1. Open the `ECS Service Setup` step and use `${context.arns.ALB_ARN}` as the **Elastic Load Balancer** and `${context.arns.TG_ARN}` as the **Target Group**.
1. That's it!

#### Outputs 

Output Name | Description
------------ | -------------
ALB_ARN | Should be used **as is**. This output will contain the ALB ARN that is identified from the script. This output maps to the `${context.arns.ALB_ARN}` variable mentioned above in the `ECS Service Setup` Workflow step.
TG_ARN| Should be used **as is**. This output will contain the Target Group ARN that is identified from the script. This output maps to the `${context.arns.TG_ARN}` variable mentioned above in the `ECS Service Setup` Workflow step.

#### Utilized Variables

Variable Name | Description
------------ | -------------
AWS Access Key ID | This should be used instead of the placeholder in the `${secrets.getValue('your_access_key_here')}` variable. It is required for authenticating to AWS.
AWS Secret Access Key | This should be used instead of the placeholder in the `${secrets.getValue('your_secret_access_key_here')}` variable. It is required for authenticating to AWS.
AWS Region | This should be used instead of the placeholder in this section `export AWS_DEFAULT_REGION="your_desired_region_here"` to allow configuration of the AWS environment.
loadBalancer | This variable should be used **as is** and should be set as a Workflow Variable for your Harness workflow. This is leveraged as `${workflow.variables.loadBalancer}` throughout the script. This will be the **name** of the load balancer that will be used throughout the deployment.
servicePort | This variable should be used **as is** and should be set as a Workflow Variable for your Harness workflow. This is leveraged as `${workflow.variables.servicePort}` throughout the script. This will be the **service port** that the deployed service will be leveraging.
service.name | This variable should be used **as is**. It is a Harness specific variable that will be replaced with the name of the service that will be deployed in the workflow.
