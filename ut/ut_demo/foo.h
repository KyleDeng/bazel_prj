#ifndef __FOO_H__
#define __FOO_H__

#include <string>

struct Bar {
    std::string name;
    int longth;
};

class Foo {
public:
  virtual ~Foo();
  virtual int GetSize() const = 0;
  // virtual std::string Describe(const char* name) = 0;
  virtual std::string Describe(int type) = 0;
  virtual bool Process(Bar elem, int count) = 0;
};

#endif
