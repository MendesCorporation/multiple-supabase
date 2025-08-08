#!/bin/bash

# Generate a unique identifier for the instance
INSTANCE_ID=${INSTANCE_ID:-$(date +%s)} #replace if using a custom name, otherwise a random one will be generated

# Export INSTANCE_ID so it can be used in envsubst
export INSTANCE_ID

# Generate other necessary variables
export POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -hex 16)} #if not replaced, a random password will be generated
# To generate JWT, ANON, and SERVICE_ROLE, visit https://supabase.com/docs/guides/self-hosting/docker
export JWT_SECRET=${JWT_SECRET:-9f878Nhjk3TJyVKgyaGh83hh6Pu9j9yfxnZSuphb}
export ANON_KEY=${ANON_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzI3MjMzMjAwLAogICJleHAiOiAxODg0OTk5NjAwCn0.O0qBbl300xfJrhmW3YktijUJQ5ZW6OXVyZjnSwSCzCg}
export SERVICE_ROLE_KEY=${SERVICE_ROLE_KEY:-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogInNlcnZpY2Vfcm9sZSIsCiAgImlzcyI6ICJzdXBhYmFzZSIsCiAgImlhdCI6IDE3MjcyMzMyMDAsCiAgImV4cCI6IDE4ODQ5OTk2MDAKfQ.7KpglgDbGij2ich1kiVbzBj6Znz_S5anWm0iOemyS18}
#
export DASHBOARD_USERNAME=${DASHBOARD_USERNAME:-admin} #user
export DASHBOARD_PASSWORD=${DASHBOARD_PASSWORD:-admin123} #default dashboard password can be overridden via env
export SECRET_KEY_BASE=$(openssl rand -base64 48)
export POSTGRES_DB=postgres 

# Export necessary variables for kong.yml
export SUPABASE_ANON_KEY=${ANON_KEY}
export SUPABASE_SERVICE_KEY=${SERVICE_ROLE_KEY}

# Generate random non-conflicting ports, do not change
export POSTGRES_PORT=${POSTGRES_PORT:-54$(shuf -i 10-99 -n 1)} 
#export POSTGRES_PORT_EXT=54$(shuf -i 10-99 -n 1) 
export KONG_HTTP_PORT=${KONG_HTTP_PORT:-80$(shuf -i 10-99 -n 1)}
export KONG_HTTPS_PORT=${KONG_HTTPS_PORT:-84$(shuf -i 10-99 -n 1)}
#export STUDIO_PORT=30$(shuf -i 10-99 -n 1)
#export AUTH_PORT=99$(shuf -i 10-99 -n 1)
#export REST_PORT=30$(shuf -i 10-99 -n 1)
#export REALTIME_PORT=40$(shuf -i 10-99 -n 1)
#export STORAGE_PORT=50$(shuf -i 10-99 -n 1)
#export IMGPROXY_PORT=50$(shuf -i 10-99 -n 1)
#export META_PORT=80$(shuf -i 10-99 -n 1)
export ANALYTICS_PORT=${ANALYTICS_PORT:-40$(shuf -i 10-99 -n 1)}
#export VECTOR_PORT=90$(shuf -i 10-99 -n 1)

