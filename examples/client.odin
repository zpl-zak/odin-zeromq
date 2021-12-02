package examples

import "core:strings"
import "core:fmt"

import zeromq "../"

main :: proc() {
	using zeromq

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