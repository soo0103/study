# Create a Cluster

# Create a Cluster

## Kubernetes Clusters

> *Kubernetes is a production-grade, open-source platform that orchestrates the placement (scheduling) and execution of application containers within and across computer clusters*
> 
- Kubernetes coordinates a highly available cluster of computers that are connected to work as a single unit
- The abstractions in Kubernetes allow you to deploy containerized applications to a cluster without tying them specifically to individual machines
- To make use of this new model of deployment, applications need to be packaged in a way that decouples them from individual hosts: they need to be containerized
    - Containerized applications are more flexible and available than in past deployment models, where applications were installed directly onto specific machines as packages deeply integrated into the host
- Kubernetes automates the distribution and scheduling of application containers across a cluster in a more efficient way

- Kubernetes cluster consists of two types of resources
    - The **Control Plane** coordinates the cluster
    - **Nodes** are the workers that run applications

## Cluster Diagram

![image.png](Create%20a%20Cluster/image.png)

- Control Plane
    - The Control Plane is responsible for managing the cluster
    - coordinate all activites in cluster
        - scheduling applications
        - maintaining applications’ desired stae
        - scaling applications
        - rolling out new updates
    
    > *Control Planes manage the cluster and the nodes that are used to host the running applications.*
    > 
- Node
    - A node is a VM or a physical computer that serves as a worker machine in a Kubernetes cluster
    - Each node has a Kubelet, which is an agent for managing the node and communicating with the Kubernetes control plane
    - The node should also have tools for handling container operations, such as containerd or CRI-O
    
    ⇒ A Kubernetes cluster that handles production traffic should have a minimum of three nodes
    
    - If one node goes down, both an etcd member and a control plane instance are lost, and redundancy is compromised
- When you deploy applications on Kubernetes, you tell the control plane to start the application containers
- The control plane schedules the containers to run on the cluster's nodes
- Node-level components, such as the kubelet, communicate with the control plane using the Kubernetes API, which the control plane exposes
- End users can also use the Kubernetes API directly to interact with the cluster