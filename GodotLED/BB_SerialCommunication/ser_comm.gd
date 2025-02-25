@tool
extends SerComm

@export var message : String
@export var send : bool = false :
	set(value):
		if open_serial():
			write_serial(message)
		else:
			print("serial closed!")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(list_serial_ports())
	print(open_serial())
	if open_serial():
		on_message.connect(message_read)

func message_read(m):
	print(m)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  #var in = waiting_input_bytes();
  #var read = read_serial(in);
  #print(read);
	pass

func _exit_tree() -> void:
	close_serial()
