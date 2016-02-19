FROM alpine
MAINTAINER Sébastien LECACHEUR "slecache@gmail.com"

#
# install Node & Git
#
RUN apk add --update nodejs git \
		&& rm -rf /var/cache/apk/*

#
# install Bower & Grunt
#
RUN npm install -g bower grunt-cli

#
# define working directory.
#
WORKDIR /data

#
# download the specified (API_CONSOLE_VERSION) version of RAML api:Console
#
ENV API_CONSOLE_VERSION feature/new-raml
RUN git clone --depth 1 --branch $API_CONSOLE_VERSION https://github.com/mulesoft/api-console.git /data \
        && mkdir /data/dist/apis \
        && mv /data/dist/examples/simple.raml /data/dist/apis/main.raml \
        && rm -rf /data/dist/examples \
        && rm -rf /data/src \
        && rm -rf /data/test \
        && rm -rf /data/.git

#
# install modules and dependencies with NPM and Bower
#
RUN npm install \
        && bower install --production --allow-root \
        && npm cache clean \
        && bower cache clean --allow-root

#
# add customs files for the API
#
RUN sed -i 's/<raml-initializer><\/raml-initializer>/<raml-console src="apis\/main.raml" resources-collapsed><\/raml-console>/g' /data/dist/index.html \
		&& sed -i '40s/resource/\/resource/g' /data/dist/apis/main.raml \
		&& sed -i '190s/\.\.\./"\.\.\.": "\.\.\."/g' /data/dist/apis/main.raml
ONBUILD ADD . /data/dist/apis/

EXPOSE 9000
EXPOSE 35729

#
# start Node.js server with Grunt
#
ENTRYPOINT ["grunt", "connect:livereload", "watch"]
