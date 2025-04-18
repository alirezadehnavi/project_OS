#include "types.h"
#include "riscv.h"
#include "defs.h"

void log_message(int level, const char* message) {
  const char* prefix;
  switch (level) {
    case 1: prefix = "INFO"; break;
    case 2: prefix = "WARN"; break;
    case 3: prefix = "ERROR"; break;
    default: prefix = "UNKNOWN";
  }
  printf("%s - %s\n", prefix, message);
}