#ifndef _Animal_h_
#define _Animal_h_

#include <string>
#include <iostream>
#include <exception>

// Note: The implementation is in the header for simplicity only...

class CannotMakeSoundException : public std::exception {
public:
  virtual const char* what() const throw()
  { return "This animal does not make sounds."; }
};

class Animal {
public:
  Animal(const std::string& name) : fName(name) {}
  ~Animal() {};

  void SetName(const std::string& newName) { fName = newName; }
  std::string GetName() { return fName; }

  void MakeSound() {
    throw CannotMakeSoundException();
  }

private:
  std::string fName;
};

#endif
