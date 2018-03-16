FROM freesurfer/freesurfer:6.0
MAINTAINER Santiago Smith <sssilvar@unal.edu.co>

# Set proxy (if necessary) --build-arg
ARG user
ARG pass

ENV http_proxy=http://$user:$pass@proxyapp.unal.edu.co:8080/
ENV https_proxy=https://$user:$pass@proxyapp.unal.edu.co:8080/
ENV ftp_proxy=https://$user:$pass@proxyapp.unal.edu.co:8080/

# Update container
RUN apt-get update && \
	apt-get install perl

# Expose port (BTW)
EXPOSE 80

# Create an input and an output folders
RUN mkdir /input && mkdir /output

# Copy license to container
COPY license /opt/freesurfer/.license

# Add enigma shape analysis
ADD enigma_shape /usr/local/enigma_shape
RUN chmod +x -R /usr/local/enigma_shape
ENV ENIGMA_SHAPE_DIR=/usr/local/enigma_shape/
ENV FS=/opt/freesurfer/
