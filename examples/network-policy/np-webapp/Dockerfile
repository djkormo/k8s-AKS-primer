FROM maven:3.5.2-jdk-8 AS build  
COPY src /usr/src/app/src  
COPY pom.xml /usr/src/app  
RUN mvn -f /usr/src/app/pom.xml clean package

FROM openjdk:8  
COPY --from=build /usr/src/app/target/sentiment-analysis-web-0.0.1-SNAPSHOT.jar /usr/app/sentiment-analysis-web-0.0.1-SNAPSHOT.jar 
ENV SA_LOGIC_API_URL http://localhost:5000
EXPOSE 8080  
ENTRYPOINT ["java","-jar","/usr/app/sentiment-analysis-web-0.0.1-SNAPSHOT.jar", "--sa.logic.api.url=${SA_LOGIC_API_URL}"]  
