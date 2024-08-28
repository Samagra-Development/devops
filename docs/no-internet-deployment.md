## Docker Package Installation

### Overview : 
- **Download**: Use a machine with internet access to download Docker and its dependencies.
- **Transfer**: Move the files to the server using `scp`.
- **Install**: Use `dpkg` on the server to install the packages.

### Step 1: Download the Packages on a Machine with Internet Access

1. **Set up Docker's apt repository:**

   On a machine with internet access, update your package list and set up Docker's apt repository:
   ```bash
   sudo apt-get update
   sudo apt-get install -y ca-certificates curl
   sudo install -m 0755 -d /etc/apt/keyrings
   sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
   sudo chmod a+r /etc/apt/keyrings/docker.asc
   ```

2. **Add Docker's repository to your apt sources:**

   ```bash
   echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   sudo apt-get update
   ```

3. **Download the Docker packages and their dependencies:**

   ```bash
   mkdir -p ~/docker-packages
   cd ~/docker-packages
   sudo apt-get download docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
   ```

   This will download all the necessary `.deb` files into the `~/docker-packages` directory.

4. **Compress the folder containing the `.deb` files for easy transfer:**

   ```bash
   tar -czvf docker-packages.tar.gz -C ~/ docker-packages
   ```

### Step 2: Transfer the Packages to the Server

1. **Use `scp` to transfer the compressed file to your server:**

   Replace `<ubuntu-user>@<ubuntu-ip>:~/path/to/destination` with your server details:
   ```bash
   scp -i "/path/to/key" docker-packages.tar.gz <ubuntu-user>@<ubuntu-ip>:~/path/to/destination
   ```

2. **SSH into your server and navigate to the destination directory:**

   ```bash
   ssh -i "/path/to/key" <ubuntu-user>@<ubuntu-ip>
   cd ~/path/to/destination
   ```

3. **Extract the compressed file:**

   ```bash
   tar -xzvf docker-packages.tar.gz
   ```

### Step 3: Install the Docker Packages on the Server

1. **Navigate to the directory containing the `.deb` files:**

   ```bash
   cd docker-packages
   ```

2. **Install all the packages using `dpkg`:**

   ```bash
   sudo dpkg -i *.deb
   ```

3. **Fix any missing dependencies:** (Requires Internet)

   ```bash
   sudo apt-get install -f
   ```

   This will install any missing dependencies from the `.deb` files that are already present in the directory.


## How to Use a Docker Image Offline.

## Overview :
To use a Docker image offline, pull the `hello-world` image on a connected machine and save it as `hello-world.tar`. Transfer this file to the offline server, load it with `docker load -i hello-world.tar`, and then run it using `docker run hello-world`.

### 1. Pre-download the `hello-world` Image

On a machine with internet access, pull the `hello-world` Docker image:
```bash
docker pull hello-world
```

### 2. Save the Image

Save the pulled `hello-world` image as a tar file:
```bash
docker save -o hello-world.tar hello-world
```

### 3. Transfer the Image to the Offline Server

```bash
scp hello-world.tar user@your-server:/path/to/save
```

### 4. Load the Image on the Offline Server

```bash
docker load -i /path/to/save/hello-world.tar
```

### 5. Verify the Image

```bash
docker images
```

You should see the `hello-world` image listed.

### 6. Use the Image

```bash
docker run hello-world
```