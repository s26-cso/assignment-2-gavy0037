#include <stdio.h>

// struct Node {
//     int val;
//     struct Node* left;
//     struct Node* right;
// };

struct Node* make_node(int val); // Returns a pointer to a struct with thegiven value and left and right pointers set to NULL.

struct Node* insert(struct Node* root, int val); // insert a node with valueval into the tree with the given root. Return the root.

struct Node* get(struct Node* root, int val); // Return a pointer to a nodewith value val in the tree. Return NULL if no such node exists.

int getAtMost(int val, struct Node* root); // Return the greatest valuepresent in the tree which is <= val. Return -1 if no such node exists.

