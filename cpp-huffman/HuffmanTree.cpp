// Name: Nicholas Keenan
// This file contains the implementation of the HuffmanTree class.
#include "HuffmanTree.hpp"

HuffmanTree::~HuffmanTree() {
    destroyTree(root);
}

void HuffmanTree::destroyTree(HuffmanNode* node) {
    if (node != nullptr) {
        destroyTree(node->left);
        destroyTree(node->right);
        delete node;
    }
}

std::string HuffmanTree::compress(const std::string inputStr) {
    // This is to clean any existing trees.
    destroyTree(root);
    root = nullptr;

    // This is to count the
    // frequency of each character.
    std::map<char, int> freqMap;
    for (char c : inputStr) {
        freqMap[c]++;
    }

    // This is to create a priority
    // queue of nodes.
    HeapQueue<HuffmanNode*, HuffmanNode::Compare> pq;
    for (const auto& pair : freqMap) {
        // This creates a new node with the character and its frequency,
        // while assuming the constructor takes character and frequency
        // in that order.
        HuffmanNode* node = new HuffmanNode(pair.first, pair.second);
        pq.insert(node);
    }

    // This while loop builds the
    // Huffman tree.
    while (pq.size() > 1) {
        HuffmanNode* left = pq.min();
        pq.removeMin();

        HuffmanNode* right = pq.min();
        pq.removeMin();

        // This creates a new internal node with the two prev
        // nodes as children.
        int combinedFreq = left->getFrequency() + right->getFrequency();
        HuffmanNode* internal = new HuffmanNode('\0', combinedFreq);
        internal->left = left;
        internal->right = right;

        pq.insert(internal);
    }

    // The last remaining node is
    // serves as the root of the Huffman tree.
    if (!pq.empty()) {
        root = pq.min();
        pq.removeMin();
    }

    // This builds a table of character codes.
    std::map<char, std::string> encodingMap;
    buildEncodingMap(root, "", encodingMap);

    // This encodes the input string.
    std::string result;
    for (char c : inputStr) {
        result += encodingMap[c];
    }

    return result;
}

void HuffmanTree::buildEncodingMap(HuffmanNode* node, std::string code, std::map<char, std::string>& encodingMap) {
    if (node == nullptr) {
        return;
    }

    // If this is a leaf node,
    // add the character and
    // the code to the map.
    if (node->left == nullptr && node->right == nullptr) {
        encodingMap[node->getCharacter()] = code;
    }

    // Recursive calls for
    // the left and right children.
    buildEncodingMap(node->left, code + "0", encodingMap);
    buildEncodingMap(node->right, code + "1", encodingMap);
}

std::string HuffmanTree::serializeTree() const {
    std::string result;
    serializeTreeHelper(root, result);
    return result;
}

void HuffmanTree::serializeTreeHelper(HuffmanNode* node, std::string& result) const {
    if (node == nullptr) {
        return;
    }

    // This is for Post-order traversal.
    serializeTreeHelper(node->left, result);
    serializeTreeHelper(node->right, result);

    // If it's a leaf node,
    // add 'L' and the character.
    if (node->left == nullptr && node->right == nullptr) {
        result += "L";
        result += node->getCharacter();
    } else {
        result += "B";
    }
}

std::string HuffmanTree::decompress(const std::string inputCode, const std::string serializedTree) {
    // This cleans up an existing tree.
    destroyTree(root);
    root = nullptr;

    // This deserializes the tree.
    int index = 0;
    root = deserializeTree(serializedTree, index);

    // This uses the tree to decode the input.
    std::string result;
    HuffmanNode* current = root;

    for (char bit : inputCode) {
        if (bit == '0') {
            current = current->left;
        } else {
            current = current->right;
        }

        // If we've reached a leaf node,
        // function should add the character
        // to the result and go back to the root
        if (current->left == nullptr && current->right == nullptr) {
            result += current->getCharacter();
            current = root;
        }
    }

    return result;
}

HuffmanNode* HuffmanTree::deserializeTree(const std::string& serialized, int& index) {
    // This processes the serialized tree,
    // and builds the tree in postorder
    std::stack<HuffmanNode*> nodeStack;

    for (int i = 0; i < serialized.length(); i++) {
        if (serialized[i] == 'L') {
            // This is for a leaf node, it creates a
            // new node with the next character.
            // Frequency doesn't matter.
            i++;
            HuffmanNode* leaf = new HuffmanNode(serialized[i], 0);
            nodeStack.push(leaf);
        } else if (serialized[i] == 'B') {
            // This is for a branch node, it pops the top two nodes and
            // makes them children of a new internal node.
            HuffmanNode* right = nodeStack.top();
            nodeStack.pop();
            HuffmanNode* left = nodeStack.top();
            nodeStack.pop();

            HuffmanNode* internal = new HuffmanNode('\0', 0);
            internal->left = left;
            internal->right = right;

            nodeStack.push(internal);
        }
    }

    // The last node on the stack is the root
    // of the tree.
    return nodeStack.empty() ? nullptr : nodeStack.top();
}