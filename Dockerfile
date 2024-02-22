# Use latest stable channel SDK.
FROM dart:stable AS build

# Resolve app dependencies.
WORKDIR /app
COPY . .
 
RUN dart pub get

# Copy app source code (except anything in .dockerignore) and AOT compile app.
# Copy app source code (except anything in .dockerignore) and AOT compile app.
RUN dart compile exe lib/launchgame.dart -o bin/gameserver
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/gameserver /app/bin/

# Start server.
EXPOSE 8080 
CMD ["/app/bin/gameserver"]
