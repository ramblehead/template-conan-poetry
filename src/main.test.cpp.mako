## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = utils.pascal_case(config["project_name"])
%>\
// Hey Emacs, this is -*- coding: utf-8 -*-

// NOLINTBEGIN(misc-include-cleaner)

#include "main.hpp"
#include <boost/test/tools/old/interface.hpp>

#define BOOST_TEST_MODULE ${project_name}
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_CASE(binary_gap) {
  // BOOST_REQUIRE_EQUAL(solution(42), 42);
  // BOOST_REQUIRE_NE(solution(42), 43);
}

// NOLINTEND(misc-include-cleaner)

// #include <cassert>
// #include <concepts/concepts.hpp>
// #include <iostream>

// auto main(int /*argc*/, char* /*argv*/[]) -> int {
//   assert(warp() == 42);

//   std::cout << "Tests passed!" << std::endl;

//   return EXIT_SUCCESS;
// }
