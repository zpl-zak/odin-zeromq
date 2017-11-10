when ODIN_OS == "windows" {
	foreign import zeromq "libzmq.lib"
}

import "core:mem.odin"
import "core:strings.odin"

@(link_prefix="zmq_", default_calling_convention="c")
foreign zeromq {
	errno                  :: proc() -> int                                                                      ---;
	strerror               :: proc(errnum: int) -> ^u8                                                           ---;
	version                :: proc(major, minor, patch: ^int)                                                    ---;

	ctx_new                :: proc() -> ^Context                                                                 ---;
	ctx_term               :: proc(ctx: ^Context) -> int                                                         ---;
	ctx_shutdown           :: proc(ctx: ^Context) -> int                                                         ---;
	ctx_set                :: proc(ctx: ^Context, option, optval: int) -> int                                    ---;
	ctx_get                :: proc(ctx: ^Context, option: int) -> int                                            ---;

	msg_init               :: proc(msg: ^Message) -> int                                                         ---;
	msg_init_size          :: proc(msg: ^Message, size: uint) -> int                                             ---;
	msg_init_data          :: proc(msg: ^Message, data: rawptr, size: uint, ffn: Free_Proc, hint: rawptr) -> int ---;
	msg_send               :: proc(msg: ^Message, s: rawptr, flags: int) -> int                                  ---;
	msg_recv               :: proc(msg: ^Message, s: rawptr, flags: int) -> int                                  ---;
	msg_close              :: proc(msg: ^Message) -> int                                                         ---;
	msg_move               :: proc(dest: ^Message, src: ^Message) -> int                                         ---;
	msg_copy               :: proc(dest: ^Message, src: ^Message) -> int                                         ---;
	msg_data               :: proc(msg: ^Message) -> rawptr                                                      ---;
	msg_size               :: proc(msg: ^Message) -> uint                                                        ---;
	msg_more               :: proc(msg: ^Message) -> int                                                         ---;
	msg_get                :: proc(msg: ^Message, property: int) -> int                                          ---;
	msg_set                :: proc(msg: ^Message, property, optval: int) -> int                                  ---;
	msg_gets               :: proc(msg: ^Message, property: ^u8) -> ^u8                                          ---;

	socket                 :: proc(s: ^Context, typ: int) -> ^Socket                                             ---;
	close                  :: proc(s: ^Socket) -> int                                                            ---;
	setsockopt             :: proc(s: ^Socket, option: int, optval: rawptr, optvallen: uint) -> int              ---;
	getsockopt             :: proc(s: ^Socket, option: int, optval: rawptr, optvallen: ^uint) -> int             ---;
	bind                   :: proc(s: ^Socket, addr: ^u8) -> int                                                 ---;
	connect                :: proc(s: ^Socket, addr: ^u8) -> int                                                 ---;
	unbind                 :: proc(s: ^Socket, addr: ^u8) -> int                                                 ---;
	disconnect             :: proc(s: ^Socket, addr: ^u8) -> int                                                 ---;
	send                   :: proc(s: ^Socket, buf: rawptr, len: uint, flags: int) -> int                        ---;
	send_const             :: proc(s: ^Socket, buf: rawptr, len: uint, flags: int) -> int                        ---;
	recv                   :: proc(s: ^Socket, buf: rawptr, len: uint, flags: int) -> int                        ---;
	socket_monitor         :: proc(s: ^Socket, addr: ^u8, events: int) -> int                                    ---;

	proxy                  :: proc(frontend, backend, capture: rawptr) -> int                                    ---;
	proxy_steerable        :: proc(frontend, backend, capture, control: rawptr) -> int                           ---;

	has                    :: proc(capability: ^u8) -> int                                                       ---;

	z85_encode             :: proc(dest: ^u8, data: ^u8, size: uint) -> ^u8                                      ---;
	z85_decode             :: proc(dest: ^u8, str: ^u8) -> ^u8                                                   ---;
	curve_keypair          :: proc(z85_public_key, z85_secret_key: ^u8) -> int                                   ---;
	curve_public           :: proc(z85_public_key, z85_secret_key: ^u8) -> int                                   ---;

	atomic_counter_new     :: proc() -> ^Atomic_Counter                                                          ---;
	atomic_counter_set     :: proc(counter: ^Atomic_Counter, value: int)                                         ---;
	atomic_counter_inc     :: proc(counter: ^Atomic_Counter) -> int                                              ---;
	atomic_counter_dec     :: proc(counter: ^Atomic_Counter) -> int                                              ---;
	atomic_counter_value   :: proc(counter: ^Atomic_Counter) -> int                                              ---;
	atomic_counter_destroy :: proc(counter: ^^Atomic_Counter)                                                    ---;

	poller_new             :: proc() -> ^Poller                                                                  ---;
	poller_destroy         :: proc(p: ^^Poller) -> int                                                           ---;
	poller_add             :: proc(p: ^Poller, socket, user_data: rawptr, events: u16) -> int                    ---;
	poller_modify          :: proc(p: ^Poller, socket: rawptr, events: u16) -> int                               ---;
	poller_remove          :: proc(p: ^Poller, socket: rawptr) -> int                                            ---;
	poller_wait            :: proc(p: ^Poller, pe: ^Poller_Event, timeout: c_long) -> int                        ---;
	poller_wait_all        :: proc(p: ^Poller, pe: ^Poller_Event, n_events: int, timeout: c_long) -> int         ---;
	poller_add_fd          :: proc(p: ^Poller, fd: int, user_data: rawptr, events: u16) -> int                   ---;
	poller_modify_fd       :: proc(p: ^Poller, fd: int, events: u16) -> int                                      ---;
	poller_remove_fd       :: proc(p: ^Poller, fd: int) -> int                                                   ---;
	socket_get_peer_state  :: proc(socket: rawptr, routing_id: rawptr, routing_id_size: uint) -> int             ---;
	pool                   :: proc(items: ^[]Poll_Item, nitems: int, timeout: c_long) -> int                     ---;
}

