FROM node:11 AS builder
COPY . /app
WORKDIR /app
RUN yarn install
RUN yarn run build

FROM wlchn/gostatic:latest
ENV CONFIG_FILE_PATH /srv/http
COPY --from=builder /app/build /srv/http
COPY ./env.sh /env.sh
# Ensure convert envs to window._env
ENTRYPOINT ["sh", "/env.sh"]
# start server. listen on 8043(in container) by default.
CMD ["/goStatic"]
