FROM --platform=$BUILDPLATFORM node:lts-alpine AS build
WORKDIR /build
COPY package.json .
COPY package-lock.json .
RUN npm install
COPY . .
RUN npm run build

FROM node:lts-alpine
EXPOSE 8080

ENV DOCKER_CONTENT_TRUST=1

WORKDIR /app
COPY --from=build /build/src/global.json .
COPY --from=build /build/dist/webserver.js .


#LABEL chekingsecurity="selinux"
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1

RUN adduser -D finbox

# Set ownership of the working directory to the non-root user
RUN chown -R finbox:finbox /app

# Switch to the non-root user
USER finbox


ENTRYPOINT [ "node", "webserver" ]


ARG MEMORY_LIMIT=536870912
ENV MEMORY_LIMIT=${MEMORY_LIMIT}

# For example, to set CPU shares to 512
ARG CPU_SHARES=512
ENV CPU_SHARES=${CPU_SHARES}



# Mount the root filesystem as read-only
VOLUME /app
