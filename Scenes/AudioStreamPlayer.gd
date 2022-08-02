extends AudioStreamPlayer

var incoming_call_idx

var stream_thread: Thread
var is_calling: bool = false

func _ready():
	Pjsip.connect("on_incoming_call", self,"_PJSIP_on_incoming_call")
	Pjsip.buffer_incoming_call_to_stream(get_stream_playback())

func _PJSIP_on_incoming_call(call_idx):
	print("incoming call: ", call_idx)
	incoming_call_idx = call_idx
	play()
	
	#re-add playback to incoming call buffer
	Pjsip.buffer_incoming_call_to_stream(get_stream_playback())
	
	# start streaming audio effect capture of bus: Microphone
	var idx = AudioServer.get_bus_index("Microphone")
	var audioeffectcapture:AudioEffectCapture = AudioServer.get_bus_effect(idx,1)
	
	if not stream_thread:
		print("thread created")
		stream_thread = Thread.new()
	if stream_thread.is_active():
		is_calling = false
		while stream_thread.is_alive():
			pass
		stream_thread.wait_to_finish()
	
	is_calling = true
	stream_thread.start(self, "stream_capture", [audioeffectcapture, incoming_call_idx])
	
func stream_capture(params: Array):
	var aec = params[0]
	var call_idx = params[1]
	
	var usec_delay = 20000
	var max_frame_length = 640
	while is_calling:
		var msec_start = OS.get_system_time_msecs()
		
		var frames_available = aec.get_frames_available()
		while frames_available >= max_frame_length:
			var buffer = aec.get_buffer(max_frame_length)
			Pjsip.push_frame(buffer, call_idx)
			frames_available -= max_frame_length
		
		var msec_taken = OS.get_system_time_msecs() - msec_start
		if msec_taken*1000 < usec_delay:
			OS.delay_usec(usec_delay - msec_taken*1000)
