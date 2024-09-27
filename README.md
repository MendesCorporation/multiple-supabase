# Supabase Multi-Instance Setup Script

This repository contains a bash script (generate.bash) to facilitate the creation of multiple Supabase instances on a single VPS. The goal is to allow the operation of several isolated instances, each with its own environment variables and volume configuration, to support different projects efficiently on a single server.

## Objective
The purpose of generate.bash is to automatically create and configure new Supabase instances, generating unique instance IDs, non-conflicting ports, and customized settings for each new instance. This is useful when you need multiple isolated environments on the same server without manually managing each instance's configurations.

## How it Works
The script:

* Generates a unique INSTANCE_ID based on the date and time, which can be customized.
* Generates secure passwords and keys for environment variables like POSTGRES_PASSWORD, JWT_SECRET, ANON_KEY, and SERVICE_ROLE_KEY.
* Automatically substitutes variables into configuration files such as .env.template, docker-compose.yml, kong.yml, and vector.yml.
* Creates and organizes necessary volume directories for PostgreSQL, functions, and logs for each instance.
* Sets up dynamic ports to avoid conflicts between instances.
* Spins up the instance containers using docker compose.
  
## Repository Structure

* generate.bash: Main bash script for generating and configuring new instances.
* docker/: Directory containing configuration templates, such as .env.template and docker-compose.yml, as well as the Kong and Vector configuration files.
* volumes/: Directory containing initial folders and files for PostgreSQL, functions, and logs.
  
### How to Use
  ### Step 1: Clone the Repository
  Clone this repository to your VPS.

```bash
git clone https://github.com/MendesCorporation/multiple-supabase.git
cd multiple-supabase/docker
```
### Step 2: Edit generate.bash
Edit the generate.bash file with your desired configurations, such as SMTP_HOST, JWT_EXPIRY, SITE_URL, among other variables specific to your environment.

### Step 3: Run the Script
Run the script to generate a new instance:

```bash
sh generate.bash
```
The script will automatically generate a new INSTANCE_ID and configure the instance with dynamic ports, unique passwords, and keys.

### Step 4: Access the Instance
Once the script finishes running, you can access your new instance using the ports configured by the script. The default generated URLs will look like:

Supabase Public URL: http://0.0.0.0:80XX
Replace XX with the generated port number.

### Step 5: Managing Multiple Instances
Each time the script is executed, it generates a new isolated instance with its own environment variables, volumes, and ports. Instances can be managed individually using Docker Compose commands:

```bash
docker compose -f docker-compose-${INSTANCE_ID}.yml down
docker compose -f docker-compose-${INSTANCE_ID}.yml up -d
```

Generated Folder Structure
For each new instance, the script creates the following directories:

```bash

volumes-${INSTANCE_ID}/
    ├── api/
    ├── db/
    ├── functions/
    └── logs/
```
Each of these directories contains the necessary files to run the associated containers.

### Important Environment Variables
Here are some of the environment variables automatically generated:

INSTANCE_ID: Unique ID for the instance.

POSTGRES_PASSWORD: PostgreSQL password.

JWT_SECRET: JWT key for authentication.

ANON_KEY and SERVICE_ROLE_KEY: Keys used in Supabase for permissions.

KONG_HTTP_PORT and KONG_HTTPS_PORT: Dynamic ports for HTTP and HTTPS access.

### Requirements

Docker and Docker Compose installed on the VPS.

OpenSSL for generating secure passwords.

### Contributing

Feel free to open issues and pull requests for improvements and fixes. Feedback is always welcome!
