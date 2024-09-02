## For installing yq :

On machine with internet access(say Machine1):

1. `sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64`
2. `scp -i "key" yq_linux_amd64 ubuntu@<Public IP>:/tmp/yq_linux_amd64`

On machine with no internet access(say Machine2):

1. `sudo mv /tmp/yq_linux_amd64 /usr/bin/yq`
2. `sudo chmod +x /usr/bin/yq`
3. `yq --version`

## For jq installation: (Not tested yet):
1. `sudo wget https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64`
2. `cp -i "key" jq_linux_amd64 ubuntu@<Public IP>:/tmp/jq_linux_amd64`

On machine with no internet access(say Machine2):
1. `sudo mv /tmp/jq_linux_amd64 /usr/bin/jq`
2. `sudo chmod +x /usr/bin/jq`
3. `jq --version`

## Installing build-essential :

**Step 1: Download the Packages on a Machine with Internet Access**
1. On a machine with internet access, update your package list: `sudo apt-get update`
2. Download the `build-essential` package and its dependencies using `apt-get` with the `--download-only` option:
   `sudo apt-get install --download-only build-essential
   `
   This will download all the necessary `.deb` files to your system's cache (usually in `/var/cache/apt/archives`).
3. Collect the downloaded `.deb` files:
    * `mkdir -p ~/build-essential-packages`
    * `sudo cp /var/cache/apt/archives/*.deb ~/build-essential-packages/`
   This will copy all the `.deb` files into the `~/build-essential-packages` directory.
4. Compress the folder containing the `.deb` files to make it easier to transfer:
    `tar -czvf build-essential-packages.tar.gz -C ~/build-essential-packages .
   `

**Step 2: Transfer the Packages to the Server**
1. Use `scp` to transfer the compressed file to your server (replace `user@server_ip:/path/to/destination` with your server details):
   `scp build-essential-packages.tar.gz user@server_ip:/path/to/destination`
2. SSH into your server and navigate to the destination directory:
   * `ssh user@server_ip`
   * `cd /path/to/destination`
3. Extract the compressed file:
   `tar -xzvf build-essential-packages.tar.gz`

**Step 3: Install the Packages on the Server**
1. Navigate to the directory containing the `.deb` files:
   `cd build-essential-packages`
2. Install all the packages using `dpkg`:
   `sudo dpkg -i *.deb`
3. If there are any missing dependencies, fix them by running:
   `sudo apt-get install -f`

If your system does not have internet access and you run apt-get install -f, it might not be able to fix the broken dependencies unless you have already downloaded the necessary packages and dependencies to your local cache or have them available in a local repository. In such cases, you would need to manually download the required packages and install them.

4. Add the current user in docker group: 
`usermod -aG docker ${USER}`

## Docker Package Installation

**Overview :** 
- **Download**: Use a machine with internet access to download Docker and its dependencies.
- **Transfer**: Move the files to the server using `scp`.
- **Install**: Use `dpkg` on the server to install the packages.

### Step 1: Download the Packages on a Machine with Internet Access**

1. **Set up Docker's apt repository:**

   On a machine with internet access, update your package list and set up Docker's apt repository:

   `sudo apt-get update`  
   `sudo apt-get install -y ca-certificates curl`  
   `sudo install -m 0755 -d /etc/apt/keyrings`  
   `sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc`  
   `sudo chmod a+r /etc/apt/keyrings/docker.asc` 

2. **Add Docker's repository to your apt sources:**
   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   ```
3. **Download the Docker packages and their dependencies:**
   `mkdir -p ~/docker-packages`  
   `cd ~/docker-packages`  
   `sudo apt-get download docker-ce docker-ce-cli containerd.io`    
    `docker-buildx-plugin`  
    `docker-compose-plugin`
    
    This will download all the necessary `.deb` files into the `~/docker-packages` directory.
4. **Compress the folder containing the `.deb` files for easy transfer:**
   `tar -czvf docker-packages.tar.gz -C ~/ docker-packages`

### Step 2: Transfer the Packages to the Server

1. **Use `scp` to transfer the compressed file to your server:**
   Replace `<ubuntu-user>@<ubuntu-ip>:~/path/to/destination` with your server details:
   `scp -i "/path/to/key" docker-packages.tar.gz <ubuntu-user>@<ubuntu-ip>:~/path/to/destination`
2. **SSH into your server and navigate to the destination directory:**
   `ssh -i "/path/to/key" <ubuntu-user>@<ubuntu-ip>`
   `cd ~/path/to/destination`
3. **Extract the compressed file:**
   `tar -xzvf docker-packages.tar.gz`

### Step 3: Install the Docker Packages on the Server

1. **Navigate to the directory containing the `.deb` files:**
   `cd docker-packages`
2. **Install all the packages using `dpkg`:**
  `sudo dpkg -i *.deb`
  3. **Fix any missing dependencies:** (Requires Internet)
   `sudo apt-get install -f`

   This will install any missing dependencies from the `.deb` files that are already present in the directory.


## How to Use a Docker Image Offline.

## Overview :
To use a Docker image offline, pull the `hello-world` image on a connected machine and save it as `hello-world.tar`. Transfer this file to the offline server, load it with `docker load -i hello-world.tar`, and then run it using `docker run hello-world`.

**1. Pre-download the `hello-world` Image**
* On a machine with internet access, pull the `hello-world` Docker image:
`docker pull hello-world`

**2. Save the Image**
Save the pulled `hello-world` image as a tar file:
* `docker save -o hello-world.tar hello-world`

**3. Transfer the Image to the Offline Server**
* `scp hello-world.tar user@your-server:/path/to/save`

**4. Load the Image on the Offline Server**
* `docker load -i /path/to/save/hello-world.tar`

**5. Verify the Image**
* `docker images` 
You should see the `hello-world` image listed.

**6. Use the Image**
* `docker run hello-world`


## Installing GPU packages: 
To download all the necessary NVIDIA CUDA drivers, toolkit, and Docker-related packages into a separate folder named `nvidia_packages` on the machine with internet access, you can use the following script:

### Step 1: Download the Packages to `nvidia_packages` Folder

```bash
#!/bin/bash

