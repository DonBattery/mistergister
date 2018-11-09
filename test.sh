#!/bin/bash

oneTimeSetUp() {
  echo "Testing Mister Gister..."
  echo
  . ./mistergister.sh
}

testVersion() {
  dummyVer="0.1.0"
  assertEquals "MRGISTER_VERSION should be a 5 character long string" ${#dummyVer} ${#MRGISTER_VERSION}
}

oneTimeTearDown() {
  echo "End of testing..."
}

# Load shUnit2.
. shunit2/shunit2