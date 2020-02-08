
# elm-tester-candidate

A tool for technical interviewing Q&A engineers.
- A broken (deliberately buggy) calculator webapp
  - a webservice to test
	```
	$ curl -v -X POST -H "Content-Type: application/json" -d "{\"operator\":\"ADD\",\"operands\":[\"1\",\"2\"]}" http://localhost:8080/calculator/
	```
  - with a broken frontend at `http://localhost:8080/calculator/spa`
- An issue tracker webapp
  - a user service endpoint: `http://localhost:8080/user/`
  - an issue tracker endpoint: `http://localhost:8080/issue/`
  - issues of a given user are at `http://localhost:8080/exportissues/user/<ID>`
  - finally, an issue report generator (HTML): `http://localhost:8080/exportissues/user/<ID>`
  - frontend is at `http://localhost:8080/issue/spa`

## Service

Under `tester-candidate/` written in Java (8), Spring Boot.

### Install
Probably only Java (8) is required, as Gradle Wrapper is used.

### Develop

- Run unit tests with
  - `./gradlew test`
- Just start the stuff for testing
  - `./gradlew bootRun`
- Build the distribution
  - `./gradlew bootDistZip` (or `bootDistTar`)

### Usage

Database is created under `~/tester-candidate-h2-db.mv.db` on first run.

While there is already service endpoint for users, there is no webapp
managing them, nor there is any way to prevent one user (Q&A candidate)
checking the stuff written by others.
- Work in progress.

Currently the IssueTracker
- assumes that there is at least one user created already,
- it does download them, on the startup and takes the first one into use.

So, for now, the best is to create a DB for every candidate, and init, using
CURL:
```
(tester-candidate service is running)
$ curl -X POST -H "Content-Type: application/json" -d "{\"firstName\":\"QA\",\"lastName\":\"Candidate\"}" http://localhost:8080/user/
```


## IssueTracker webapp

Under `webapp/issuetracker`, written in Elm 0.19.

### Install

- node and npm
- Elm 0.19
- elm-test (with npm)
- `npm install`
- (maybe) `elm make src/Main.elm --output temp.html`
	- to get Elm packages pulled in, CHECK: is this necessary?

### Develop

- Run unit tests
  - `elm-test`
- Building the Elm app
  - `npm run build`
- built app distribution is under `dist/`
- copying the built Elm distribution to the Spring Boot distribution
  - `npm run deploy`
  - after which you can create a distro of the `tester-candidate`, see above.

## Further (planned) work
- Create a broken (deliberately) Calculator webapp, using the broken Calculator service endpoint
  - for verifying manual testing capabilities of Q&A candidate
- Provide a sample BDD test setup (Robot?), testing the Calculator webservice
  - for verifying test scripting capabilities of Q&A candidate
- rename incorrect endpoint URI paths (issue/ -> issues/, etc)
- proper user management
