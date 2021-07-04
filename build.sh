#!/bin/bash
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install default-jdk wget git maven -y
cd /tmp/
git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git
cd /tmp/boxfuse-sample-java-war-hello/
mvn install
mvn package