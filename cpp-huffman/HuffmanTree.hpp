// Name: Nicholas Keenan
// This file serves as the header file for the
// HuffmanTree class and the source file.

// These are the macros and guards.
#ifndef HUFFMAN_TREE_HPP
#define HUFFMAN_TREE_HPP

#include "HuffmanBase.hpp"
#include "HeapQueue.hpp"
#include <map>
#include <stack>
#include <string>
#include <vector>

// This is the class definition
// that lists out the functions
// for the HuffmanTree class.
class HuffmanTree : public HuffmanTreeBase {
private:
    HuffmanNode* root;

    // These are helper methods
    // for the class.
    void destroyTree(HuffmanNode* node);
    void buildEncodingMap(HuffmanNode* node, std::string code, std::map<char, std::string>& encodingMap);
    void serializeTreeHelper(HuffmanNode* node, std::string& result) const;
    HuffmanNode* deserializeTree(const std::string& serialized, int& index);

public:
    HuffmanTree() : root(nullptr) {}
    ~HuffmanTree();

    // These are the required
    // methods from abstract class.
    std::string compress(const std::string inputStr);
    std::string serializeTree() const;
    std::string decompress(const std::string inputCode, const std::string serializedTree);
};

// This is the end of the guard.
#endif // HUFFMAN_TREE_HPP