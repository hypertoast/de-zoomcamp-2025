#!/bin/bash

# Update and install dependencies
apt-get update
apt-get install -y docker.io docker-compose git

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add current user to Docker group
usermod -aG docker $(whoami)

# Create airflow directory
mkdir -p /opt/airflow
cd /opt/airflow

# Create directories for Airflow with proper permissions
mkdir -p /opt/airflow/dags
mkdir -p /opt/airflow/logs
mkdir -p /opt/airflow/plugins

# Set proper permissions
chmod -R 777 /opt/airflow/logs
chmod -R 777 /opt/airflow/dags
chmod -R 777 /opt/airflow/plugins

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
      - airflow-init
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=''
      - AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true
      - AIRFLOW__CORE__LOAD_EXAMPLES=false
      - AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session
      - AIRFLOW__WEBSERVER__WEB_SERVER_HOST=0.0.0.0
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
      - airflow-init
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=''
      - AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION=true
      - AIRFLOW__CORE__LOAD_EXAMPLES=false
      - AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    command: scheduler
    restart: always

  airflow-init:
    image: apache/airflow:2.7.1
    depends_on:
      - postgres
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres/airflow
      - AIRFLOW__CORE__FERNET_KEY=''
      - AIRFLOW__CORE__LOAD_EXAMPLES=false
      - AIRFLOW__API__AUTH_BACKENDS=airflow.api.auth.backend.basic_auth,airflow.api.auth.backend.session
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    entrypoint: /bin/bash
    command: -c "airflow db init && airflow users create --username admin --password admin --firstname Admin --lastname User --role Admin --email admin@example.com"

volumes:
  postgres-db-volume:
EOL

# Start Airflow using Docker Compose
cd /opt/airflow
docker-compose up -d

echo "Airflow setup complete. You can access the Airflow UI at http://[EXTERNAL_IP]:8080"
echo "To verify containers are running: docker ps"