FROM debian:11.2

ARG USERNAME=swuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# ********************************************************
# * Anything else you want to do like clean up goes here *
# ********************************************************

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

#Install dependencies
RUN sudo apt update && sudo apt install -y python3 python3-pip fonts-liberation cron at ruby-full wget libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libcups2 libcurl3-gnutls libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libxcomposite1 libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 xdg-utils git

#Set up the headers project
WORKDIR /headers
ARG CHROME_VERSION=109.0.5414.119-1
RUN sudo wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb
RUN sudo dpkg -i google-chrome-stable_${CHROME_VERSION}_amd64.deb; sudo apt-get -f install -y && rm google-chrome-stable_${CHROME_VERSION}_amd64.deb
COPY southwest-headers southwest-headers
COPY 0001-Set-version-109.patch southwest-headers
RUN sudo chown -R $USERNAME:$USERNAME southwest-headers
WORKDIR southwest-headers
RUN git config --global user.name "swuser" && git config --global user.email "swuser@aaron-todd.com" && git am 0001-Set-version-109.patch
RUN pip3 install --user virtualenv && export PATH=$PATH:/home/$USERNAME/.local/bin && virtualenv env
RUN env/bin/pip install -r requirements.txt
RUN BROWSER_MAJOR=$(google-chrome --version | sed 's/Google Chrome \([0-9]*\).*/\1/g') && \
    wget https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${BROWSER_MAJOR} -O chrome_version && \
    wget https://chromedriver.storage.googleapis.com/`cat chrome_version`/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    rm chromedriver_linux64.zip && \
    DRIVER_MAJOR=$(chromedriver --version | sed 's/ChromeDriver \([0-9]*\).*/\1/g') && \
    echo "chrome version: $BROWSER_MAJOR" && \
    echo "chromedriver version: $DRIVER_MAJOR" && \
    if [ $BROWSER_MAJOR != $DRIVER_MAJOR ]; then echo "VERSION MISMATCH"; exit 1; fi
RUN export RAND=$(tr -dc A-Za-z < /dev/urandom | head -c 3) && perl -pi -e 's/cdc_/$ENV{RAND}_/g' chromedriver
#We will install the crontab, but have the command run on startup of the container to generate first header when started
COPY southwest-cron /etc/cron.d/southwest-cron
RUN sudo chmod 0644 /etc/cron.d/southwest-cron && crontab /etc/cron.d/southwest-cron

#set up the checkin project
WORKDIR /checkin
COPY southwest-checkin southwest-checkin
WORKDIR southwest-checkin
COPY .autoluv.env /home/$USERNAME/.autoluv.env
RUN sudo gem install autoluv

COPY entrypoint.sh /home/$USERNAME/entrypoint.sh
RUN sudo chmod +rx /home/$USERNAME/entrypoint.sh
RUN sudo chmod a+w /var/lib/gems/2.7.0/gems/autoluv-*/
ENTRYPOINT ["/home/swuser/entrypoint.sh"]
