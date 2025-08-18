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
### Building the agent
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

Now let's look at our agent code as well, we'll call it 'hello_agent.py'. As you can see in the Containerfile above we are using python3 to run the agent script in unbuffered ("-u") mode so that the output appears immediately on stdout.

```
#!/usr/bin/env python3
"""
Management Agent for Immutable bootC Operating System
Optimized for telemetry and lifecycle management tasks
"""

import time
import sys
import datetime
import json
import os
from pathlib import Path


class ManagementAgent:
    """A management agent for immutable OS environments."""
    
    def __init__(self, interval=30):
        self.interval = interval
        self.start_time = datetime.datetime.now()
        self.message_count = 0
        
    def log_message(self, message, level="INFO"):
        """Log a timestamped message."""
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] [{level}] {message}", flush=True)
        sys.stdout.flush()
        
    def get_system_info(self):
        """Gather basic system information."""
        return {
            "uptime": str(datetime.datetime.now() - self.start_time),
            "message_count": self.message_count,
            "python_version": sys.version.split()[0],
            "container_user": os.getenv("USER", "unknown")
        }
        
    def run_management_cycle(self):
        """Execute one management cycle."""
        self.message_count += 1
        
        # Core messaging
        self.log_message("----------\n Hello, World! Management Agent running on immutable bootC OS")
        self.log_message("I am optimized for telemetry and lifecycle management tasks")
        self.log_message("OS changes should be made via Containerfile/build process updates")
        self.log_message("Immutable infrastructure ensures consistency and reliability")
        
        # System status
        info = self.get_system_info()
        self.log_message(f"Agent uptime: {info['uptime']}")
        self.log_message(f"Messages sent: {info['message_count']}")
        
        # Lifecycle management status
        self.log_message("Performing lifecycle health check... OK")
        self.log_message("Telemetry collection active and operational")
        
    def run(self):
        """Main agent loop."""
        self.log_message("Management Agent starting up...")
        self.log_message(f"Configured interval: {self.interval} seconds")
        
        try:
            while True:
                self.run_management_cycle()
                time.sleep(self.interval)
        except KeyboardInterrupt:
            self.log_message("Shutdown signal received", "WARN")
        except Exception as e:
            self.log_message(f"Error in management cycle: {e}", "ERROR")
            raise


if __name__ == "__main__":
    # Configure from environment or use defaults
    interval = int(os.getenv("AGENT_INTERVAL", "30"))
    
    agent = ManagementAgent(interval=interval)
    agent.run()
```
Now let's build the agent with `podman build -t edge-agent-ubi:v1 -f Containerfile_agent .`
I've created a container repo on quay.io called "edge-agent" and I am pushing the agent container we've just built to it via `podman push localhost/edge-agent-ubi:v1 quay.io/aspanner/edge-agent:v1`.

If everything went right you should now see your agent container image in your container registry:
![Quay.io container registry showing the agent container](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/QuayAgentImage.png?raw=true)






#Other




