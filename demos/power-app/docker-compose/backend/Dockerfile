FROM node:11.4.0-alpine

RUN apk update && \
    apk add --no-cache vim wget curl

WORKDIR /kubeprimer-api/

ADD rootfs /

CMD ["npm", "start"]
