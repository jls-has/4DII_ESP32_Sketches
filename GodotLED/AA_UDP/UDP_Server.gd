#https://forum.godotengine.org/t/how-to-use-udp-server/1928
class_name ServerNode
extends Node

var server := UDPServer.new()
var peers = []

func _ready():
	print(IP.get_local_addresses())
	print(server.listen(4242))

func _process(delta):
	#print(server.poll()) # Important!
	#print(server.is_listening())
	#print(server.is_connection_available())
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(packet)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)

	for i in range(0, peers.size()):
		pass # Do something with the connected peers.
