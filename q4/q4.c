#include <stdio.h>
#include <string.h>
#include <dlfcn.h>
#include <stdlib.h>

typedef int (*op_func_type)(int, int);

int main() {
    int num1, num2;
    char op[6], libName[50];
    
    char current_op[6] = "";
    void *current_handle = NULL;
    op_func_type current_operation = NULL;

    while (scanf("%s %d %d", op, &num1, &num2) == 3) {
        
        // if the operation changed, we need to swap libraries
        if (strcmp(op, current_op) != 0) {
            
            // Close the old library FIRST to ensure we never exceed 2GB threshold (1.5 + 1.5)
            if (current_handle != NULL) {
                dlclose(current_handle);
                current_handle = NULL;
            }

            sprintf(libName, "./lib%s.so", op);

            // RTLD_LAZY is much faster/efficient on massive 1.5GB files
            current_handle = dlopen(libName, RTLD_LAZY);
            if (!current_handle) {
                fprintf(stderr, "Error loading library: %s\n", dlerror());
                current_op[0] = '\0'; // reset tracking variable
                continue;
            }

            dlerror(); // Clear old errors
            current_operation = (op_func_type) dlsym(current_handle, op);
            
            char *error = dlerror();
            if (error != NULL) {
                fprintf(stderr, "Error finding function %s: %s\n", op, error);
                
                dlclose(current_handle); // Fixed Memory Leak
                current_handle = NULL;
                current_op[0] = '\0';
                continue;
            }
            
            strcpy(current_op, op); // Cache that we successfully loaded this operation
        }

        // execute the function and print the result
        int result = current_operation(num1, num2);
        printf("%d\n", result);
    }

    // Clean up at the very end
    if (current_handle != NULL) {
        dlclose(current_handle);
    }

    return 0;
}
