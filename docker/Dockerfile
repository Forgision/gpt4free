FROM selenium/node-chrome

# ARG G4F_VERSION
ARG G4F_USER=g4f
ARG G4F_USER_ID=1000
ARG G4F_NO_GUI
ARG G4F_PASS=secret

ENV G4F_USER $G4F_USER
ENV G4F_USER_ID $G4F_USER_ID
ENV G4F_NO_GUI $G4F_NO_GUI

ENV SE_SCREEN_WIDTH 1850
ENV PYTHONUNBUFFERED 1
ENV G4F_DIR /app
ENV G4F_LOGIN_URL http://localhost:7900/?autoconnect=1&resize=scale&password=$G4F_PASS
ENV HOME /home/$G4F_USER
ENV PATH $PATH:$HOME/.local/bin
ENV SE_DOWNLOAD_DIR $HOME/Downloads
ENV SEL_USER $G4F_USER
ENV SEL_UID $G4F_USER_ID
ENV SEL_GID $G4F_USER_ID

USER root

# RUN apt-get update

RUN \
G4F_VERSION=$(wget -qO-  "https://api.github.com/repos/xtekky/gpt4free/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') \
echo "G4F_VERSION: ${G4F_VERSION}"

RUN wget https://github.com/xtekky/gpt4free/archive/refs/tags/$(wget -qO-  "https://api.github.com/repos/xtekky/gpt4free/releases/latest" \
| awk '/tag_name/{print $4;exit}' FS='[""]').zip -O /tmp/g4f.zip
RUN unzip /tmp/g4f.zip
RUN mv gpt4free-${G4F_VERSION}/g4f /app

#  If docker compose, install git
RUN if [ "$G4F_VERSION" = "" ] ; then \
  apt-get -qqy update && \
  apt-get -qqy install git \
  ; fi

# Python packages
RUN apt-get -qqy update \
  && apt-get -qqy install \
    python3 \
    python-is-python3 \
    pip

# Remove java
RUN apt-get -qyy remove openjdk-11-jre-headless

# Cleanup
RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  && apt-get -qyy autoremove \
  && apt-get -qyy clean

# Update entrypoint
COPY docker/supervisor.conf /etc/supervisor/conf.d/selenium.conf
COPY docker/supervisor-gui.conf /etc/supervisor/conf.d/gui.conf

# If no gui
RUN if [ "$G4F_NO_GUI" ] ; then \
  rm /etc/supervisor/conf.d/gui.conf \
  ; fi

# Change background image
COPY docker/background.png /usr/share/images/fluxbox/ubuntu-light.png

# Add user
RUN groupadd -g $G4F_USER_ID $G4F_USER \
  && useradd -rm -G sudo -u $G4F_USER_ID -g $G4F_USER_ID $G4F_USER \
  && echo "${G4F_USER}:${G4F_PASS}" | chpasswd

# Fix permissions
RUN mkdir "${SE_DOWNLOAD_DIR}"
RUN chown "${G4F_USER_ID}:${G4F_USER_ID}" $SE_DOWNLOAD_DIR /var/run/supervisor /var/log/supervisor
RUN chown "${G4F_USER_ID}:${G4F_USER_ID}" -R /opt/bin/ /usr/bin/chromedriver /opt/selenium/

COPY docker/update.sh $G4F_DIR

RUN chown -R $G4F_USER:$G4F_USER $G4F_DIR

RUN chmod +x /app/update.sh

# Switch user
USER $G4F_USER_ID

# Set VNC password
RUN mkdir -p ${HOME}/.vnc \
  && x11vnc -storepasswd ${G4F_PASS} ${HOME}/.vnc/passwd

# Set the working directory in the container.
WORKDIR $G4F_DIR

# Copy the project's requirements file into the container.
COPY requirements.txt $G4F_DIR

# Upgrade pip for the latest features and install the project's Python dependencies.
RUN pip install --upgrade pip && pip install -r requirements.txt

# # Copy the entire package into the container.
# # ADD --chown=$G4F_USER:$G4F_USER g4f $G4F_DIR/g4f

# Expose ports
EXPOSE 8080 1337