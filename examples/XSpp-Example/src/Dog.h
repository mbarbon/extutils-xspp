#ifndef _Dog_h_
#define _Dog_h_

#include <Animal.h>
#include <string>

// Note: The implementation is in the header for simplicity only...

class Dog : public Animal {
public:
  Dog(const std::string& name);

  void Bark() const;
  void MakeSound() const;
};


#endif
