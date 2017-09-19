FROM hub.c.163.com/workhardsmile/citest:slave

COPY ./testplus /slave 
RUN pip install selenium nose \
    && mkdir -p /slave/log \
    && mkdir -p /slave/projects \
    && apt-get update \
	&& apt-get install -y vim gcc make g++ libmysqlclient-dev \ 
    && cd /slave \
	&& bundle install \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get purge -y --auto-remove gcc make g++
VOLUME ["/slave/log", "/slave/config", "/slave/projects"]
CMD ["ruby", "/slave/testplus_run.rb"]