FROM debian:11.2

#Install dependencies
RUN apt update && apt install -y python3 python3-pip fonts-liberation cron at ruby-full wget libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libcups2 libcurl3-gnutls libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 libxcomposite1 libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 xdg-utils

#Set up the headers project
WORKDIR /headers
#I would like to make this versioned so an update doesn't break the driver I'm using pulling
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb
COPY southwest-headers southwest-headers
WORKDIR southwest-headers
RUN pip3 install virtualenv && virtualenv env
RUN env/bin/pip install -r requirements.txt
RUN wget https://chromedriver.storage.googleapis.com/96.0.4664.45/chromedriver_linux64.zip && unzip chromedriver_linux64.zip && rm chromedriver_linux64.zip
RUN export RAND=$(tr -dc A-Za-z < /dev/urandom | head -c 3) && perl -pi -e 's/cdc_/$ENV{RAND}_/g' chromedriver
#We will install the crontab, but have the command run on startup of the container to generate first header when started
COPY southwest-cron /etc/cron.d/southwest-cron
RUN chmod 0644 /etc/cron.d/southwest-cron && crontab /etc/cron.d/southwest-cron

#set up the checkin project
WORKDIR /checkin
COPY southwest-checkin southwest-checkin
WORKDIR southwest-checkin
COPY .autoluv.env /root/.autoluv.env
RUN gem install autoluv

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
