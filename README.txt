Group Members:
==============
1. George Menjivar
2. Gonzalo Martinez
3. Ivkaran S. Sawhney

How to run:
===========

1. Open .imn file in CORE
2. Click the run button
3. Click on each node to open a console
4. Copy the source code to each node's path
5. On each node, type bash run.sh config <node_name>

SNDMSG:
=======

1. SNDMSG simply forwards the packet (with the message in the PAYLOAD field) till the dest is found.
2. When the packet reaches the dest, the message from the PAYLOAD field is displayed.

Ping:
=====

1. The PING messages are sent in a loop [NUMPINGS] times with a new seq number field starting from 0 and incrementing by 1.
2. The ack field is used as true/false/error. If the ack is false then src has sent a message to dest, if the ack is true then dest has sent an ack to src, and if the ack is error then that means the dest is unreachable so error is thrown.
3. The TIME_SENT field is used to show the time the PING message was sent.
4. When src receives an ack from dest, time difference (Time Now - Time Sent) is calculated, if it’s greater than the PING TIMEOUT, error is thrown, otherwise, it’s a success!

Security Extension: Onions Routing
==================================

We implemented Onion Routing just for SNGMSG since it’s using the PAYLOAD field. Similar to SNDMSG, we defined new message type “SECMSG.” To send encrypted messages, enter SECMSG <node_name> “message.”

Our algorithm is as follows:
1. On bootup, every node generates both a public and a private key. Their .pem files are stored in “/home/core” path.
2. The src node gets the path to a destination.
3. Work from backwards and create the packet layers by instantiating an Advanced Encryption Standard (AES), a symmetric block cipher with 128 bits of key and by using Cipher Block Chaining (CBC) mode. 
4. For every current node in the path, it needs to know the public RSA key of the next hop, which it uploads from “/home/core/public-<next_hop>.pem” file and generates an encrypted cipher token ("#{key}%%#{iv}”).
5. When messages are encapsulated in layers of encryption, src node then sends to the network.
6. Then, each node in the network uses its own private to decrypt the cipher token and use it to peel away a single layer of the message.
7. By following the same process at every node, dest node sees the original message that src node has meant to send.
8. This way, the src node and dest node remains anonymous, which is what we want.

NOTE: Because we used JSON, we were not able to save the encrypted message in json when forwarding packets, so we had to encode after encrypting the message when saving in JSON and decode before decrypting the message.