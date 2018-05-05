# Start with a large python base image that includes gcc and other libraries
FROM python:3 as python-base
COPY requirements.txt .
RUN pip install -r requirements.txt

# This time, we will download in the first stage so that we do not need wget in
# the final image
# You should use dumb-init when running commands in docker. 
# See why here: https://github.com/Yelp/dumb-init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64

# This will be our final image as it does not include 'as'
FROM python:3-alpine

# We copy over the built files from our first stage that we will use in this
# final version.
COPY --from=python-base /root/.cache /root/.cache
COPY --from=python-base requirements.txt .
RUN pip install -r requirements.txt && rm -rf /root/.cache

# Copy over dumb-init
COPY --from=python-base /usr/local/bin/dumb-init /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

# Add our app's code to the image
COPY ./app /app
WORKDIR /app

# Runs "/usr/bin/dumb-init -- /my/script --with --args"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run our app
CMD gunicorn -w 4 -b 0.0.0.0:8000 main:app