bind :: proc(s: ^Socket, addr: string) -> int {
	return bind(s, &addr[0]);
}

connect :: proc(s: ^Socket, addr: string) -> int {
	return connect(s, &addr[0]);
}

setsockopt :: proc(s: ^Socket, option: int, optval: string) -> int {
	return setsockopt(s, option, cast(rawptr)&optval[0], cast(uint)len(optval));
}

s_recv :: proc(s: ^Socket) -> string {
	msg := Message{};
	msg_init(&msg);
	size := msg_recv(&msg, s, 0);
	if size == -1 do return "";
	str := make([]u8, size+1);
	mem.copy(&str[0], msg_data(&msg), size);
	msg_close(&msg);
	str[size] = 0;
	ret := strings.to_odin_string(&str[0]);
	return ret;
}

s_send :: proc(s: ^Socket, str: string) -> int {
	msg := Message{};
	msg_init_size(&msg, cast(uint)len(str));
	mem.copy(msg_data(&msg), &str[0], len(str));
	size := msg_send(&msg, s, 0);
	msg_close(&msg);
	return size;
}

s_sendmore :: proc(s: ^Socket, str: string) -> int {
	msg := Message{};
	msg_init_size(&msg, cast(uint)len(str));
	mem.copy(msg_data(&msg), &str[0], len(str));
	size := msg_send(&msg, s, SNDMORE);
	msg_close(&msg);
	return size;
}

Context        :: struct #ordered {}
Socket         :: struct #ordered {}
Atomic_Counter :: struct #ordered {}
Poller         :: struct #ordered {}

Message :: struct #ordered {
	data: [64]u8,
}

Poller_Event :: struct #ordered {
	socket: rawptr,
	fd: int, // TODO(zaklaus): Double check this!
	user_data: rawptr,
	events: u16,
}

Poll_Item :: struct #ordered {
	socket: rawptr,
	fd: int, // TODO(zaklaus): Double check this!
	events: u16,
	revents: u16,
}

// Context options
IO_THREADS            :: 1;
MAX_SOCKETS           :: 2;
THREAD_PRIORITY       :: 3;
THREAD_SCHED_PRIORITY :: 4;
MAX_MSGSZ             :: 5;

// Context defaults
IO_THREADS_DFLT          :: 1;
MAX_SOCKETS_DFLT         :: 1023;
THREAD_PRIORITY_DLFT     :: -1;
THREAD_SCHED_POLICY_DFLT :: -1;

// Socket types
PAIR   :: 0;
PUB    :: 1;
SUB    :: 2;
REQ    :: 3;
REP    :: 4;
DEALER :: 5;
ROUTER :: 6;
PULL   :: 7;
PUSH   :: 8;
XPUB   :: 9;
XSUB   :: 10;
STREAM :: 11;

