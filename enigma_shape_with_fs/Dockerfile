# Create a base docker container that will execute the ENIGMA Shape analysis and
# put the results in the /output foder
#
# Example usage:
#   docker run --rm -ti \
#       -v </groupfile/directory>:/group \
#       -v </input/directory>:/input \
#       -v </output/directory>:/output \
#       sssilvar/eshape_fs /group/groupfile.csv /input /output
#


FROM freesurfer/freesurfer:6.0
MAINTAINER Santiago Smith <sssilvar@unal.edu.co>

# Set proxy (if necessary) --build-arg
ARG proxy

ENV http_proxy=$proxy

# Update container
RUN apt-get -y update && \
	apt-get -y install perl

# Expose port (BTW)
EXPOSE 80

# Create an input and an output folders
RUN mkdir /input && mkdir /output && mkdir /group

# Copy license to container
COPY license /opt/freesurfer/.license

# Add enigma shape analysis
ADD enigma_shape /usr/local/enigma_shape
RUN chmod +x -R /usr/local/enigma_shape
ENV ENIGMA_SHAPE_DIR=/usr/local/enigma_shape/
ENV FS=/opt/freesurfer/
ENTRYPOINT ["/usr/local/enigma_shape/shape_group_run.sh"]