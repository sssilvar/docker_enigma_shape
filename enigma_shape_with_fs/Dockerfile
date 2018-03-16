FROM freesurfer/freesurfer:6.0
MAINTAINER Santiago Smith <sssilvar@unal.edu.co>

# Set proxy (if necessary)
ARG user=aieun
ARG pass=3173831565

ENV http_proxy=http://user:pass@proxyapp.unal.edu.co:8080/
ENV https_proxy=https://user:pass@proxyapp.unal.edu.co:8080/
ENV ftp_proxy=https://user:pass@proxyapp.unal.edu.co:8080/

# Update container
RUN apt-get update

# Expose port (BTW)
EXPOSE 80

# Create an input and an output folders
RUN mkdir /input && mkdir /output

# Copy license to container
COPY license /opt/freesurfer/.license