// Socket options
AFFINITY                 :: 4;
ROUTING_ID               :: 5;
SUBSCRIBE                :: 6;
UNSUBSCRIBE              :: 7;
RATE                     :: 8;
RECOVERY_IVL             :: 9;
SNDBUF                   :: 11;
RCVBUF                   :: 12;
RCVMORE                  :: 13;
FD                       :: 14;
EVENTS                   :: 15;
TYPE                     :: 16;
LINGER                   :: 17;
RECONNECT_IVL            :: 18;
BACKLOG                  :: 19;
RECONNECT_IVL_MAX        :: 21;
MAXMSGSIZE               :: 22;
SNDHWM                   :: 23;
RCVHWM                   :: 24;
MULTICAST_HOPS           :: 25;
RCVTIMEO                 :: 27;
SNDTIMEO                 :: 28;
LAST_ENDPOINT            :: 32;
ROUTER_MANDATORY         :: 33;
TCP_KEEPALIVE            :: 34;
TCP_KEEPALIVE_CNT        :: 35;
TCP_KEEPALIVE_IDLE       :: 36;
TCP_KEEPALIVE_INTVL      :: 37;
IMMEDIATE                :: 39;
XPUB_VERBOSE             :: 40;
ROUTER_RAW               :: 41;
IPV6                     :: 42;
MECHANISM                :: 43;
PLAIN_SERVER             :: 44;
PLAIN_USERNAME           :: 45;
PLAIN_PASSWORD           :: 46;
CURVE_SERVER             :: 47;
CURVE_PUBLICKEY          :: 48;
CURVE_SECRETKEY          :: 49;
CURVE_SERVERKEY          :: 50;
PROBE_ROUTER             :: 51;
REQ_CORRELATE            :: 52;
REQ_RELAXED              :: 53;
CONFLATE                 :: 54;
ZAP_DOMAIN               :: 55;
ROUTER_HANDOVER          :: 56;
TOS                      :: 57;
CONNECT_ROUTING_ID       :: 61;
GSSAPI_SERVER            :: 62;
GSSAPI_PRINCIPAL         :: 63;
GSSAPI_SERVICE_PRINCIPAL :: 64;
GSSAPI_PLAINTEXT         :: 65;
HANDSHAKE_IVL            :: 66;
SOCKS_PROXY              :: 68;
XPUB_NODROP              :: 69;
BLOCKY                   :: 70;
XPUB_MANUAL              :: 71;
XPUB_WELCOME_MSG         :: 72;
STREAM_NOTIFY            :: 73;
INVERT_MATCHING          :: 74;
HEARTBEAT_IVL            :: 75;
HEARTBEAT_TTL            :: 76;
HEARTBEAT_TIMEOUT        :: 77;
XPUB_VERBOSER            :: 78;
CONNECT_TIMEOUT          :: 79;
TCP_MAXRT                :: 80;
THREAD_SAFE              :: 81;
MULTICAST_MAXTPDU        :: 84;
VMCI_BUFFER_SIZE         :: 85;
VMCI_BUFFER_MIN_SIZE     :: 86;
VMCI_BUFFER_MAX_SIZE     :: 87;
VMCI_CONNECT_TIMEOUT     :: 88;
USE_FD                   :: 89;

// Message options
MORE   :: 1;
SHARED :: 3;

// Send/Recv options
DONTWAIT :: 1;
SNDMORE  :: 2;

// Security mechanisms
NULL   :: 0;
PLAIN  :: 1;
CURVE  :: 2;
GSSAPI :: 3;

// RADIO-DISH protocol
GROUP_MAX_LENGTH :: 15;

// Socket transport events (TCP, IPC and TIPC only)
EVENT_CONNECTED       :: 0x0001;
EVENT_CONNECT_DELAYED :: 0x0002;
EVENT_CONNECT_RETRIED :: 0x0004;
EVENT_LISTENING       :: 0x0008;
EVENT_BIND_FAILED     :: 0x0010;
EVENT_ACCEPTED        :: 0x0020;
EVENT_ACCEPT_FAILED   :: 0x0040;
EVENT_CLOSED          :: 0x0080;
EVENT_CLOSE_FAILED    :: 0x0100;
EVENT_DISCONNECTED    :: 0x0200;
EVENT_MONITOR_STOPPED :: 0x0400;
EVENT_ALL             :: 0xFFFF;

// I/O multiplexing
POLLIN  :: 1;
POLLOUT :: 2;
POLLERR :: 4;
POLLPRI :: 8;

Free_Proc :: #type proc "c" (data, hint: rawptr);