# Create a directory to store all downloaded packages
mkdir -p ~/nvidia_packages
cd ~/nvidia_packages

# Check if an NVIDIA GPU is present
if lspci | grep -i nvidia &>/dev/null; then
    echo "NVIDIA GPU found."
    echo "Downloading NVIDIA CUDA drivers and Toolkit"
    export distro="$(lsb_release -is | tr '[:upper:]' '[:lower:]')$(lsb_release -rs | tr -d '.')"
    export arch=$(uname -m)

    # Download the CUDA keyring
    wget https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-keyring_1.1-1_all.deb
    
    # Add NVIDIA repo and download CUDA drivers
    sudo dpkg -i cuda-keyring_1.1-1_all.deb
    sudo apt-get -qq update
    apt-get download $(apt-cache depends cuda-drivers | grep Depends | sed "s/.*ends:\ //" | tr '\n' ' ')

    echo "Downloading NVIDIA container toolkit"
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    sudo apt-get -qq update
    apt-get download nvidia-container-toolkit nvidia-docker2

    echo "Downloading Docker-related packages"
    apt-get download jq docker.io

    echo "All NVIDIA and Docker packages downloaded to ~/nvidia_packages"
else
    echo "No NVIDIA GPU found. Skipping NVIDIA package download."
fi

```

### Step 2: Transfer the `nvidia_packages` Folder

1. **Transfer the `nvidia_packages` Folder via `scp`:**


   `scp -i "key" -r ~/nvidia_packages user@offline-machine:/path/to/destination`

### Step 3: Install the Packages on the Offline Machine

1. **Install the Packages on the Offline Machine:**

   On the offline machine, navigate to the directory where you transferred the `nvidia_packages` folder and install all the `.deb` packages:

   `cd /path/to/destination/nvidia_packages`
   `sudo dpkg -i *.deb`
   `sudo apt-get install -f`

2. **Restart the machine**


## Setting up Webhook : 

Given that you already have the necessary template files (`hooks.json.template`, `webhook.service.template`) and the `.env` file on the offline machine, the primary task is to install the `webhook` binary and then run your setup script. Here’s how to proceed:

### Step 1: Prepare the `webhook` Binary on the Internet-Connected Machine

1. **Download the Webhook Binary:**

   On the machine with internet access, download the `webhook` binary:

   ```bash
   mkdir -p ~/webhook_setup
   cd ~/webhook_setup
   curl -sSL https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz -o webhook-linux-amd64.tar.gz
   tar -zxvf webhook-linux-amd64.tar.gz --strip-components=1 --directory .
   ```

2. **Transfer the Binary to the Offline Machine:**

   Transfer the `webhook` binary to the offline machine using `scp`:

   ```bash
   scp ~/webhook_setup/webhook user@offline-machine:/path/to/destination
   ```

### Step 2: Install the `webhook` Binary on the Offline Machine

1. **Move the Binary to `/usr/local/bin`:**

   On the offline machine, move the `webhook` binary to `/usr/local/bin` and make it executable:

   ```bash
   sudo mv /path/to/destination/webhook /usr/local/bin/
   sudo chmod +x /usr/local/bin/webhook
   ```

### Step 3: Run the Setup Script on the Offline Machine

1. **Ensure the `.env` File is Correct:**

   Verify that your `.env` file has the correct values for `WEBHOOK_PASSWORD`, `WEBHOOK_USER`, and `WEBHOOK_GROUP`.

2. **Run the Setup Script:**

   Navigate to the directory where your setup script is located and run it:

   ```bash
   cd /path/to/setup_script
   ./setup_webhook.sh
   ```

### Step 4: Verify the Setup

1. **Check the Webhook Service Status:**

   After running the setup script, ensure that the webhook service is running:

   ```bash
   sudo systemctl status webhook.service
   ```