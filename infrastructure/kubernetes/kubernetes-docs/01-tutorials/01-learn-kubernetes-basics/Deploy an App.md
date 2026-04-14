# Deploy an App

# **Using kubectl to Create a Deployment**

## kubernetes Deployments

> *A Deployment is responsible for creating and updating instances of your application*
> 
- Once you have a running Kubernetes cluster, you can deploy your containerized applications on top of it
    - To do so, you create a Kubernetes Deployment
- Once you've created a Deployment, the Kubernetes control plane schedules the application instances included in that Deployment to run on individual Nodes in the cluster

- Once the application instances are created, a Kubernetes Deployment controller continuously monitors those instances
- If the Node hosting an instance goes down or is deleted, the Deployment controller replaces the instance with an instance on another Node in the cluster

⇒ This provides a self-healing mechanism to address machine failure or maintenance

- By both creating your application instances and keeping them running across Nodes, Kubernetes Deployments provide a fundamentally different approach to application management

## Deploying your first app on Kubernetes

> *Applications need to be packaged into one of the supported container formats in order to be deployed on Kubernetes*
> 

![image.png](Deploy%20an%20App/image.png)

- You can create and manage a Deployment by using the Kubernetes command line interface, kubectl
- `kubectl` uses the Kubernetes API to interact with the cluster

- When you create a Deployment, you'll need to specify the container image for your application and the number of replicas that you want to run
- You can change that information later by updating your Deployment

### kubectl basics

- The common format of a kubectl command is: kubectl action resource
- This performs the specified action (like `create`, `describe` or `delete`) on the specified resource (like `node` or `deployment`You can use `--help` after the subcommand to get additional info about possible parameters (for example: `kubectl get nodes --help`)
- Check that kubectl is configured to talk to your cluster, by running the kubectl version command
- Check that kubectl is installed and that you can see both the client and the server versions
- To view the nodes in the cluster, run the `kubectl get nodes` command
    - You see the available nodes
    - Later, Kubernetes will choose where to deploy our application based on Node available resources

### Deploy an app

- Let’s deploy our first app on Kubernetes with the `kubectl create deployment` command
- We need to provide the deployment name and app image location (include the full repository url for images hosted outside Docker Hub)
    
    ```bash
    kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
    ```
    
- This performed a few things
    - searched for a suitable node where an instance of the application could be run
    - scheduled the application to run on that Node
    - configured the cluster to reschedule the instance on a new Node when needed
- To list deployments, use the `kubectl get deployments` command
    
    ```bash
    kubectl get deployments
    ```
    

### View the app

- Pods that are running inside Kubernetes are running on a private, isolated network
- By default they are visible from other pods and services within the same Kubernetes cluster, but not outside that network
- When we use kubectl, we're interacting through an API endpoint to communicate with our application
- The kubectl proxy command can create a proxy that will forward communications into the cluster-wide, private network
- The proxy can be terminated by pressing control-C and won't show any output while it's running
    
    ```bash
    kubectl proxy
    ```
    
- We now have a connection between our host (the terminal) and the Kubernetes cluster
- The proxy enables direct access to the API from these terminals
- You can see all those APIs hosted through the proxy endpoint
    - For example, we can query the version directly through the API using the curl command
        
        ```bash
        curl http://localhost:8001/version
        ```
        
- The API server will automatically create an endpoint for each pod, based on the pod name, that is also accessible through the proxy
- First we need to get the Pod name, and we'll store it in the environment variable `POD_NAME`
    
    ```bash
    export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
    echo Name of the Pod: $POD_NAME
    ```
    
- You can access the Pod through the proxied API, by running
    
    ```bash
    curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME:8080/proxy/
    ```