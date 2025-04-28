FROM jupyter/scipy-notebook:latest

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libpq-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install Python packages
RUN pip install --no-cache-dir \
    pandas \
    matplotlib \
    seaborn \
    sqlalchemy \
    psycopg2-binary \
    ipython-sql \
    google-cloud-storage \
    google-cloud-bigquery \
    pyarrow \
    gcsfs \
    dbt-core \
    dbt-postgres \
    dbt-bigquery \
    prefect \
    great_expectations

# Set working directory
WORKDIR /home/jovyan/notebooks