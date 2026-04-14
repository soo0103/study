# Explore Your App

# **Viewing Pods and Nodes**

## Kubernetes Pods

> *A Pod is a group of one or more application containers (such as Docker) and includes shared storage (volumes), IP address and information about how to run them*
> 
- A Pod is a Kubernetes abstraction that represents a group of one or more application containers (such as Docker), and some shared resources for those containers
- Those resources include
    - Shared storage, as Volumes
    - Networking, as a unique cluster IP address
    - Information about how to run each container, such as the container image version or specific ports to use
- A Pod models an application-specific "logical host" and can contain different application containers which are relatively tightly coupled
- The containers in a Pod share an IP Address and port space, are always co-located and co-scheduled, and run in a shared context on the same Node

- Pods are the atomic unit on the Kubernetes platform
- When we create a Deployment on Kubernetes, that Deployment creates Pods with containers inside them (as opposed to creating containers directly)
- Each Pod is tied to the Node where it is scheduled, and remains there until termination (according to restart policy) or deletion
- In case of a Node failure, identical Pods are scheduled on other available Nodes in the cluster

### Pods overview

![module_03_pods.svg](Explore%20Your%20App/module_03_pods.svg)

> *Containers should only be scheduled together in a single Pod if they are tightly coupled and need to share resources such as disk*
> 

## Nodes

- Pod always runs on a Node
- A Node is a worker machine in Kubernetes and may be either a virtual or a physical machine, depending on the cluster
- Each Node is managed by the control plane
- A Node can have multiple pods, and the Kubernetes control plane automatically handles scheduling the pods across the Nodes in the cluster
- The control plane's automatic scheduling takes into account the available resources on each Node

- Every Kubernetes Node runs at least
    - Kubelet, a process responsible for communication between the Kubernetes control plane and the Node; it manages the Pods and the containers running on a machine.
    - A container runtime (like Docker) responsible for pulling the container image from a registry, unpacking the container, and running the application

### Nodes overview

![module_03_nodes.svg](Explore%20Your%20App/module_03_nodes.svg)

## Troubleshooting with kubectl

- The most common operations can be done with the following kubectl subcommands
    - `kubectl get` - list resources
    - `kubectl describe` - show detailed information about a resource
    - `kubectl logs` - print the logs from a container in a pod
    - `kubectl exec` - execute a command on a container in a pod
- You can use these commands to see when applications were deployed, what their current statuses are, where they are running and what their configurations are

### Check application configuration

- Use the `kubectl get` command and look for existing Pods
    
    ```bash
    kubectl get pods
    ```
    
- If no pods are running, please wait a couple of seconds and list the Pods again

- To view what containers are inside that Pod and what images are used to build those containers we run the `kubectl describe pods` command
    
    ```bash
    kubectl describe pods
    ```
    
- We see here details about the Pod’s container
    - IP address,
    - the ports used
    - a list of events related to the lifecycle of the Pod

### Show the app in the terminal

- Recall that Pods are running in an isolated, private network - so we need to proxy access to them so we can debug and interact with them
    - To do this, we'll use the kubectl proxy command to run a proxy in a second terminal
    
    ```bash
    kubectl proxy
    ```
    
- Now again, we'll get the Pod name and query that pod directly through the proxy
    - To get the Pod name and store it in the POD_NAME environment variable
        
        ```bash
        export POD_NAME="$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')"
        echo Name of the Pod: $POD_NAME
        ```
        
- To see the output of our application, run a curl request
    
    ```bash
    curl http://localhost:8001/api/v1/namespaces/default/pods/$POD_NAME:8080/proxy/
    ```
    
- The URL is the route to the API of the Pod

### Executing commands on the container

- We can execute commands directly on the container once the Pod is up and running
- For this, we use the exec subcommand and use the name of the Pod as a parameter
    
    ```bash
    kubectl exec "$POD_NAME" -- env
    ```
    
- Start a bash session in the Pod’s container
    
    ```bash
    kubectl exec -it $POD_NAME -- bash
    ```
    
- We have now an open console on the container where we run our NodeJS application
- The source code of the app is in the `server.js` file
    
    ```bash
    cat server.js
    ```
    
- You can check that the application is up by running a curl command
    
    ```bash
    curl http://localhost:8080
    ```
    
- To close your container connection, type `exit`