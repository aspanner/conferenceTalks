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



![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopStartupScreen2.png?raw=true)

