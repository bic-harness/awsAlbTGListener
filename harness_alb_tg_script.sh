#set AWS credentials and defaults for authentication and config
#below credentials need to be adjusted with the corresponding secret names from your Harness Secrets
export AWS_ACCESS_KEY_ID=${secrets.getValue('your_access_key_here')}
export AWS_SECRET_ACCESS_KEY=${secrets.getValue('your_secret_access_key_here')}
export AWS_DEFAULT_REGION="your_desired_region_here"

#set initial variables for the ALB configuration & config
alb_arn=$(aws elbv2 describe-load-balancers --names ${workflow.variables.loadBalancer} --query 'LoadBalancers[*].LoadBalancerArn | [0]' --output text)
albsch=$(aws elbv2 describe-load-balancers --names ${workflow.variables.loadBalancer} --query 'LoadBalancers[*].Scheme | [0]' --output text)
tgs=$(aws elbv2 describe-target-groups --load-balancer-arn $alb_arn --query 'TargetGroups[*].TargetGroupName | []' --output text) 
vpcn=$(aws elbv2 describe-load-balancers --load-balancer-arns $alb_arn --query 'LoadBalancers[*].VpcId' --output text)
listeners=$(aws elbv2 describe-listeners --load-balancer-arn $alb_arn --query 'Listeners[*].ListenerArn | []' --output text)
countertg=0
counterls=0
ctg=0
cls=0

#set internal/external for target group name
if [[ "$albsch" == "internal" ]]; then
    tgn="tgt-${service.name}-internal"
else
    if [[ "$albsch" == "internet-facing" ]]; then
        tgn="tgt-${service.name}-external"
    fi
fi

#setting up the counter for the number of target groups attached to the load balancer
for tg in $tgs
do
    countertg=$(( countertg+1 ))
done

#setting up the counter for the number of listener rules in the load balancer
for listener in $listeners
do
    counterls=$(( counterls+1 ))
done
#verifying that the target group doesn't exist already and creating it if it doesn't exist
#this applies for the corresponding listener rule as well
for tg in $tgs
do
   ctg=$(( ctg+1 ))
   if [[ "$tg" == "$tgn" ]]; then
        echo "$tg exists, going to leverage the target group for the deployment."
        tg_arn=$(aws elbv2 describe-target-groups --names $tg --query 'TargetGroups[*].TargetGroupArn | []' --output text)
   else
        if [[ $ctg == $countertg ]]; then
            echo "$tgn does not exist. Creating it..."
            tg_arn=$(aws elbv2 create-target-group --name $tgn --protocol HTTP --port 80 --target-type instance --vpc-id $vpcn | jq -r '.TargetGroups[].TargetGroupArn')
            echo "Target Group ARN is $tg_arn"
            echo "$tgn created successfully."
            echo "Now checking listeners."
            #similar approach for identifying the listener is applied
            for listener in $listeners
            do
                cls=$(( cls+1 ))
                port=$(aws elbv2 describe-listeners --listener-arns $listener --query 'Listeners[*].Port' --output text)
                if [[ "${workflow.variables.servicePort}" == "$port" ]]; then
                    echo "Found the corresponding listener, adjusting rule to include new target group."
                    aws elbv2 create-rule --actions Type=forward,TargetGroupArn=$tg_arn --listener-arn $listener --conditions Field=path-pattern,Values="/${service.name}*" --priority 1
                    break
                else
                    if [[ $cls == $counterls ]]; then
                        echo "No corresponding rule found for this port. Creating new listener."
                        aws elbv2 create-listener --load-balancer-arn $alb_arn --protocol HTTP --port ${workflow.variables.servicePort} --default-actions Type=forward,TargetGroupArn=$tg_arn
                    fi
                fi
            done
        fi
   fi
done

#exporting the identified ARNs for the ALB and TG that will help in configuring the service setup
export ALB_ARN=$alb_arn
export TG_ARN=$tg_arn