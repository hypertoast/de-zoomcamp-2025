#!/bin/bash

# Update and install dependencies
apt-get update
apt-get install -y python3-pip python3-dev libpq-dev postgresql postgresql-contrib docker.io docker-compose git

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add current user to Docker group
usermod -aG docker $(whoami)

# Install Python dependencies
pip3 install apache-airflow[gcp,postgres]==2.7.1 pytest

# Create airflow directory
mkdir -p /opt/airflow
cd /opt/airflow

# Initialize Airflow config
export AIRFLOW_HOME=/opt/airflow
airflow config init

# Set up Airflow database
airflow db init

# Create Airflow user
airflow users create \
    --username admin \
    --password admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com

# Create Docker Compose file for Airflow
cat > docker-compose.yml <<EOL
version: '3'
services:
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_USER=airflow
      - POSTGRES_PASSWORD=airflow
      - POSTGRES_DB=airflow
    volumes:
      - postgres-db-volume:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "airflow"]
      interval: 5s
      retries: 5
    restart: always

  airflow-webserver:
    image: apache/airflow:2.7.1
    depends_on:
      - postgres
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=''
      - AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true
      - AIRFLOW__CORE__LOAD_EXAMPLES=false
      - AIRFLOW__API__AUTH_BACKENDS='airflow.api.auth.backend.basic_auth'
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    ports:
      - "8080:8080"
    command: webserver
    healthcheck:
      test: ["CMD", "curl", "--fail", "http://localhost:8080/health"]
      interval: 10s
      timeout: 10s
      retries: 5
    restart: always

  airflow-scheduler:
    image: apache/airflow:2.7.1
    depends_on:
      - postgres
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=''
      - AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true
      - AIRFLOW__CORE__LOAD_EXAMPLES=false
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    command: scheduler
    restart: always

volumes:
  postgres-db-volume:
EOL

# Create directories for Airflow
mkdir -p /opt/airflow/dags
mkdir -p /opt/airflow/logs
mkdir -p /opt/airflow/plugins

# Start Airflow using Docker Compose
cd /opt/airflow
docker-compose up -d

# Setup firewall to allow Airflow web UI access
gcloud compute firewall-rules create allow-airflow --allow tcp:8080

echo "Airflow setup complete. You can access the Airflow UI at http://[EXTERNAL_IP]:8080"