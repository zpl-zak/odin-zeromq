import "core:strings.odin"
import "core:fmt.odin"

using import "zeromq.odin"


main :: proc() {
	ctx := ctx_new();

	subscriber := socket(ctx, SUB);
	rc := connect(subscriber, "tcp://localhost:5556");
	assert(rc == 0);

	rc = setsockopt(subscriber, SUBSCRIBE, "10001 ");
	assert(rc == 0);

	for i in 0..15 {
		str := recv(subscriber);
		defer free(str);
		fmt.println("zipcode and temps:", str);
	}

	close(subscriber);
	ctx_term(ctx);
}