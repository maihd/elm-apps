module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

suite : Test
suite =
    test "3 * 2 = 6"
        (\_ -> Expect.equal 6 (3 * 2))