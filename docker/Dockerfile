# FROM selenium/node-chrome
FROM seleniarm/node-chromium

ARG G4F_VERSION=0.3.1.9
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

# RUN if [ "$G4F_NO_GUI" ] ; then \
#   # If no gui
#   COPY docker/supervisor.conf /etc/supervisor/conf.d/selenium.conf \
#   else \
#   COPY docker/supervisor.conf /etc/supervisor/conf.d/selenium.conf \
#   COPY docker/supervisor-gui.conf /etc/supervisor/conf.d/gui.conf \
#   ; fi


# #  If docker compose, install git
RUN \
  apt-get -qqy update && \
  apt-get -qqy install \
  git \
  python3 \
  python-is-python3 \
  pip \
  && mkdir ${G4F_DIR} \
  # Installing Gpt4Free
  && G4F_VERSION=$(wget -qO-  "https://api.github.com/repos/xtekky/gpt4free/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') \
  # echo "G4F_VERSION: ${G4F_VERSION}" \
  && wget https://github.com/xtekky/gpt4free/archive/refs/tags/${G4F_VERSION}.zip -O /tmp/g4f.zip \
  && unzip /tmp/g4f.zip \
  && mv gpt4free-${G4F_VERSION} /app \
  # Remove java
  && apt-get -qyy remove openjdk-11-jre-headless

# # Python packages
# RUN apt-get -qqy update \
#   && apt-get -qqy install \
#     python3 \
#     python-is-python3 \
#     pip


# # Cleanup
# RUN rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
#   && apt-get -qyy autoremove \
#   && apt-get -qyy clean

# Update entrypoint
RUN if [ "$G4F_NO_GUI" ] ; then \
  # If no gui
  COPY docker/supervisor.conf /etc/supervisor/conf.d/selenium.conf \
  else \
  COPY docker/supervisor.conf /etc/supervisor/conf.d/selenium.conf \
  COPY docker/supervisor-gui.conf /etc/supervisor/conf.d/gui.conf \
  ; fi

# # Change background image
# COPY docker/background.png /usr/share/images/fluxbox/ubuntu-light.png

# Add user
RUN groupadd -g $G4F_USER_ID $G4F_USER \
  && useradd -rm -G sudo -u $G4F_USER_ID -g $G4F_USER_ID $G4F_USER \
  && echo "${G4F_USER}:${G4F_PASS}" | chpasswd

COPY docker/update.sh $G4F_DIR

# Fix permissions
RUN mkdir "${SE_DOWNLOAD_DIR}"
RUN chown "${G4F_USER_ID}:${G4F_USER_ID}" $SE_DOWNLOAD_DIR /var/run/supervisor /var/log/supervisor
RUN chown "${G4F_USER_ID}:${G4F_USER_ID}" -R /opt/bin/ /usr/bin/chromedriver /opt/selenium/
RUN chown "${G4F_USER_ID}:${G4F_USER_ID}" -R $G4F_DIR

# RUN chmod +x /app/update.sh

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
RUN pip install --break-system-packages --upgrade pip \
  && pip install --break-system-packages -r requirements.txt \
  && pip install --break-system-packages \
    undetected-chromedriver selenium-wire \
  && pip uninstall -y --break-system-packages \
    pywebview plyer

# # Copy the entire package into the container.
# # ADD --chown=$G4F_USER:$G4F_USER g4f $G4F_DIR/g4f

# Expose ports
EXPOSE 8080 1337