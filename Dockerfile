##artifact build stage
FROM maven AS buildstage
RUN mkdir /var/src/app
WORKDIR /var/src/app
COPY . .
RUN mvn clean install    ## artifact -- .war

### tomcat deploy stage
FROM tomcat
WORKDIR webapps
COPY --from=buildstage /var/src/app/target/*.war .
RUN rm -rf ROOT && mv *.war ROOT.war
EXPOSE 8080
