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
Create your project directory and then your agent subdirectory. Change directory (cd) into your agent directory.
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

If everything went right you should now see your (only 53Mbyte big) agent container image in your container registry:
![Quay.io container registry showing the agent container](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/QuayAgentImage.png?raw=true)

##Building your bootC __Container__ image
The reason I highlighte container above is because to build your bootC Operating System (O/S) image it's a two step process:
1) build the container image
2) build the O/S image based off the container image

## 1) Build the container image
Move out of the agent directy in your project directory and inspect your container file for the bootC image:

```
# bootC OS Image with Python Management Agent
FROM quay.io/fedora/fedora-bootc:41

# Install container tools and Python for the host OS
RUN dnf install -y \
    podman \
    python3 \
    python3-pip \
    systemd \
    && dnf clean all

# Create a user for running containers
RUN useradd -m -G wheel bootcuser && \
    echo 'bootcuser:bootcuser' | chpasswd

# Copy the Python management agent source
COPY agent/hello_agent.py /usr/local/bin/
RUN chmod +x /usr/local/bin/hello_agent.py

# Copy the agent Containerfile for building during firstboot
COPY agent/Containerfile_agent /usr/local/share/containers/
COPY agent/hello_agent.py /usr/local/share/containers/

# Install the Quadlet service definition
COPY agent/hello-agent.container /etc/containers/systemd/

# Create a script to build the agent container on first boot
RUN echo '#!/bin/bash' > /usr/local/bin/build-agent-container.sh && \
    echo 'set -euo pipefail' >> /usr/local/bin/build-agent-container.sh && \
    echo '' >> /usr/local/bin/build-agent-container.sh && \
    echo 'echo "Building Python management agent container..."' >> /usr/local/bin/build-agent-container.sh && \
    echo 'cd /usr/local/share/containers' >> /usr/local/bin/build-agent-container.sh && \
    echo 'podman build -t quay.io/aspanner/edge-agent:v1 -f Containerfile_agent .' >> /usr/local/bin/build-agent-container.sh && \
    echo '' >> /usr/local/bin/build-agent-container.sh && \
    echo 'echo "Container built successfully!"' >> /usr/local/bin/build-agent-container.sh && \
    echo 'podman images | grep edge-agent-ubi' >> /usr/local/bin/build-agent-container.sh && \
    chmod +x /usr/local/bin/build-agent-container.sh

# Create a oneshot service to build the container on first boot
RUN echo '[Unit]' > /etc/systemd/system/build-agent-container.service && \
    echo 'Description=Build Python Management Agent Container' >> /etc/systemd/system/build-agent-container.service && \
    echo 'After=network-online.target podman.service' >> /etc/systemd/system/build-agent-container.service && \
    echo 'Wants=network-online.target' >> /etc/systemd/system/build-agent-container.service && \
    echo 'Before=edge-agent.service' >> /etc/systemd/system/build-agent-container.service && \
    echo 'ConditionPathExists=!/var/lib/containers/agent-built' >> /etc/systemd/system/build-agent-container.service && \
    echo '' >> /etc/systemd/system/build-agent-container.service && \
    echo '[Service]' >> /etc/systemd/system/build-agent-container.service && \
    echo 'Type=oneshot' >> /etc/systemd/system/build-agent-container.service && \
    echo 'ExecStart=/usr/local/bin/build-agent-container.sh' >> /etc/systemd/system/build-agent-container.service && \
    echo 'ExecStartPost=/bin/touch /var/lib/containers/agent-built' >> /etc/systemd/system/build-agent-container.service && \
    echo 'RemainAfterExit=yes' >> /etc/systemd/system/build-agent-container.service && \
    echo 'User=root' >> /etc/systemd/system/build-agent-container.service && \
    echo '' >> /etc/systemd/system/build-agent-container.service && \
    echo '[Install]' >> /etc/systemd/system/build-agent-container.service && \
    echo 'RequiredBy=edge-agent.service' >> /etc/systemd/system/build-agent-container.service && \
    echo 'WantedBy=multi-user.target' >> /etc/systemd/system/build-agent-container.service

# Enable the container build service (Quadlet service will be auto-enabled)
RUN systemctl enable build-agent-container.service

# Configure podman for rootless containers
RUN echo 'bootcuser:100000:65536' >> /etc/subuid && \
    echo 'bootcuser:100000:65536' >> /etc/subgid

# Create systemd user directory for bootcuser
RUN mkdir -p /home/bootcuser/.config/systemd/user && \
    chown -R bootcuser:bootcuser /home/bootcuser/.config

# Add a welcome message
RUN echo '==========================================' > /etc/motd && \
    echo '  bootC OS with Python Management Agent' >> /etc/motd && \
    echo '==========================================' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo 'This system includes:' >> /etc/motd && \
    echo '- Python Management Agent running as Quadlet' >> /etc/motd && \
    echo '- Immutable OS infrastructure' >> /etc/motd && \
    echo '- Container-based application delivery' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo 'Monitor the agent:' >> /etc/motd && \
    echo '  sudo journalctl -u edge-agent.service -f' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo 'Check agent status:' >> /etc/motd && \
    echo '  sudo systemctl status edge-agent.service' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo 'Build information available at:' >> /etc/motd && \
    echo '  /usr/local/share/containers/' >> /etc/motd && \
    echo '' >> /etc/motd && \
    echo '==========================================' >> /etc/motd

# Set the default target
RUN systemctl set-default multi-user.target
```
A few things to call out in the Containerfile.bootc are:
* We are using the fedora-bootc:41 as a base image
* The full python-based version of dnf is used
* We are using a new user and group call "bootcuser"

