#!/bin/bash
SSH_PORT=$1

#Checking if SSH port was provided
if [ -z "$SSH_PORT" ]; then
    echo "Please provide SSH port as an argument"
    exit 1
fi

echo "=========================================="
echo "=== Starting to set the iptables rules ==="
echo "==========================================="

# Flushing iptables rules for starting with clean server
echo "--> Flushing any existing iptables rules"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Setting default policies 
echo "Setting default INPUT & FORWARD policies to DROP"
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT 
iptables -P FORWARD DROP 

#allow loopback
echo "Allow LoopBack traffic"
iptabels -A INPUT -i lo ACCEPT
iptables -A OUTPUT -j lo ACCEPT

#allow existing connections
echo "Allow conntrack..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

#allow ssh connection (via the custom port)
echo "Allow SSH connections"
iptables -A INPUT -p tcp --dport "$SSH_PORT" -j ACCEPT

#Allow ping
echo "Allow ICMP (Ping)"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

#Allow outgoing dns queries
echo "Allow outbound DNS queries"
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

#Allow dns anwers to get back to the server
echo "Allow inbound DNS queries"
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 53 -j ACCEPT

#allow openvpn connections
echo "Allow rules for openvpn connections"
iptables -A INPUT -p udp --dport 1194 -j ACCEPT #opening port 1194 udp
iptables -A INPUT -i tun+ -j ACCEPT 
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE

echo "=== Iptables rules set successfully ==="

#Show iptables state 
echo "---> The New Tables <---"
iptables -nvL
iptables -t nat -nvL




