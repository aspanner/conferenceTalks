# Welcome to Lab 3
In this lab things get a lot more sophisticated, we'll 
* use the CLI only
* build an agent during the first bootC OS image boot process
* create a systemd unit file representing the agent service and starting it
* show agent log messages
* create an iso file
* boot that iso file and install the OS
* startup and test the vm and that everything is working as expected.

The instructions and screenshots are from a Fedora 41 environment

## Context
In edge environments agents (not the AI ones) are quite common pattern. 
From GitOps ([ArgoCD agent](https://argocd-agent.readthedocs.io/)) to Edge Fleet Management ([Avassa Edge Enforcer](https://avassa.io/platform/)) the agent based
approach is a way to combat the challenges of distributed environments such as:
* Network Complexity - the need for direct connections to the edge site
* Security Boundaries - NAT, firewalls and environments that are difficult to reach
* Operational Overhad - credential management and access 
* Single Points of Failure a centralized application controller creates
* Performance - centralized architecture can create a bottleneck

Red Hat's approach is [Red Hat Edge Manager](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html/edge_manager/edge-mgr-intro) and the associated upstream project [Flight Control] (https://github.com/flightctl/flightctl)

## Let's get started.
Create your project directory and then your agent subdirectory.
In order to build your container based agent we'll create a containerfile and call it Containerfile_agent
```# Use the most minimal Red Hat Universal Base Image
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Install Python using microdnf (minimal package manager)
RUN microdnf install -y python3 && \
    microdnf clean all

# Create app directory with proper permissions
RUN mkdir -p /app && \
    chmod 755 /app && \
    chown -R 1000:1000 /app

# Copy Python application code
COPY --chown=1000:1000 hello_agent.py /app/

# Set the working directory
WORKDIR /app

# Switch to non-root user
USER 1000:1000

# Run the Python agent continuously with unbuffered output
CMD ["python3", "-u", "hello_agent.py"]
```
Our containerfile has a few goodies in it we want to call out:
* It build upon the latest version of the freely available, supported Red Hat minimal ubi container image.
* It uses microdnf, a lightweigth, standalone package manager written in C to be faster and smaller than standard dnf for environments where speend and size matter
* It uses the user (uid) and group (gid) of 1000, which is usually the first non root user in Linux systems.



![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopStartupScreen2.png?raw=true)

