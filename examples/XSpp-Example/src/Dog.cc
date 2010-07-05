#include "Dog.h"
#include <string>
#include <iostream>

using namespace std;

Dog::Dog(const std::string& name)
  : Animal(name)
{}

void
Dog::Bark()
  const
{
  cout << "Woof" << endl;
}

void
Dog::MakeSound()
  const
{
  Bark();
}

