ARG IMAGE=gitea.internal/ben/libtorch-docker:cpu-dev
FROM $IMAGE

# Setup the ci environment
COPY ci /tmp/ci
RUN sudo /tmp/ci/setup-ci.bash && rm -rf /tmp/ci

# Make libs discoverable for runtime linking (For some reason its not carried over from the base image)
RUN ldconfig /usr/local/libtorch/lib/ && ldconfig -p | grep /usr/local/libtorch || { echo "Error: libtorch not found in ldconfig paths"; exit 1; }

# Set the node bin path explicitly to ensure its in the path
ENV PATH="/opt/node/x64/bin:$PATH"
