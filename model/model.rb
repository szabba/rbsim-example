program :wget do |opts|
	sent = 0
	on_event :send do
		cpu do |cpu|
			(150 / cpu.performance).miliseconds
		end
		send_data to: opts[:target], size: 1024.bytes, type: :request, content: sent
		sent += 1
		register_event :send, delay: 5.miliseconds if sent < opts[:count]
	end

	on_event :data_received do |data|
		log "Got data #{data} in process #{process.name}"
		stats event: :request_served, client: process.name
	end

	register_event :send
end

program :apache do
	on_event :data_received do |data|
		stats_start server: :apache, name: process.name
		cpu do |cpu|
			(100 * data.size.in_bytes / cpu.performance).miliseconds
		end
		send_data to: data.src, size: data.size * 10, type: :response, content: data.content
		stats_stop server: :apache, name: process.name
	end
end

node :desktop do
	cpu 100
end

node :gandalf do
	cpu 1400
end

new_process :client1, program: :wget, args: { target: :server, count: 10 }
new_process :client2, program: :wget, args: { target: :server, count: 10 }
new_process :server, program: :apache

net :net01, bw: 1024.bps
net :net02, bw: 510.bps

route from: :desktop, to: :gandalf, via: [ :net01, :net02 ], twoway: true

put :server, on: :gandalf
put :client1, on: :desktop
put :client2, on: :desktop

