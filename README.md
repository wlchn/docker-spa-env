# docker-spa-env
Docker image used to serve a Single Page App (like React) using go server which is only 7MB.
Config runtime ENV for spa(Single Page App). Let you build your image first, and pass envs when laterly run your app.

## Usage
1. Copy `env.sh` to your project dir. This convert ENVS to a json into config.js. So we can use it as `window._env`
``` shell
#!/bin/sh
if [ $CONFIG_VARS ]; then
  # clear
  echo -n > ${CONFIG_FILE_PATH}/config.js

  SPLIT=$(echo $CONFIG_VARS | tr "," "\n")
  echo "window._env = {" >> ${CONFIG_FILE_PATH}/config.js

  for VAR in ${SPLIT}; do
      VALUE=$(printenv ${VAR})
      echo "  ${VAR}: \"${VALUE}\"," >> ${CONFIG_FILE_PATH}/config.js
  done

  echo "}" >> ${CONFIG_FILE_PATH}/config.js
fi

# disable broswer cache
sed -i "s/config.js?v=[0-9]*/config.js?v=$(date +'%s')/g" /srv/http/index.html

# exec CMD
exec "$@"
```
2. Write Your Dockerfile Build your app. And serve the builed files and the config.js.

```
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
```

3. Add config.js to your index.html
```
<script type="text/javascript" src="/config.js?v="></script>
```
4. Use window._env as your env
```
let _env = process.env;
// check if there is env exits in local, otherwise using window._env
if (_env.ENV_ABC) {
  _env = window._env;
}
// so you can use env like _env.ENV_ABC
```

5. pass env when docker run or docker-compose up
```
# pass envs like:
CONFIG_VARS=ABC,XYZ
ABC=helloabc
XYZ=HELLOXYZ

# you coud get config.js
window._env = {
  ABC: "helloabc",
  XYZ: "HELLOXYZ",
}

# in your app, you can use like
console.log(_env.ABC)
console.log(_env.XYZ)
```
