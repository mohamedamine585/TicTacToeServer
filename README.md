A double servers app built using [dart:io] package (https://pub.dev/packages/io),
configured to enable running with [Docker](https://www.docker.com/).

This sample code handles HTTP POST,GET,PUT,DELETE requests to the authserver and a websocket to the gameserver.

# Running the sample

## Running with the Dart SDK

You can run the example with the [Dart SDK](https://dart.dev/get-dart)
like this:

```
$ dart run bin/main.dart
Game server is running on 0.0.0.0 port 8080
Auth server is running on 0.0.0.0 port 8081
```

Sign up:
```
POST http://0.0.0.0:8081/Signup with body : {"palyername" : "<your name>" , "password" : "<your password>"}
response:
player is signed in

```
Sign up:
```

$ GET http://0.0.0.0:8081/Signin/palyername=<yourname>&password=<your password>
response:
player is signed in
```
Change Name:
```

$ PUT http://0.0.0.0:8081/ChangeName with body : {"palyername" : "<your name>" , "password" : "<your password>","new_name":"<your new name>"}
response :
playername changed to <your new name>
```

## Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed, you
can build and run with the `docker` command:

```
$ docker build . -t myserver
$ docker run -it -p 8080:8080 myserver
Server listening on port 8080
```

And then from a second terminal:
```
$ curl http://0.0.0.0:8080
Hello, World!
$ curl http://0.0.0.0:8080/echo/I_love_Dart
I_love_Dart
```
