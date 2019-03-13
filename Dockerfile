FROM node:8
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
COPY . /usr/src/app
RUN echo "machine github.com" >> ~/.netrc
RUN echo "    login ${GITHUB_USER}" >> ~/.netrc
RUN echo "    password ${GITHUB_TOKEN}" >> ~/.netrc
RUN chmod 600 ~/.netrc
RUN npm -g install gitbook-cli
RUN npm install
RUN gitbook install
RUN gitbook build
EXPOSE 9000
CMD [ "npm", "start" ]