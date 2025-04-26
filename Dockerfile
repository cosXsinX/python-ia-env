# Use an official Python image as base
FROM jupyter/datascience-notebook:x86_64-python-3.11.6

# Set working directory inside the container
WORKDIR /workspace

# Switch to root to install code-server
USER root

# Install code-server manually
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://github.com/coder/code-server/releases/download/v4.98.2/code-server_4.98.2_amd64.deb -o code-server.deb && \
    apt-get install -y ./code-server.deb && \
    rm code-server.deb


#RUN code --version

# Install VS Code extensions
RUN code-server --install-extension ms-python.python
#RUN code-server --install-extension ms-python.vscode-pylance
RUN code-server --install-extension ms-toolsai.jupyter
RUN code-server --install-extension eamodio.gitlens
RUN code-server --install-extension ms-azuretools.vscode-docker
RUN code-server --install-extension ms-python.debugpy
RUN code-server --install-extension esbenp.prettier-vscode
#RUN code-server --install-extension visualstudioexptteam.vscodeintellicode
RUN code-server --install-extension github.vscode-pull-request-github

# Create config directory (still as root, but we'll fix permissions)
# As root
RUN mkdir -p /home/jovyan/.config/code-server && \
    printf "bind-addr: 0.0.0.0:8080\nauth: password\npassword: maximax\n\ncert: false\n" \
    > /home/jovyan/.config/code-server/config.yaml && \
    chown -R jovyan:users /home/jovyan/.config

# Create volume workspace directory
RUN mkdir -p /workspace && chown jovyan:users /workspace
	
# Fix log dir permissions
RUN mkdir -p /home/jovyan/.local/share/code-server && \
    chown -R jovyan:users /home/jovyan/.local

COPY requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Expose code-server port
EXPOSE 8080



# Switch back to non-root user
USER jovyan

# Start code-server & jupyter notebook
CMD bash -c "jupyter notebook --ip=0.0.0.0 --port=8888 --NotebookApp.token='' --NotebookApp.password='' & \
             code-server /workspace --config /home/jovyan/.config/code-server/config.yaml"