### Where do we get the container from?
We've just pushed the container up to our Quay.io container registry and that's where we do get it from, right? But do we? Not this time.

It  might be that in some edge environments there's no access to registries and for these occasions we show how we actually build the container in the target image via a oneshot service. In order to do so we need 2 components:
1) The container build script
2) The systemd oneshot quadlet configuration. 

Both you can see above.

The first `RUN echo` command creates the build script in `/usr/local/bin/build-agent-container.sh`. The core of that build script is `podman build -t localhost/edge-agent-ubi:v1 -f Containerfile_agent .` which is pretty much what you did before. Only this time it runs within the operating system as a oneshot systemd service, which is what the next `RUN echo` line sets up.


### Building the bootC Container in 3,2,1...
Now let's build it:
Because the following O/S image build process needs root permissions we are building the O/S image with 'sudo': `sudo podman build -t my-edge-bootc-os:v1 -f Containerfile.bootc .`

Once that is built you should see a message a long the lines of:
```
COMMIT my-edge-bootc-os:v1
--> b651c8b428d8
Successfully tagged localhost/my-edge-bootc-os:v1
b651c8b428d8cc7bc145e251e1731724bc8b436fadea363a7dcf54f3030417f9
```

### Building the iso
Converting the bootC container image into a bootable image support many different formats.
Supported image types can be found here for open source 

The bootc image builder needs elevated (sudo) privileges and this is how we build it:
```
 sudo podman run \
    --rm \
    -it \
    --privileged \
    --pull=newer \
    --security-opt label=type:unconfined_t \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    -v $(pwd)/config.toml:/config.toml:ro \
    -v $(pwd)/output:/output \
    registry.redhat.io/rhel10/bootc-image-builder:latest \
    --type iso \
    --rootfs xfs \
    --config /config.toml \
    localhost/my-edge-bootc-os:v1
```
If everything goes to plan the output should look like this:

```
[|] Disk image building step
[9 / 9] Pipeline bootiso [------------------------------------------------------------------------>] 100.00%
[3 / 3] Stage org.osbuild.implantisomd5 [--------------------------------------------------------->] 100.00%
Message: Results saved in .
```

Which leads us to the last step of this lab, building a virtual machine based on the iso we just created.
The iso is stored under <your project folder>/output/bootiso/ and is called `install.iso`.

On Fedora 4x we are using the `virt-install` command to build the virtual machine. Once you checked that the iso file got created with a 2.4Gb size and at the correct time you are now ready to build the vm:

```
 sudo virt-install \       
-n myDevConfFedoraCLIImageModevm \
--description "bootC & RHEL Image mode" \
--os-variant=fedora41 \
--ram=5048 \
--vcpus=2 \
--disk path=/var/lib/libvirt/images/myEdgeBootcOSVMdisk.img,bus=virtio,size=20 \
--graphics vnc \
--cdrom ./output/bootiso/install.iso \
--network bridge:virbr0
```









#Other




