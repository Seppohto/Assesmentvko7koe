#! /bin/bash
sudo apt-get update -y
sudo apt-get install python3-pip -y
pip3 install flask
cd /home/olli/
git clone https://github.com/Seppohto/Assesmentvko7koe.git
cd Ass*
pip3 install -r requirements.txt
flask run --host=0.0.0.0 --port=80