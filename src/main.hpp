#pragma once
// Hey Emacs, this is -*- coding: utf-8 -*-

#include <cassert>
#include <cstdint>

inline auto solution(std::int32_t N) -> std::int32_t {
  assert(N >= 1 && N <= 2'147'483'647);
  return N;
}
