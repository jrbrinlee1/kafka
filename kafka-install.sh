#!/bin/bash

# kafka specs
KAFKA_RELEASE=3.0.1
KAFKA_VERSION=kafka_2.12-3.0.1

# install kakfa
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
sudo mkdir /home/ec2-user/kafka
sudo wget -P /home/ec2-user/kafka/ https://downloads.apache.org/kafka/$KAFKA_RELEASE/$KAFKA_VERSION.tgz
sudo tar -xvzf /home/ec2-user/kafka/$KAFKA_VERSION.tgz --strip 1 -C /home/ec2-user/kafka/
sudo useradd kafka
sudo chown ec2-user:ec2-user -R /home/ec2-user/kafka
sudo pip3 install kafka-python

sudo touch /etc/systemd/system/kafka-zookeeper.service
sudo touch /etc/systemd/system/kafka.service

sudo tee /etc/systemd/system/kafka-zookeeper.service <<EOL
[Unit]
Description=Apache Zookeeper server (Kafka)
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=ec2-user
#Environment=JAVA_HOME=/usr/bin/java
ExecStart=/home/ec2-user/kafka/bin/zookeeper-server-start.sh /home/ec2-user/kafka/config/zookeeper.properties
ExecStop=/home/ec2-user/kafka/bin/zookeeper-server-stop.sh

[Install]
WantedBy=multi-user.target
EOL

sudo tee sudo /etc/systemd/system/kafka.service <<EOL
[Unit]
Description=Apache Kafka server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target kafka-zookeeper.service

[Service]
Type=simple
User=ec2-user
#Environment=JAVA_HOME=/usr/bin/java
ExecStart=/home/ec2-user/kafka/bin/kafka-server-start.sh /home/ec2-user/kafka/config/server.properties
ExecStop=/home/ec2-user/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl enable --now kafka-zookeeper.service
sudo systemctl enable --now kafka.service

sudo cat > example.txt <<EOL

Small Test

Create Topic
bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --topic data  --partitions 4 --replication-factor 1

Confirm it was created
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
bin/kafka-topics.sh --describe --topic data --bootstrap-server localhost:9092

Write to the topic
bin/kafka-console-producer.sh --bootstrap-server localhost:9092 --topic data

Paste the records below one at a time.
{"id": "1", "group": "100", "seg": "1"} 
{"id": "2", "group": "110", "seg": "2"} 
{"id": "3", "group": "130", "seg": "3"}
{"id": "2", "group": "120", "seg": "6"}

crtl+c to get out of the console producer.

Confirm the records were successfully written to the topic
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic data --from-beginning

crtl+c to get out of the console consumer.

Delete the topic.
bin/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic data

Confirm it deleted.
bin/kafka-topics.sh --list --bootstrap-server localhost:9092
EOL
