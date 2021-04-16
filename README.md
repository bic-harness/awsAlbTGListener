# awsAlbTGListener

##### Repository that contains a script for Harness to automate the creation of Target Groups, Listeners and Listener rules based on the ALB setup and naming convention.

The script should be leveraged as a Shell Script step in your Harness Workflow, before the **ECS Service Setup** step as the `ALB_ARN` and the `TG_ARN` Environment Variables will be utilized by that step.

##### Utilized inputs

Input Name | Description
------------ | -------------
AWS Access Key ID | This should be used instead of the placeholder in the `${secrets.getValue('your_access_key_here')}` variable. It is required for authenticating to AWS.
AWS_SECRET_ACCESS_KEY| This should be used instead of the placeholder in the `${secrets.getValue('your_secret_access_key_here')}` variable. It is required for authenticating to AWS.
