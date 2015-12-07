FROM mhart/alpine-node:base-5.1.1

WORKDIR /src
COPY package.json ./package.json
COPY lib ./lib/
COPY node_modules ./node_modules/

EXPOSE 8000
CMD ["node", "lib/cli.js"]
