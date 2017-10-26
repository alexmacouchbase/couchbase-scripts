#!/bin/sh

yum -y install gcc 

# iperf
tar -zxvf iperf-3-current.tar.gz
cd iperf-3.1.2/
./configure; make; make install
cd ..
