#! /bin/bash
sudo apt-get update -y
sudo apt-get install python3-pip -y
sudo pip3 install flask
cd /home/olli/
git clone https://github.com/runeli/assesment-test.git
cd /ass*
flask run --host=0.0.0.0 --port=80