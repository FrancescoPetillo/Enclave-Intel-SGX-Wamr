#include <stdio.h> 
#include <string.h> 
int main(int argc, char** argv) { 
  const char *out = "out.txt"; 
  const char *msg = (argc>1)? argv[1] : "Hello from WASM inside SGX (SIM) via WAMR!\n"; 
  FILE *f = fopen(out, "w"); 
  if (!f) { perror("fopen"); return 1; } 
  fwrite(msg, 1, strlen(msg), f); 
  fclose(f); 
  printf("Wrote %zu bytes to %s\n", strlen(msg), out); 
  return 0; 
} 