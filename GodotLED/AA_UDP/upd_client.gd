# client_node.gd
class_name ClientNode
extends Node

var udp := PacketPeerUDP.new()
var connected = false

func _ready():
	udp.connect_to_host("127.0.0.1", 4242)

func _process(delta):
	udp.connect_to_host("127.0.0.1", 4242)

	if !connected:
		# Try to contact server
		udp.put_packet("The answer is... 42!".to_utf8_buffer())
	if udp.get_available_packet_count() > 0:
		print("Connected: %s" % udp.get_packet().get_string_from_utf8())
		connected = true
