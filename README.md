# CS 1632 Deliverable 4: Performance Testing

## Info

Jeremy Kato & Danielle Moonah
MW @ 1pm Period

## Installation

Run `bundle install` to install the appropriate gems. If there are any errors, try `gem install` on any libraries that cause issues.

# Testing Notes

Code coverage will be off for parallel engine if you run verifier_test.rb first - the tests for parallel engine are in parallel_engine_test.rb, and that will produce the correct code coverage.

# Flamegraph Note

Flamegraph is not in the release version as it slows execution - see previous commits to see flamegraph usage if you're curious!