import "core:strings.odin"
import "core:fmt.odin"

using import "zeromq.odin"

main :: proc() {
	ctx := ctx_new();

	publisher := socket(ctx, PUB);
	rc := bind(publisher, "tcp://*:5556");
	assert(rc == 0);

	buf := make([]u8, 20);
	defer free(buf);
	cnt := 0;

	fmt.println("Broadcasting weather data...");

	for {
		zipcode := cnt % 2 == 0 ? 10001 : 10000;
		temps := cnt % 3 == 0 ? 32 : 23;

		data := fmt.bprintf(buf, "%05d %d", zipcode, temps);
		send(publisher, data);

		cnt += 1;
		if cnt > 10 do cnt = 0;
	}

	close(publisher);
	ctx_term(ctx);
}