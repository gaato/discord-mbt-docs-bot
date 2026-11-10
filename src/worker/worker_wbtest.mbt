///|
// Public test fixture from discord/src/verify/verify_test.mbt, signed with
// a generated test key over the exact timestamp + UTF-8 body below.
let test_public_key = "b17f4787e67691b60c1d3c19e1c33f3d3df84bd6e20e212dbe5284c772de0704"

///|
let test_signature : String = "18bc501f1401f8c760948c22e08e9f7fec78206b8ef7a740b1f2b01f687429b52" +
  "cc352752102eccb7fd5aca53d92d49bb906d2aaba4a66d8ac89b6595bd85701"

///|
let test_timestamp = "1720951200"

///|
let test_ping =
  #|{"type":1,"id":"123456789012345678","application_id":"987654321098765432"}

///|
async test "Worker signature promise verifies exact timestamp and body" {
  assert_true(
    verify_signature(test_public_key, test_signature, test_timestamp, test_ping).wait(),
  )
  assert_false(
    verify_signature(
      test_public_key,
      test_signature,
      test_timestamp,
      test_ping + " ",
    ).wait(),
  )
  assert_false(
    verify_signature(
      test_public_key,
      test_signature,
      test_timestamp + "0",
      test_ping,
    ).wait(),
  )
}

///|
async test "Worker signature promise rejects malformed keys and signatures" {
  assert_false(
    verify_signature("", test_signature, test_timestamp, test_ping).wait(),
  )
  assert_false(
    verify_signature(test_public_key, "invalid", test_timestamp, test_ping).wait(),
  )
  assert_false(
    verify_signature("z".repeat(64), test_signature, test_timestamp, test_ping).wait(),
  )
}

///|
async test "Worker PING returns PONG and finishes background without REST" {
  let controller = @js_async.AbortController::new()
  let body =
    #|{"type":1,"id":"123456789012345678","application_id":"987654321098765432","token":"test-interaction-token","version":1}
  let dispatch = start_interaction("test-token", body, controller.signal())
  let response = dispatch.response().wait()
  assert_eq(response.kind(), "Reply")
  json_inspect(@json.parse(response.body()), content={ "type": 1 })
  dispatch.background().wait()
}
