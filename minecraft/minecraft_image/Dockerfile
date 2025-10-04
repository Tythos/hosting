# set up initial image config
FROM eclipse-temurin:21-jre-jammy
ARG SERVER_JAR_URL=https://piston-data.mojang.com/v1/objects/11e54c2081420a4d49db3007e66c80a22579ff2a/server.jar
WORKDIR /minecraft

# install deps
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# config files
RUN echo "eula=true" > eula.txt
COPY server.properties .
COPY whitelist.json .
COPY ops.json .

# download server jar, expose, run
RUN curl -o server.jar -L "${SERVER_JAR_URL}"
EXPOSE 25565
ENTRYPOINT ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "--nogui"]
