#ifndef _Dog_h_
#define _Dog_h_

#include <Animal.h>
#include <string>
#include <iostream>

// Note: The implementation is in the header for simplicity only...

class Dog: public Animal {
public:
  Dog(const std::string& name) : Animal(name) {}
  ~Dog() {};

  void Bark() { std::cout << "Woof" << std::endl; }
  void MakeSound() { Bark(); }
};


#endif
