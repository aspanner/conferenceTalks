# Hello & Getting Started
The following instructions are a step by step guide to get your first hands on experience with bootC (bootable containers) or RHEL Image mode.
There is a CLI way to achieve this but for first time uses we are utilizing awesome Podman Desktop.

## First Things First
Install Podman Desktop on your Fedora, Linux, Windows or Mac machine.
A good place to start is here: https://podman-desktop.io/docs/installation

## Start Podman Desktop
If you've got everything right then starting your Podman Desktop should greet you with a screen similar to this:

![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopStartupScreen2.png?raw=true)

##Building your first operating system iso image
Without further delay, let's get cracking to get the first operating system build underway. After all time is money the Wolf of Wallstreet once said to me - when I was young.

On the left hand side go the 2nd icon from the top (looks like a container and the tooltip reads 'Containers') and click it. On that screen then click on the top right hand side the '+ Create' button. Your screen should look like this:

![Podman Desktop Startup Screen](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/PodmanDesktopContainerCreate.png?raw=true)

Next, click on the button 'Containerfile or Dockerfile' and select the Containerfile you'd like to base your operating system image build up. As we are at the beginning of the lession I suggest you use the file Containerfile1 within this repository: ![Containerfile1](./Containerfile1)

Get this Containerfile onto your local machine and select it as input; your screen will then look like similar to this:
Set the configuration according to the screen below and hit 'Build'; Sitback and enjoy this moment! Your container (not OS image yet!) is building!
You should eventually see the success message as per below:

![Podman Build Completed](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/podmanbuilddone.png?raw=true)

Under images in Podman Desktop you can now see your image (in my case andreas1) freshly backed and tagged:

![Podman image registry](https://github.com/aspanner/conferenceTalks/blob/main/2025/DevConIndia/podmanImagesShowAndreas1.png?raw=true)