# Set values for required variables
export API_EXTERNAL_URL=${API_EXTERNAL_URL:-"http://0.0.0.0:${KONG_HTTP_PORT}"} #replace with your IP
export SITE_URL=${SITE_URL:-"http://0.0.0.0:3000"} #replace with your IP
export SUPABASE_PUBLIC_URL=${SUPABASE_PUBLIC_URL:-"http://0.0.0.0:${KONG_HTTP_PORT}"} #replace with your IP
export STUDIO_DEFAULT_ORGANIZATION=${STUDIO_DEFAULT_ORGANIZATION:-"YourOrganization"}
export STUDIO_DEFAULT_PROJECT=${STUDIO_DEFAULT_PROJECT:-"YourProject"}
export ENABLE_EMAIL_SIGNUP=${ENABLE_EMAIL_SIGNUP:-"true"}
export ENABLE_EMAIL_AUTOCONFIRM=${ENABLE_EMAIL_AUTOCONFIRM:-"true"}
export SMTP_ADMIN_EMAIL=${SMTP_ADMIN_EMAIL:-"your_email"}
export SMTP_HOST=${SMTP_HOST:-"your_smtp_host"}
export SMTP_PORT=${SMTP_PORT:-2500}
export SMTP_USER=${SMTP_USER:-"your_smtp_user"}
export SMTP_PASS=${SMTP_PASS:-"your_smtp_pass"}
export SMTP_SENDER_NAME=${SMTP_SENDER_NAME:-"your_sender_name"}
export ENABLE_ANONYMOUS_USERS=${ENABLE_ANONYMOUS_USERS:-"true"}
export JWT_EXPIRY=${JWT_EXPIRY:-3600}
export DISABLE_SIGNUP=${DISABLE_SIGNUP:-"false"}
export IMGPROXY_ENABLE_WEBP_DETECTION=${IMGPROXY_ENABLE_WEBP_DETECTION:-"true"}
export FUNCTIONS_VERIFY_JWT=${FUNCTIONS_VERIFY_JWT:-"false"}
export DOCKER_SOCKET_LOCATION=${DOCKER_SOCKET_LOCATION:-"/var/run/docker.sock"}
export LOGFLARE_API_KEY=${LOGFLARE_API_KEY:-"your_logflare_key"}
export LOGFLARE_LOGGER_BACKEND_API_KEY=${LOGFLARE_LOGGER_BACKEND_API_KEY:-"your_logflare_key"}
export PGRST_DB_SCHEMAS=${PGRST_DB_SCHEMAS:-public,storage,graphql_public}

# Substitute variables in .env.template and generate instance-specific .env
if [ -f ".env.template" ]; then
  envsubst < .env.template > .env-${INSTANCE_ID}
else
  echo "Warning: .env.template not found. Creating minimal .env-${INSTANCE_ID}."
  : > .env-${INSTANCE_ID}
fi

# Substitute variables in docker-compose.yml and generate instance-specific docker-compose
envsubst < docker-compose.yml > docker-compose-${INSTANCE_ID}.yml

# Create volume directories for the instance
mkdir -p volumes-${INSTANCE_ID}/functions
mkdir -p volumes-${INSTANCE_ID}/logs
mkdir -p volumes-${INSTANCE_ID}/db/init
mkdir -p volumes-${INSTANCE_ID}/api  

# Copy necessary files to volume directories

## Copy all contents of the db folder, including subdirectories and specific files
if [ -d "volumes/db/" ]; then
  cp -a volumes/db/. volumes-${INSTANCE_ID}/db/
fi

## Copy all contents of the pooler folder, including subdirectories and specific files
if [ -d "volumes/pooler/" ]; then
  cp -a volumes/pooler/. volumes-${INSTANCE_ID}/pooler/
fi

## Copy function files (if any)
if [ -d "volumes/functions/" ]; then
  cp -a volumes/functions/. volumes-${INSTANCE_ID}/functions/
fi

## Substitute variables in vector.yml and copy to the instance directory
if [ -f "volumes/logs/vector.yml" ]; then
  envsubst < volumes/logs/vector.yml > volumes-${INSTANCE_ID}/logs/vector.yml
fi

## Substitute variables in kong.yml and copy to the instance directory
if [ -f "volumes/api/kong.yml" ]; then
  envsubst < volumes/api/kong.yml > volumes-${INSTANCE_ID}/api/kong.yml
else
  echo "Error: File volumes/api/kong.yml not found."
  exit 1
fi

# Start the instance containers
docker compose -f docker-compose-${INSTANCE_ID}.yml --env-file .env-${INSTANCE_ID} up -d
