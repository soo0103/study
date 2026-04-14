# Scale Your App

# **Running Multiple Instances of Your App**

## Scaling an application

> *You can create from the start a Deployment with multiple instances using the --replicas parameter for the kubectl create deployment command*
> 
- Previously we created a Deployment, and then exposed it publicly via a Service
- The Deployment created only one Pod for running our application
- When traffic increases, we will need to scale the application to keep up with user demand

⇒ Scaling is accomplished by changing the number of replicas in a Deployment

## Scaling overview

![module_05_scaling2.svg](Scale%20Your%20App/module_05_scaling2.svg)

> *Scaling is accomplished by changing the number of replicas in a Deployment*
> 
- Scaling out a Deployment will ensure new Pods are created and scheduled to Nodes with available resources
- Scaling will increase the number of Pods to the new desired state
- Scaling to zero is also possible, and it will terminate all Pods of the specified Deployment

- Running multiple instances of an application will require a way to distribute the traffic to all of them
- Services have an integrated load-balancer that will distribute network traffic to all Pods of an exposed Deployment
- Services will monitor continuously the running Pods using endpoints, to ensure the traffic is sent only to available Pods

- Once you have multiple instances of an application running, you would be able to do Rolling updates without downtime

### Scaling a Deployment

- To list Deployments, use the `get deployments` subcommand
    
    ```bash
    kubectl get deployments
    ```
    
- We should have 1 Pod
- This shows
    - *NAME* lists the names of the Deployments in the cluster
    - *READY* shows the ratio of CURRENT/DESIRED replicas
    - *UP-TO-DATE* displays the number of replicas that have been updated to achieve the desired state
    - *AVAILABLE* displays how many replicas of the application are available to your users
    - *AGE* displays the amount of time that the application has been running

- To see the ReplicaSet created by the Deployment, run
    
    ```bash
    kubectl get rs
    ```
    
- Notice that the name of the ReplicaSet is always formatted as [DEPLOYMENT-NAME]-[RANDOM-STRING]
- The random string is randomly generated and uses the pod-template-hash as a seed
- Two important columns of this output are
    - *DESIRED* displays the desired number of replicas of the application, which you define when you create the Deployment
        
        ⇒ This is the desired state
        
    - *CURRENT* displays how many replicas are currently running

- Next, let’s scale the Deployment to 4 replicas
- Use the `kubectl scale` command, followed by the Deployment type, name and desired number of instances
    
    ```bash
    kubectl scale deployments/kubernetes-bootcamp --replicas=4
    ```
    
- To list Deployments once again, use `get deployments`
    
    ```bash
    kubectl get deployments
    ```
    
- This change was applied, and we have 4 instances of the application available
- Next, check if the number of Pods changed
    
    ```bash
    kubectl get pods -o wide
    ```
    
- There are 4 Pods now, with different IP addresses
- The change was registered in the Deployment events log
- To check that, use the `describe` subcommand
    
    ```bash
    kubectl describe deployments/kubernetes-bootcamp
    ```
    

### Load Balancing

- To find out the exposed IP and Port, use `describe service`
    
    ```bash
    kubectl describe services/kubernetes-bootcamp
    ```
    
- Create an environment variable called NODE_PORT that has a value as the Node Port
    
    ```bash
    export NODE_PORT="$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')"
    echo NODE_PORT=$NODE_PORT
    ```
    
- Do a `curl` to exposed IP address and port
- Execute the command multiple times
    
    ```bash
    curl http://"$(minikube ip):$NODE_PORT"
    ```
    
- This demonstrates that the load-balancing is working

### Scale Down

- To scale down the Deployment to 2 replicas, run agin the `scale` subcommand
    
    ```bash
    kubectl scale deployments/kubernetes-bootcamp --replicas=2
    ```
    
- List the Deployments to check if the cahnge was applied with the `get deployments` subcommand
    
    ```bash
    kubectl get deployments
    ```
    
- The number of  replicas decreased to 2
- List the number of Pods, with `get pods`
    
    ```bash
    kubectl get pods -o wide
    ```