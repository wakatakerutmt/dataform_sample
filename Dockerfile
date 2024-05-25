FROM node:22-alpine

RUN npm i -g @dataform/cli@^3.0.0-beta.2

COPY . /workdir
WORKDIR /workdir