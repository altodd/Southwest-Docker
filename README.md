# Southwest-Docker
Container made to make running byalextran's Southwest Checkin easy

TLDR: You can `docker pull altodd/southwest-docker` and then use all the options specified in the [origonal project](https://github.com/byalextran/southwest-checkin)

## Usage

### Schedule a Check-In

    docker run -itd altodd/southwest-docker schedule ABCDEF John Doe

### Schedule a Check-In With Email Notification

    docker run -itd altodd/southwest-docker schedule ABCDEF John Doe john.doe@email.com optional@bcc.com

### Check In Immediately

    docker run -itd altodd/southwest-docker checkin ABCDEF John Doe
    
## Email set up
It's already set up! Emails should come from southwest.docker@mail.com

## Building the image
If you want to modify this image you can build it by cloning both [southwest-headers](https://github.com/byalextran/southwest-headers) and [southwest-checkin](https://github.com/byalextran/southwest-checkin) into the same directory as the Dockerfile and then doing a docker build.

I plan to further optomize and improve on this image when I have more time. I am by no means a docker engineer, I just know how to get things done with Docker, so feel free to contribute your optomizations/thoughts! I just got this going and have tested things on my machine, If you run into any problems please open an issue as I haven't had time to do a lot of testing before I travel. 
