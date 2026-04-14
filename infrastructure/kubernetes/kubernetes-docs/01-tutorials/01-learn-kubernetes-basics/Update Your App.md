# Update Your App

# **Perfoming a Rolling Update**

## Updating an application

> *Rolling updates allow Deployments' update to take place with zero downtime by incrementally updating Pods instances with new ones*
> 
- Users expect applications to be available all the time, and developers are expected to deploy new versions of them several times a day
- In kubernetes this is done with rolling updates
- A rolling update allows Deployment update to take place with zero downtime
- It does this by incrementally replacing the current Pods with new ones
- The neew Pods are scheduled on Nodes with available resources, and Kubernetes waits for those new Pods to start before removing the old Pods

- In the previous module we scaled our applicaation to run multiple instances
- This is a requirement for performing updates without affecting application availability
- By default, the maximum number of Pods that can be unavailable during the update  and the maximum numbers or percentages (of Pods)
- In Kubernetes, updates are versioned an any Dpeployment update can be reverted to a previous (stable) version

## Rolling updates overview

![module_06_rollingupdates4.svg](Update%20Your%20App/module_06_rollingupdates4.svg)

> 
> 
> 
> If a Deployment is publicly exposed, the Service will send traffic only to Pods that can handle requests 
> 
> This ensures users continue to access the application during an update
> 
- During a rolling update, this behavior keeps thee application available by routing traffic only to Pods that are serving requests
- Rolling updates allow the following actions
    - Promote an application from one environment to another (via container image updates)
    - Rollback to previous versions
    - Continuous Integration and Continuous Delivery of applications with zero downtime

### Update the version of the app

- To list Deployments, run the `get deployments` subcommand
    
    ```bash
    kubectl get deployments
    ```
    
- To list the running Pods, run the `get pods` subcommand
    
    ```bash
    kubectl get pods
    ```
    
- To view the current image version of the app, run the `describe pods` subcommand and look for the `Image` field
    
    ```bash
    kubectl describe pods
    ```
    
- To update the image of the application to version 2, use the `set image` subcommand, followed by the deployment name and the new image version
    
    ```bash
    kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=docker.io/jocatalin/kubernetes-bootcamp:v2
    ```
    
- The command notified the Deployment to use a different image for your app and initiated a rolling update
- Check the status of the new Pods, and view the old one terminating with the `get pods` subcommand
    
    ```bash
    kubectl get pods
    ```
    

### Verify an update

- First, check that the service is running
- If it’s missing, create it again with
    
    ```bash
    export NODE_PORT="$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')"
    echo "NODE_PORT=$NODE_PORT"
    ```
    
- Next, do a `curl` to the exposed IP and port
    
    ```bash
    curl http://"$(minikube ip):$NODE_PORT"
    ```
    
- Every time you run the `curl` command, you will hit a different Pod
- Notice that all Pods are now running the latest version(`v2`)
- You can also confirm the update by running the `rollout status` subcommand
    
    ```bash
    kubectl rollout status deployments/kubernetes-bootcamp
    ```
    
- To view the current image version of the app, run the describe pods subcommand
    
    ```bash
    kubectl describe pods
    ```
    
- In the `Image` field of the output, verify that you are running the latest image version (`v2`)

### Roll back an update

- Let’s perform another update, an try to deploy an image tagged with `v10`
    
    ```bash
    kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=gcr.io/google-samples/kubernetes-bootcamp:v10
    ```
    
- Use `get deployments` to see the status of the deployment
    
    ```bash
    kubectl get deployments
    ```
    
- Notice that some of the Pods have a status of `ImagePullBackOff`
- To get more insight into the problem, run the `describe pods` subcommand
    
    ```bash
    kubectl describe pods
    ```
    
- In the `Events` section of the output for the affected Pods, notice that the `v10` image version did not exist in the repository
- To roll back the deployment to your last working version, use the `rollout undo` subcommand
    
    ```bash
    kubectl rollout undo deployments/kubernetes-bootcamp
    ```
    
- The `rollout undo` command reverts the deployment to the previous known state(`v2` of the image)
- Updates are versioned an you can revert to any previously known state of a Deployment
- Use the `get pods` subcommand to list the Pods again
    
    ```bash
    kubectl get pods
    ```
    
- To check the image deployed on the running Pods, use the `describe pods` subcommand
    
    ```bash
    kubectl describe pods
    ```
    
- The Deployment is once again using stable version of the app(`v2`)
- The rollback was successful
- Remember to clean up your local cluster
    
    ```bash
    kubectl delete deployments/kubernetes-bootcamp services/kubernetes-bootcamp
    ```