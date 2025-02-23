# Hello & Getting Started
The following instructions are a step by step guide to get your first hands on experience with bootC (bootable containers) or RHEL Image mode.
There is a CLI way to achieve this but for first time uses we are utilizing awesome Podman Desktop.

## First Things First
Install Podman Desktop on your Fedora, Linux, Windows or Mac machine.
A good place to start is here: https://podman-desktop.io/docs/installation

## Start Podman Desktop
If you've got everything right then starting your Podman Desktop should greet you with a screen similar to this:

![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopStartupScreen2.png?raw=true)

## Installing the bootC extension in Podman Desktop
Navigate to the 'Extension' section in Podman Desktop, click on the 'Catalog' tab and search for 'Bootable Containers' and click the 'download/install' icon.
![Install bootC extension](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopExtensionsInstalled2.png?raw=true)

## Building your first operating system iso image
Without further delay, let's get cracking to get the first operating system build underway. After all time is money the Wolf of Wallstreet once said to me - when I was young.

On the left hand side go the 2nd icon from the top (looks like a container and the tooltip reads 'Containers') and click it. On that screen then click on the top right hand side the '+ Create' button. Your screen should look like this:

![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopContainerCreate.png?raw=true)

Next, click on the button 'Containerfile or Dockerfile' and select the Containerfile you'd like to base your operating system image build up. As we are at the beginning of the lession I suggest you use the file Containerfile1 within this repository: ![Containerfile1](./Containerfile1)

Get this Containerfile onto your local machine and select it as input; your screen will then look like similar to this:
Set the configuration according to the screen below and hit 'Build'; Sitback and enjoy this moment! Your container (not OS image yet!) is building!
You should eventually see the success message as per below:

![Podman Build Completed](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/podmanbuilddone.png?raw=true)

Under images in Podman Desktop you can now see your image (in my case andreas1) freshly baked (and still warm) and tagged:

![Podman image registry](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/podmanImagesShowAndreas1.png?raw=true)

On your container image (in my case andreas1) click the Play (>) button and configure a port mapping under the Basic tab by clicking on the 'Add custom port mapping' link. Use a free Host Port (like 8080) and map it to port 80 under Container Port. This is where your httpd will be listening. Then click at the bottom the long '> Start Container' button.

![Podman image registry](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanRunImage.png?raw=true)

Explore your running image:
* What's the containers IP address?
* How do I login?
* Can I access the terminal without login?
* Where is my index.php file I created?
* Can I curl my webserver?

Once your excitement and associated pulse rate is coming down it might be time for your to start building an operating system instance from your container image.

In order to build your OS image go to the 'Bootable Containers' Extension at the bottom left and make the configurations as per the screenshot items marked in red:

* Select the previously created container image
* Select and output folder the OS image will be built into
* Select the image you'd like to create (I've selected an iso image)
* Add users and ssh keys

![Podman image registry](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanBuildOSImageConfig.png?raw=true)

Then hit the build button and observe what happens.
* What are you observing?
* How long does the OS image build take compared to the container image build?


![Podman Operating System Build successful!](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanOSImageBuildSuccessfully.png?raw=true)


Once you see the final 'manifest - finished successfully' message you should find your freshly baked iso image in the folder you specified. In order to test you can either:
a) Copy the iso onto a bootable USB stick and boot from the USB or
b) Boot a virtual machine up with that created 'install.iso' file


# Now let's test it!
We are now going to test our newly created Fedora Operating System which we built based on a Containerfile and a bootc container image.

## First we create a virtual machine via a hypervisor (here KVM on my Fedora 41 laptop)
![Virtual Machine configuration with KVM via Cockpit](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/FedoraVMCreation.png?raw=true)

## Then observe your new Fedora instance booting up and configuring itself:
![Fedora booting](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/FedoraIsoBooting.png?raw=true)

and auto configuring...
![Fedora auto configuration](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/FedoraInstalling2.png?raw=true)

...and finally up and running!
![Fedora up and Running!](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/FedoraHttpdRunning.png?raw=true)

# Congratulations!
You have now completed the journey from creating a containerfile, built a container and subsequently built an Operating system originating from the very same Containerfile!

Feel Proud and let's move to the next exercise...

