# Start with a bare bones Ubuntu 16.04
FROM ubuntu:16.04

# Install what we need on the OS to install Python 3 with miniconda
RUN apt-get update -yqq && apt-get -y upgrade && apt-get install -yqq bzip2 \
    git \
    wget \
    gcc \
    python-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3 from miniconda. Sorry for the line breaks,
# the following ADD should be on the same line!!!
ADD https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh miniconda.sh 
RUN bash miniconda.sh -b -p /work/miniconda && rm miniconda.sh 
ENV PATH /work/miniconda/bin:$PATH

# Install all our apps requirements
COPY requirements.txt /requirements/requirements.txt
WORKDIR /requirements
run pip install --no-cache-dir -r requirements.txt

# Add our app's code to the image
COPY ./app /app
WORKDIR /app

# You should use dumb-init when running commands in docker. 
# See why here: https://github.com/Yelp/dumb-init
# Should all be on the same line!!!
RUN wget https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64.deb
RUN dpkg -i dumb-init_*.deb

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run our app
CMD gunicorn -w 4 -b 0.0.0.0:8000 main:app
